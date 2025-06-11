import Main from "@/Main.tsx";
import React from "react";
import ReactDOM from "react-dom/client";
import "@/index.css";
import { PixelawProvider, usePixelawProvider } from "@pixelaw/react";
import { BrowserRouter } from "react-router-dom";
import { DojoEngine } from "@pixelaw/core-dojo";
import { MudEngine } from "@pixelaw/core-mud";
import { getCoreDefaultsFromUrl, getWorldForUrl } from "@/utils.ts";
import { StarknetChainProvider } from "@pixelaw/react-dojo";
import type { WorldsRegistry } from "@pixelaw/core";
import worldsRegistry from "@/config/worlds.json";
import { setupWorld } from "@/config/contracts.gen";
import { DojoWallet } from "@pixelaw/core-dojo";
import { PwarContext } from "./provider/PwarContext";
import { pwarManifest } from "./config/manifest.contracts";


const AppContent = React.memo(() => {
    const { coreStatus, pixelawCore } = usePixelawProvider()

    React.useEffect(() => {
        if (coreStatus !== "ready" && coreStatus !== "readyWithoutWallet" && coreStatus !== "initAccount") {
            const timer = setTimeout(() => {
                console.log("Auto-refreshing after 5 seconds of loading...");
                window.location.reload();
            }, 5000);
            return () => clearTimeout(timer);
        }
    }, [coreStatus]);

    const contextValue = React.useMemo(() => {
    if (!pixelawCore) {
      console.log("pixelawCore is not available");
      return null;
    }
    
    if (coreStatus !== "ready" && coreStatus !== "readyWithoutWallet") {
      console.log("Core status is not ready:", coreStatus);
      return null;
    }

    try {
      const account = pixelawCore.account;
      const wallet = pixelawCore.wallet as DojoWallet;
      const provider = pixelawCore.engine["dojoSetup"]?.provider;
      
      if (!provider) {
        console.error("Provider is not available in dojoSetup");
        return null;
      }
      
      const manifest = pixelawCore.engine["dojoSetup"].manifest;
      const mergedContracts = [...manifest.contracts, ...pwarManifest];
      pixelawCore.engine["dojoSetup"].manifest.contracts = mergedContracts;
      const world = setupWorld(provider);
      // console.log("manifest contracts: ", manifest.contracts);
      // console.log("wallet:", wallet);
      // console.log("Provider:", provider);
      // console.log("World:", world);
      // console.log("merged contracts", mergedContracts);

      return { account, wallet, provider, world };
    } catch (error) {
      console.error("Error setting up context:", error);
      return null;
    }
  }, [pixelawCore, coreStatus]);

    // if (coreStatus === "error") {
    //     return <div className="error-message">Error occurred, check the logs</div>
    // }
    if (coreStatus === "initAccount") {
        return (
            <BrowserRouter>
                <StarknetChainProvider>
                    <div className="loading-message">Pls wait 🧘 : Initializing account</div>
                </StarknetChainProvider>
            </BrowserRouter>
        )
    }
    if (
      (coreStatus === "ready" || coreStatus === "readyWithoutWallet") && contextValue)
      {
        return (
          <BrowserRouter>
            <StarknetChainProvider>
              <PwarContext.Provider value={contextValue}>
                {" "}
                <Main />
              </PwarContext.Provider>
            </StarknetChainProvider>
          </BrowserRouter>
        );
    }
    
  return <div className="loading-message">Pls wait 🧘 : Loading (Auto-refreshing in 5s)</div>
});

const App = () => {
  console.log("Initializing App with:", {
    worldsRegistry,
    world,
    engines,
    coreDefaults
  });
  
  return (
    <PixelawProvider
      worldsRegistry={worldsRegistry as WorldsRegistry}
      world={world}
      engines={engines}
      coreDefaults={coreDefaults}
    >
      <AppContent />
    </PixelawProvider>
  );
};

const { protocol, hostname } = window.location;
const baseUrl = `${protocol}//${hostname}`;

const world = getWorldForUrl(
  worldsRegistry as WorldsRegistry,
  baseUrl,
  "local",
);

const rootElement = document.getElementById("root");

const engines = { dojo: DojoEngine, mud: MudEngine };

const coreDefaults = getCoreDefaultsFromUrl();

if (rootElement) {
  ReactDOM.createRoot(rootElement).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  );
} else {
  console.error("Failed to find the root element");
}
