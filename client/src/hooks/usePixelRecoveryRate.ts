import { useComponentValue } from "@dojoengine/react";
import { useDojo } from "./useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { Entity } from "@dojoengine/recs";

// Always game is single and id = 1 for now
export const usePixelRecoveryRate = () => {
  const {
    setup: {
      clientComponents: { PixelRecoveryRate },
    },
  } = useDojo();

  const pixelRecoveryRate = useComponentValue(PixelRecoveryRate, getEntityIdFromKeys([BigInt(1)]) as Entity);

  return { pixelRecoveryRate };
};
