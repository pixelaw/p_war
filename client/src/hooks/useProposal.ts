import { useEntityQuery } from "@dojoengine/react";
import { useDojo } from "./useDojo";
import { getComponentValue, HasValue } from "@dojoengine/recs";
import { useMemo } from "react";

export const useProposals = (gameId: number) => {
  const {
    setup: {
      clientComponents: { Proposal },
    },
  } = useDojo();

  const proposalEntities = useEntityQuery([HasValue(Proposal, { game_id: gameId })]);

  const proposals = useMemo(() => {
    return proposalEntities
      .map((entity) => getComponentValue(Proposal, entity))
      .filter((proposal) => proposal !== undefined);
  }, [proposalEntities, Proposal]);

  return { proposals };
};
