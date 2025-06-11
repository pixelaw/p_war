import {
  type Coordinate,
  type Interaction,
  type Notification,
  type QueueItem,
  getZoomLevel,
} from "@pixelaw/core";

import AppPickerButton from "@/components/GamePage/AppPicker/AppPickerButton.tsx";
import ColorPicker from "@/components/GamePage/ColorPicker/ColorPicker.tsx";
import ColorPickerButton from "@/components/GamePage/ColorPicker/ColorPickerButton.tsx";
import { WalletPicker } from "@/components/GamePage/WalletPicker/WalletPicker.tsx";
import WalletPickerButton from "@/components/GamePage/WalletPicker/WalletPickerButton.tsx";
import { InteractionDialog, usePixelawProvider } from "@pixelaw/react";
import { useEffect, useMemo, useRef, useState } from "react";
import type { SimplePixelError } from "../../../../pixelaw.js/packages/core/src";
import styles from "./GamePage.module.css";

import AppPicker from "@/components/GamePage/AppPicker/AppPicker";
import SimpleColorPicker from "@/components/GamePage/ColorPicker/SimpleColorPicker.tsx";

// biome-ignore lint/complexity/noBannedTypes: TODO
function debounce(func: Function, wait: number) {
  let timeout: NodeJS.Timeout;
  const debouncedFunction = (...args: any[]) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
  debouncedFunction.cancel = () => clearTimeout(timeout);
  return debouncedFunction;
}

