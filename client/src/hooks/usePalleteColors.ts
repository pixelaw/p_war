import { useEntityQuery } from "@dojoengine/react";
import { useDojo } from "./useDojo";
import { getComponentValue, Has } from "@dojoengine/recs";
import { hexToRgba } from "@/utils";
import { useMemo } from "react";

export const usePaletteColors = () => {
  const {
    setup: {
      clientComponents: { PaletteColors },
    },
  } = useDojo();

  const paletteColorEntities = useEntityQuery([Has(PaletteColors)]);
  const paletteColors = useMemo(
    () =>
      paletteColorEntities
        .map((entity) => {
          const value = getComponentValue(PaletteColors, entity);
          if (value) {
            return hexToRgba(value.color);
          }
        })
        .filter((color) => color !== undefined),
    [paletteColorEntities, PaletteColors]
  );

  return paletteColors;
};
