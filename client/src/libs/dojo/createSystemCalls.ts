import { defineSystem, Has, HasValue, World } from "@dojoengine/recs";
import { ClientComponents } from "./createClientComponents";
import type { IWorld } from "./typescript/contracts.gen";
import { Account } from "starknet";
import { DefaultParameters } from "./typescript/models.gen";
import { handleTransactionError } from "@/utils";
import { toast } from "sonner";

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
          }
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
          }
        );
      });
    } catch (e) {
      handleError("vote", e);
    }
  };

  const activateProposal = async (
    account: Account,
    game_id: number,
    index: number,
    clearData: { x: number; y: number }[]
  ) => {
    try {
      const { transaction_hash } = await client.propose_actions.activate_proposal({
        account,
        game_id,
        index,
        clear_data: clearData,
      });
      console.log(transaction_hash);
    } catch (e) {
      handleError("activateProposal", e);
    }
  };

  return {
    interact,
    vote,
    activateProposal,
  };
}
