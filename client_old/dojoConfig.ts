import { createDojoConfig } from "@dojoengine/core";
import manifestDev from "../contracts/manifest_dev.json";
// import manifestSepolia from "../contracts/manifest_sepolia.json";

export const manifest = manifestDev;

export const dojoConfig = createDojoConfig({
  toriiUrl: import.meta.env.VITE_PUBLIC_TORII_URL,
  rpcUrl: import.meta.env.VITE_PUBLIC_RPC_URL,
  masterAddress: import.meta.env.VITE_PUBLIC_MASTER_ADDRESS,
  masterPrivateKey: import.meta.env.VITE_PUBLIC_MASTER_PRIVATE_KEY,
  manifest,
});
