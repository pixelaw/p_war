import { useEntityQuery } from "@dojoengine/react";
import { useDojo } from "./useDojo";
import { getComponentValue, HasValue } from "@dojoengine/recs";
import { Entity } from "@dojoengine/torii-client";
import { useEffect, useMemo } from "react";
import { toast } from "sonner";
import { createProposalTitle, formatWalletAddressWithEmoji } from "@/utils";
import { getProposalFromEntity } from "@/libs/dojo/helper";

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

          // 1. if this proposal is new or not
          const isNewProposal = proposals.find((p) => p.index === updatedProposal.index) === undefined;

          if (isNewProposal) {
            toast.success("New Proposal Submitted", {
              description: `by ${formatWalletAddressWithEmoji("0x" + updatedProposal.author.toString(16))}`,
            });
          } else {
            const title = createProposalTitle(
              updatedProposal.proposal_type,
              updatedProposal.target_args_1,
              updatedProposal.target_args_2,
            );
            // 2. if it'snot, need to detect what's changed
            const oldProposal = proposals.find((p) => p.index === updatedProposal.index);
            if (oldProposal) {
              const isActivated = oldProposal.is_activated !== updatedProposal.is_activated;
              if (isActivated) {
                toast.success("Proposal activated", {
                  description: `${title}`,
                });
              } else if (oldProposal.yes_voting_power < updatedProposal.yes_voting_power) {
                toast.success("Voted in favor", {
                  description: `${title}`,
                });
              } else if (oldProposal.no_voting_power < updatedProposal.no_voting_power) {
                toast.error("Voted against", {
                  description: `${title}`,
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