const GamePage: React.FC = () => {
  try {
    // TODO: Ideally pixelawCore doesnt need to be exposed here, and we have a setter for renderer
    const {
      pixelawCore,
      coreStatus,
      world,
      app,
      color,
      center,
      zoom,
      setColor,
      setApp,
    } = usePixelawProvider();
    const [selectedApp, setSelectedApp] = useState<string>("snake");
    const appIcon = !app
      ? ""
      : pixelawCore.appStore.getByName(selectedApp)!.icon;

    const { viewPort: renderer } = pixelawCore;
    const rendererContainerRef = useRef<HTMLDivElement | null>(null);
    const [currentInteraction, setCurrentInteraction] =
      useState<Interaction | null>(null);

    const zoombasedAdjustment = useMemo(() => {
      return ["mid", "close"].includes(getZoomLevel(zoom)) ? "0px" : "-100%";
    }, [zoom]);

    const [activeChooser, setActiveChooser] = useState<
      "color" | "wallet" | "app" | null
    >(null);

    const handleColorPickerClick = () => {
      if (app === "paint") {
        setActiveChooser((prev) => (prev === "color" ? null : "color"));
      } else {
        setApp("paint");
      }
    };

    const handleColorPickerSecondaryClick = () =>
      setActiveChooser((prev) => (prev === "color" ? null : "color"));

    const handleWalletPickerClick = () => {
      if (app === "player") {
        setActiveChooser((prev) => (prev === "wallet" ? null : "wallet"));
      } else {
        setApp("player");
      }
    };

    const handleWalletPickerSecondaryClick = () =>
      setActiveChooser((prev) => (prev === "wallet" ? null : "wallet"));

    const handleAppPickerClick = () => {
      if (app !== "player" && app !== "paint") {
        setActiveChooser((prev) => (prev === "app" ? null : "app"));
      } else {
        setApp(selectedApp);
      }
    };

    const handleAppPickerSecondaryClick = () =>
      setActiveChooser((prev) => (prev === "app" ? null : "app"));

    const playerIcon = "⭐";

    // Updating the URL
    useEffect(() => {
      const updateURL = () => {
        const queryParams = new URLSearchParams();
        queryParams.set("app", app ?? "");
        queryParams.set("center", `${center[0]},${center[1]}`);
        queryParams.set("zoom", zoom.toString());
        queryParams.set("color", color.toString());
        queryParams.set("world", world!);
        const newSearch = `?${queryParams.toString()}`;

        if (window.location.search !== newSearch) {
          window.history.replaceState(null, "", newSearch);
        }
      };
      const debounceUpdateURL = debounce(updateURL, 300);

      try {
        debounceUpdateURL();
      } catch (e) {
        console.log(e);
      }
      return () => {
        debounceUpdateURL.cancel();
      };
    }, [app, center, zoom, color, world]);

    // Handle viewport events
    useEffect(() => {
      const handleCellClick = async (cell: Coordinate) => {
        if (getZoomLevel(zoom) === "far") {
          console.warn("not handling cell click if zoomed out far");
          return;
        }

        const interaction = await pixelawCore.prepInteraction(cell);

        if (interaction.getUserParams().length === 0) {
          await interaction.execute();
          return;
        }

        console.log(interaction);
        setCurrentInteraction(interaction);
      };

      const handleQueueItem = (item: QueueItem) => {
        console.log("scheduled+");
        pixelawCore.executeQueueItem(item).catch(console.error);
      };

      const handleNotification = (item: Notification) => {
        console.log("NOTIFICATION", item);
      };

      const handleError = (error: SimplePixelError) => {
        console.log("handleError", JSON.stringify(error));
        if (error.coordinate) {
          pixelawCore.viewPort.addGlow(
            error.coordinate,
            2000,
            "#FF0000",
            10,
            50,
          );
        }
      };

      console.log("handling");
      pixelawCore.queue.eventEmitter.on("scheduled", handleQueueItem);
      pixelawCore.queue.retrieve().then(() => {
        //Just let it run
      });

      // pixelawCore.events.on("cellHovered", handleCellHover)
      pixelawCore.events.on("cellClicked", handleCellClick);
      pixelawCore.events.on("error", handleError);
      pixelawCore.events.on("notification", handleNotification);

      return () => {
        // pixelawCore.events.off("cellHovered", handleCellHover)
        pixelawCore.events.off("cellClicked", handleCellClick);
        pixelawCore.queue.eventEmitter.off("scheduled", handleQueueItem);
        pixelawCore.events.off("error", handleError);
        pixelawCore.events.off("notification", handleNotification);
      };
    }, [pixelawCore, zoom]);

    useEffect(() => {
      if (!coreStatus.startsWith("ready")) return;

      renderer.setContainer(rendererContainerRef.current!);
    }, [coreStatus, renderer]);

    return (
      <>
        <div
          ref={rendererContainerRef}
          style={{ width: "100%", height: "100%", touchAction: "none" }}
        />

        {activeChooser === "color" && (
          <SimpleColorPicker
            color={color}
            onColorSelect={(color) => {
              setColor(color);
              setActiveChooser(null);
            }}
          />
        )}
        {activeChooser === "wallet" && (
          <WalletPicker onClose={() => setActiveChooser(null)} />
        )}

        {activeChooser === "app" && (
          <AppPicker
            selectedApp={selectedApp}
            setSelectedApp={setSelectedApp}
            onClose={() => setActiveChooser(null)}
          />
        )}

        <div id={styles.bottomMenu} style={{ bottom: zoombasedAdjustment }}>
          <AppPickerButton
            appEmoji={appIcon}
            onClick={handleAppPickerClick}
            onSecondary={handleAppPickerSecondaryClick}
            selected={app !== "player" && app !== "paint"}
          />
          <WalletPickerButton
            playerEmoji={playerIcon}
            onClick={handleWalletPickerClick}
            onSecondary={handleWalletPickerSecondaryClick}
            selected={app === "player"}
          />
          <ColorPickerButton
            color={color}
            onClick={handleColorPickerClick}
            onSecondary={handleColorPickerSecondaryClick}
            selected={app === "paint"}
          />
        </div>

        {currentInteraction && (
          <InteractionDialog
            interaction={currentInteraction}
            onSubmit={(interaction) => {
              console.log("Interaction submitted:", interaction);
              setCurrentInteraction(null); // Clear the interaction after submission
            }}
            onCancel={(interaction) => {
              console.log("Interaction cancelled:", interaction);
              setCurrentInteraction(null); // Clear the interaction after submission
            }}
          />
        )}
      </>
    );
  } catch (e) {
    console.log(e);
  }
  //</editor-fold>
};

export default GamePage;
