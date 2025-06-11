import { createContext, useContext } from "react";
import { DojoWallet } from "@pixelaw/core-dojo";

//TODO: avoid any type.
export type IPwarContext = {
  wallet: DojoWallet;
  account: any;
  provider: any;
  world: any;
};

export const PwarContext = createContext<IPwarContext | undefined>(undefined);

export const usePwarProvider = (): IPwarContext => {
  const context = useContext(PwarContext);
  if (!context) {
    throw new Error("usePwarProvider must be used within a PwarProvider");
  }
  return context;
};
