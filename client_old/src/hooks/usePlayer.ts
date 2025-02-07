import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useMemo } from "react";
import { useDojo } from "./useDojo";
import { useComponentValue } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";

export const usePlayer = () => {
  const {
    setup: {
      account: { account },
      clientComponents: { Player },
      connectedAccount,
    },
  } = useDojo();
  const activeAccount = useMemo(() => connectedAccount || account, [connectedAccount, account]);

  const key = useMemo(() => getEntityIdFromKeys([BigInt(activeAccount?.address)]) as Entity, [activeAccount?.address]);
  const player = useComponentValue(Player, key);

  return { player };
};
