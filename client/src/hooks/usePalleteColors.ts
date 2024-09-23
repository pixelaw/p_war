import { useEntityQuery } from "@dojoengine/react";
import { useDojo } from "./useDojo";
import { getComponentValue, Has } from "@dojoengine/recs";
import { hexToRgba } from "@/utils";
import { useMemo } from "react";
import { DEFAULT_COLOR_PALLETTE } from "@/constants";

export const usePaletteColors = () => {
  const {
    setup: {
      clientComponents: { PaletteColors },
    },
  } = useDojo();

  const paletteColorEntities = useEntityQuery([Has(PaletteColors)]);
  const paletteColors = useMemo(() => {
    const colors = paletteColorEntities
      .map((entity) => {
        const value = getComponentValue(PaletteColors, entity);
        if (value) {
          return hexToRgba(value.color);
        }
      })
      .filter((color) => color !== undefined);

    return colors.length === 0 ? DEFAULT_COLOR_PALLETTE : colors;
  }, [paletteColorEntities, PaletteColors]);

  return paletteColors;
};
