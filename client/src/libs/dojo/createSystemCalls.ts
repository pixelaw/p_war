import { defineSystem, Has, HasValue, World } from "@dojoengine/recs";
import { ClientComponents } from "./createClientComponents";
import type { IWorld } from "./typescript/contracts.gen";
import { Account } from "starknet";
import { DefaultParameters } from "./typescript/models.gen";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls({ client }: { client: IWorld }, clientComponents: ClientComponents, world: World) {
  const interact = async (account: Account, default_params: DefaultParameters) => {
    try {
      await client.p_war_actions.interact({
        account,
        default_params,
      });

      // Wait for the indexer to update the entity
      // By doing this we keep the optimistic UI in sync with the actual state
      await new Promise<void>((resolve) => {
        defineSystem(
          world,
          [Has(clientComponents.PWarPixel), HasValue(clientComponents.Player, { address: BigInt(account.address) })],
          () => {
            resolve();
          }
        );
      });
    } catch (e) {
      console.log(e);
    }
  };

  return {
    interact,
  };
}
