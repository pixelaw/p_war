import { useComponentValue } from "@dojoengine/react";
import { useDojo } from "./useDojo";
import { Entity } from "@dojoengine/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { DEFAULT_GAME_ID } from "@/constants";

// Always game is single and id = 1 for now
export const useGame = () => {
  const {
    setup: {
      clientComponents: { Game },
    },
  } = useDojo();

  const game = useComponentValue(Game, getEntityIdFromKeys([BigInt(DEFAULT_GAME_ID)]) as Entity);
  console.log(game);

  return { game };
};
