import { startTransition, useCallback, useMemo, useRef, useState, useOptimistic } from "react";
import { BASE_CELL_SIZE } from "@/constants/webgl";
import { Pixel, type Color } from "@/types";
import { useDojo } from "@/hooks/useDojo";
import { rgbaToUint32, uint32ToRgba } from "@/utils";
import { useSound } from "use-sound";
import { DEFAULT_BOARD_SIZE, sounds } from "@/constants";
import { useGridState } from "@/hooks/useGridState";
import { useWebGL } from "@/hooks/useWebGL";
import { CoordinateFinder } from "@/components/CoordinateFinder";
import { ColorPalette } from "@/components/ColorPallette";
import { CanvasGrid } from "@/components/CanvasGrid";
import { usePaletteColors } from "@/hooks/usePalleteColors";
import { useEntityQuery } from "@dojoengine/react";
import { getComponentValue, Has } from "@dojoengine/recs";
import { detectMobile } from "@/utils/devices";
import { useHaptic } from "use-haptic";

export const PixelViewer: React.FC = () => {
  // Refs
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Other Hooks
  const {
    setup: {
      systemCalls: { interact },
      account: { account },
      connectedAccount,
      clientComponents: { Pixel },
    },
  } = useDojo();
  const { gridState, setGridState } = useGridState();
  // NOTE: On the assumption that game_id is just 1, and there are any other related pixels other than p_war in the world
  const pixelEntities = useEntityQuery([Has(Pixel)]);
  const paletteColors = usePaletteColors();
  const { drawPixels } = useWebGL(canvasRef, gridState);
  const [play] = useSound(sounds.placeColor, { volume: 0.5 });
  const { vibe } = useHaptic();

  // States
  const isMobile = detectMobile();
  const [selectedColor, setSelectedColor] = useState<Color>(paletteColors[0]);
  const [currentMousePos, setCurrentMousePos] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const activeAccount = useMemo(() => connectedAccount || account, [connectedAccount, account]);
  const visiblePixels = useMemo(
    () =>
      pixelEntities
        .map((entity) => {
          const pixel = getComponentValue(Pixel, entity);
          if (!pixel) return;

          return { x: pixel.x, y: pixel.y, color: uint32ToRgba(pixel.color) };
        })
        .filter((pixel) => pixel !== undefined),
    [pixelEntities, Pixel],
  );
  const [optimisticPixels, setOptimisticPixels] = useOptimistic(visiblePixels, (pixels, newPixel: Pixel) => {
    return [...pixels, newPixel];
  });

  // Handlers
  const onCellClick = useCallback(
    async (x: number, y: number) => {
      startTransition(async () => {
        setOptimisticPixels({ x, y, color: selectedColor });
        play();
        await interact(activeAccount, {
          for_player: 0n,
          for_system: 0n,
          position: { x, y },
          color: rgbaToUint32(selectedColor),
        });
      });
    },
    [selectedColor, activeAccount, interact, setOptimisticPixels, play],
  );

  const onTap = useCallback(
    (x: number, y: number) => {
      vibe();
      onCellClick(x, y);
    },
    [onCellClick, vibe],
  );

  const onDrawGrid = useCallback(() => {
    drawPixels(optimisticPixels);
  }, [optimisticPixels, drawPixels]);

  const animateJumpToCell = useCallback(
    (x: number, y: number, duration: number = 500) => {
      const canvas = canvasRef.current;
      if (!canvas) return;

      const canvasWidth = canvas.width;
      const canvasHeight = canvas.height;

      const startTime = performance.now();
      const startOffsetX = gridState.offsetX;
      const startOffsetY = gridState.offsetY;

      const targetOffsetX = Math.max(0, x * BASE_CELL_SIZE + BASE_CELL_SIZE / 2 - canvasWidth / (2 * gridState.scale));
      const targetOffsetY = Math.max(0, y * BASE_CELL_SIZE + BASE_CELL_SIZE / 2 - canvasHeight / (2 * gridState.scale));

      const animateFrame = () => {
        const elapsedTime = performance.now() - startTime;
        const progress = Math.min(elapsedTime / duration, 1);

        // easing function (optional: smooth movement)
        const easeProgress = 1 - Math.pow(1 - progress, 3);

        setGridState((prev) => ({
          ...prev,
          offsetX: startOffsetX + (targetOffsetX - startOffsetX) * easeProgress,
          offsetY: startOffsetY + (targetOffsetY - startOffsetY) * easeProgress,
        }));

        if (progress < 1) {
          requestAnimationFrame(animateFrame);
        } else {
          startTransition(() => {
            setCurrentMousePos({ x, y });
          });
        }
      };

      requestAnimationFrame(animateFrame);
    },
    [gridState, setGridState, setCurrentMousePos],
  );

  return (
    <section className="relative h-full w-full">
      <CanvasGrid
        canvasRef={canvasRef}
        className="fixed inset-x-0 bottom top-[50px] h-[calc(100%-50px)] w-full bg-black/80"
        onCellClick={isMobile ? undefined : onCellClick}
        onTap={isMobile ? onTap : undefined} // NOTE: somehow tap and mouseup events are called duplicated (it might be depends on the environemnts??)
        onDrawGrid={onDrawGrid}
        setCurrentMousePos={setCurrentMousePos}
        gridState={gridState}
        setGridState={setGridState}
        maxCellSize={DEFAULT_BOARD_SIZE}
      />
      <CoordinateFinder currentMousePos={currentMousePos} animateJumpToCell={animateJumpToCell} />
      <ColorPalette selectedColor={selectedColor} setSelectedColor={setSelectedColor} />
    </section>
  );
};
