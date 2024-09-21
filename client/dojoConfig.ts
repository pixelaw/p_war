import { createDojoConfig } from "@dojoengine/core";
import manifestDev from "../contracts/manifests/dev/deployment/manifest.json";
import manifestRelease from "../contracts/manifests/release/deployment/manifest.json";

export const manifest = import.meta.env.VITE_PUBLIC_PROFILE === "dev" ? manifestDev : manifestRelease;

export const dojoConfig = createDojoConfig({
  toriiUrl: import.meta.env.VITE_PUBLIC_TORII_URL,
  rpcUrl: import.meta.env.VITE_PUBLIC_RPC_URL,
  masterAddress: import.meta.env.VITE_PUBLIC_MASTER_ADDRESS,
  masterPrivateKey: import.meta.env.VITE_PUBLIC_MASTER_PRIVATE_KEY,
  manifest,
});
