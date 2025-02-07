import { Connector } from "@starknet-react/core";
import CartridgeConnector from "@cartridge/connector";
import { getContractByName } from "@dojoengine/core";
import { ControllerOptions } from "@cartridge/controller";
import { manifest } from "../../../dojoConfig";

const p_war_actions = getContractByName(manifest, "pixelaw", "p_war_actions");
if (!p_war_actions?.address) {
  throw new Error("pixelaw-p_war_actions contract not found");
}
const propose_actions = getContractByName(manifest, "pixelaw", "propose_actions");
if (!propose_actions?.address) {
  throw new Error("pixelaw-propose_actions contract not found");
}
const voting_actions = getContractByName(manifest, "pixelaw", "voting_actions");
if (!voting_actions?.address) {
  throw new Error("pixelaw-voting_actions contract not found");
}

const guild_actions = getContractByName(manifest, "pixelaw", "guild_actions");
if (!guild_actions?.address) {
  throw new Error("pixelaw-guild_actions contract not found");
}

const policies = [
  {
    target: import.meta.env.VITE_PUBLIC_FEE_TOKEN_ADDRESS,
    method: "approve",
  },
  // p_war_actions
  {
    target: p_war_actions.address,
    method: "interact",
  },
  // propose_actions
  {
    target: propose_actions.address,
    method: "create_proposal",
  },
  {
    target: propose_actions.address,
    method: "activate_proposal",
  },
  // vote_actions
  {
    target: voting_actions.address,
    method: "vote",
  },
  // guild_actions
  {
    target: guild_actions.address,
    method: "create_guild",
  },
  {
    target: guild_actions.address,
    method: "add_member",
  },
  {
    target: guild_actions.address,
    method: "remove_member",
  },
];
const options: ControllerOptions = {
  rpc: import.meta.env.VITE_PUBLIC_RPC_URL,
  policies,
  paymaster: {
    caller: "0x1091e8bd03d373366cc8fd0adaeac683293a67eeb1e5a9e2c68677ce2c77cb2",
  },
};

const cartridgeConnector = new CartridgeConnector(options) as never as Connector;

export default cartridgeConnector;
