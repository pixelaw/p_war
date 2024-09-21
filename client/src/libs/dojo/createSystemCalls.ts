import { defineSystem, Has, HasValue, World } from "@dojoengine/recs";
import { ClientComponents } from "./createClientComponents";
import type { IWorld } from "./typescript/contracts.gen";
import { Account } from "starknet";
import { DefaultParameters } from "./typescript/models.gen";

const FAILURE_REASON_REGEX = /Failure reason: ".+"/;

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls({ client }: { client: IWorld }, clientComponents: ClientComponents, world: World) {
  const interact = async (account: Account, default_params: DefaultParameters) => {
    try {
      const tx = await client.p_war_actions.interact({
        account,
        default_params,
      });

      // Wait for the indexer to update the entity
      // By doing this we keep the optimistic UI in sync with the actual state
      await new Promise<void>((resolve) => {
        defineSystem(
          world,
          [Has(clientComponents.Pixel), HasValue(clientComponents.Player, { address: BigInt(account.address) })],
          () => {
            resolve();
          }
        );
      });

      const receipt = await account.waitForTransaction(tx.transaction_hash, {
          retryInterval: 100,
      });

      if ('execution_status' in receipt && receipt.statusReceipt === 'reverted') {
          if ('revert_reason' in receipt && !!receipt.revert_reason) {
              throw (
                  receipt.revert_reason.match(FAILURE_REASON_REGEX)?.[0] ??
                  receipt.revert_reason
              );
          } else throw new Error('transaction reverted');
      }

      if (receipt.statusReceipt === 'rejected') {
          if ('transaction_failure_reason' in receipt)
              throw receipt.transaction_failure_reason.error_message;
          else throw new Error('transaction rejected');
      }
    } catch (e) {
      console.log(e);
    }
  };

  return {
    interact,
  };
}
