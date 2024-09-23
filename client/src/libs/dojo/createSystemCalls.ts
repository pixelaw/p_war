import { defineSystem, Has, HasValue, World } from "@dojoengine/recs";
import { ClientComponents } from "./createClientComponents";
import type { IWorld } from "./typescript/contracts.gen";
import { Account } from "starknet";
import { DefaultParameters } from "./typescript/models.gen";
import { handleTransactionError } from "@/utils";
import { toast } from "sonner";
import { ProposalType } from "@/types";

const handleError = (action: string, error: unknown) => {
  console.error(`Error executing ${action}:`, error);
  const errorMessage = handleTransactionError(error);
  console.info(errorMessage);
  toast.error(errorMessage);
  throw error;
};

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls({ client }: { client: IWorld }, clientComponents: ClientComponents, world: World) {
  const interact = async (account: Account, default_params: DefaultParameters) => {
    console.log("interact", default_params);
    try {
      const { transaction_hash } = await client.p_war_actions.interact({
        account,
        default_params,
      });
      console.log(transaction_hash);

      // // Wait for the indexer to update the entity
      // // By doing this we keep the optimistic UI in sync with the actual state
      await new Promise<void>((resolve) => {
        defineSystem(
          world,
          [
            Has(clientComponents.PWarPixel),
            HasValue(clientComponents.Player, {
              address: BigInt(account.address),
            }),
          ],
          () => {
            resolve();
          },
        );
      });
    } catch (e) {
      handleError("interact", e);
    }
  };

  const vote = async (account: Account, game_id: number, index: number, use_px: number, is_in_favor: boolean) => {
    try {
      const { transaction_hash } = await client.voting_actions.vote({
        account,
        game_id,
        index,
        use_px,
        is_in_favor,
      });
      console.log(transaction_hash);

      await new Promise<void>((resolve) => {
        defineSystem(
          world,
          [
            HasValue(clientComponents.Proposal, {
              game_id,
            }),
            HasValue(clientComponents.Game, {
              id: game_id,
            }),
            HasValue(clientComponents.Player, {
              address: BigInt(account.address),
            }),
          ],
          () => {
            resolve();
          },
        );
      });
    } catch (e) {
      handleError("vote", e);
    }
  };

  const activateProposal = async (
    account: Account,
    gameId: number,
    index: number,
    clearData: { x: number; y: number }[],
  ) => {
    try {
      const { transaction_hash } = await client.propose_actions.activate_proposal({
        account,
        game_id: gameId,
        index,
        clear_data: clearData,
      });
      console.log(transaction_hash);

      await new Promise<void>((resolve) => {
        defineSystem(
          world,
          [
            HasValue(clientComponents.Proposal, {
              game_id: gameId,
            }),
            HasValue(clientComponents.Game, {
              id: gameId,
            }),
            HasValue(clientComponents.Player, {
              address: BigInt(account.address),
            }),
          ],
          () => {
            resolve();
          },
        );
      });
    } catch (e) {
      handleError("activateProposal", e);
    }
  };

  const createProposal = async (account: Account, gameId: number, proposalType: ProposalType, color?: number) => {
    try {
      const { transaction_hash } = await client.propose_actions.create_proposal({
        account,
        game_id: gameId,
        proposal_type: proposalType,
        target_args_1: color ? color : 0,
        target_args_2: 0,
      });
      console.log(transaction_hash);

      await new Promise<void>((resolve) => {
        defineSystem(
          world,
          [
            HasValue(clientComponents.Proposal, {
              game_id: gameId,
            }),
            HasValue(clientComponents.Game, {
              id: gameId,
            }),
            HasValue(clientComponents.Player, {
              address: BigInt(account.address),
            }),
          ],
          () => {
            resolve();
          },
        );
      });
      console.log("Done");
    } catch (e) {
      handleError("createProposal", e);
    }
  };

  return {
    interact,
    vote,
    createProposal,
    activateProposal,
  };
}
