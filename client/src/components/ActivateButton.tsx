import { DEFAULT_GAME_ID } from "@/constants";
import { useDojo } from "@/hooks/useDojo";
import { Position, Proposal } from "@/libs/dojo/typescript/models.gen";
import { useEntityQuery } from "@dojoengine/react";
import { getComponentValue, HasValue } from "@dojoengine/recs";
import { useCallback, useMemo } from "react";

export const ActivateProposalButton = ({ proposal }: { proposal: Proposal }) => {
  // Hooks
  const {
    setup: {
      systemCalls: { activateProposal },
      clientComponents: { Pixel },
    },
    account: { account },
    connectedAccount,
  } = useDojo();

  // State
  const activeAccount = useMemo(() => connectedAccount || account, [connectedAccount, account]);
  const targetPixelEntities = useEntityQuery([HasValue(Pixel, { color: proposal.target_args_2 })]);
  const targetPixels = useMemo(
    () =>
      targetPixelEntities
        .map((entity) => {
          const value = getComponentValue(Pixel, entity);
          if (!value) return;
          return {
            x: value.x,
            y: value.y,
          } as Position;
        })
        .filter((pixel) => pixel !== undefined),
    [targetPixelEntities, Pixel]
  );

  console.log(targetPixels);

  // Handler
  const handleActivateProposal = useCallback(async () => {
    if (proposal.target_args_1 === 1) {
      await activateProposal(activeAccount, DEFAULT_GAME_ID, proposal.index, [{ x: 0, y: 0 }]);
    } else {
      await activateProposal(activeAccount, DEFAULT_GAME_ID, proposal.index, targetPixels);
    }
  }, [proposal, activeAccount, targetPixels, activateProposal]);

  return (
    <button
      className="absolute bottom-4 right-4 rounded-md px-4 py-2 text-sm transition duration-300 bg-blue-600 text-white hover:bg-blue-500"
      onClick={handleActivateProposal}
    >
      Activate
    </button>
  );
};
