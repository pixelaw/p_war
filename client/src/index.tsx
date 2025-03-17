import Main from "@/Main.tsx"
import React from "react"
import ReactDOM from "react-dom/client"
import "@/index.css"
import {PixelawProvider} from "@pixelaw/react"
import {BrowserRouter} from "react-router-dom"
import {DojoEngine} from "@pixelaw/core-dojo"
import {MudEngine} from "@pixelaw/core-mud"
import {DEFAULT_WORLD, getCoreDefaultsFromUrl} from "@/utils.ts";
import {StarknetChainProvider} from "@pixelaw/react-dojo"

// TODO for now hardcoded, but planning to retrieve from github URL using env WORLDS_REGISTRY_URL
import worldsRegistry from "@/config/worlds.json"


const rootElement = document.getElementById("root")

const engines = {"dojoengine": DojoEngine, "mudengine": MudEngine}

const coreDefaults = getCoreDefaultsFromUrl()

if (rootElement) {
    ReactDOM.createRoot(rootElement).render(
        <React.StrictMode>
            <PixelawProvider worldsRegistry={worldsRegistry} world={DEFAULT_WORLD} engines={engines} coreDefaults={coreDefaults}>
                    <BrowserRouter>
                        <StarknetChainProvider>
                        <Main />
                        </StarknetChainProvider>
                    </BrowserRouter>
                </PixelawProvider>
        </React.StrictMode>
    )
} else {
    console.error("Failed to find the root element")
}
