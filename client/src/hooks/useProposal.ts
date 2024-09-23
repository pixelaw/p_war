import { useEntityQuery } from "@dojoengine/react";
import { useDojo } from "./useDojo";
import { getComponentValue, HasValue } from "@dojoengine/recs";
import { Entity } from "@dojoengine/torii-client";
import { useEffect, useMemo } from "react";
import { Proposal } from "@/libs/dojo/typescript/models.gen";
import { toast } from "sonner";
import { createProposalTitle, formatWalletAddressWithEmoji } from "@/utils";

const getProposalFromEntity = (entity: Entity) => {
  return entity["pixelaw-Proposal"] as unknown as Proposal;
};

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
              keys: [],
              pattern_matching: "VariableLen",
              models: ["pixelaw-Proposal"],
            },
          },
        ],
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (_entityId: any, entity: Entity) => {
          const updatedProposal = getProposalFromEntity(entity);
          console.log("proposal", updatedProposal);
          // 1. if this proposal is new or not
          const isNewProposal = proposals.find((p) => p.index === updatedProposal.index) === undefined;
          if (isNewProposal) {
            toast.success("New Proposal Submitted", {
              description: `by ${formatWalletAddressWithEmoji("0x" + updatedProposal.author.toString(16))}`,
            });
          } else {
            // 2. if it'snot, need to detect what's changed
            const oldProposal = proposals.find((p) => p.index === updatedProposal.index);
            if (oldProposal) {
              const isActivated = oldProposal.is_activated !== updatedProposal.is_activated;
              if (isActivated) {
                toast.success("Proposal activated", {
                  description: `${createProposalTitle(updatedProposal.proposal_type, updatedProposal.target_args_1, updatedProposal.target_args_2)}`,
                });
              }
            }
          }
        },
      );

      return sub;
    };

    const sub = subscription();
    return () => {
      sub.then((sub) => sub.cancel());
    };
  }, [toriiClient, proposals]);

  return { proposals };
};
