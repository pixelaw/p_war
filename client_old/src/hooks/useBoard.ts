import { useComponentValue } from "@dojoengine/react";
import { useDojo } from "./useDojo";
import { Entity } from "@dojoengine/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { DEFAULT_GAME_ID } from "@/constants";

// Always game is single and id = 1 for now
export const useBoard = () => {
  const {
    setup: {
      clientComponents: { Board },
    },
  } = useDojo();

  const board = useComponentValue(Board, getEntityIdFromKeys([BigInt(DEFAULT_GAME_ID)]) as Entity);

  return { board };
};
