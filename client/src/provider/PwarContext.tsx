import { createContext, useContext } from "react";
import type { DojoWallet } from "@pixelaw/core-dojo";
import type { Account, Provider } from "starknet";

export type IPwarContext = {
  wallet: DojoWallet;
  account: Account;
  provider: Provider;
  world: World;
};

export const PwarContext = createContext<IPwarContext | undefined>(undefined);

export const usePwarProvider = (): IPwarContext => {
  const context = useContext(PwarContext);
  if (!context) {
    throw new Error("usePwarProvider must be used within a PwarProvider");
  }
  return context;
};
