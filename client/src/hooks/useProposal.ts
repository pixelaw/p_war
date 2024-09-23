import { useEntityQuery } from "@dojoengine/react";
import { useDojo } from "./useDojo";
import { getComponentValue, HasValue } from "@dojoengine/recs";
import { Entity } from "@dojoengine/torii-client";
import { useEffect, useMemo } from "react";

export const useProposals = (gameId: number) => {
  const {
    setup: {
      toriiClient,
      clientComponents: { Proposal },
    },
  } = useDojo();

  const proposalEntities = useEntityQuery([HasValue(Proposal, { game_id: gameId })]);

  const proposals = useMemo(() => {
    return proposalEntities
      .map((entity) => getComponentValue(Proposal, entity))
      .filter((proposal) => proposal !== undefined);
  }, [proposalEntities, Proposal]);

  // Effects
  useEffect(() => {
    const subscription = async () => {
      const sub = await toriiClient.onEntityUpdated(
        [
          {
            Keys: {
              keys: [gameId.toString()],
              pattern_matching: "FixedLen",
              models: ["pixelaw-Proposal"],
            },
          },
        ],
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (_entityId: any, entity: Entity) => {
          console.log(entity);
        },
      );

      return sub;
    };

    const sub = subscription();
    return () => {
      sub.then((sub) => sub.cancel());
    };
  }, [toriiClient, gameId]);

  return { proposals };
};
