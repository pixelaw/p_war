import Main from "@/Main.tsx"
import React from "react"
import ReactDOM from "react-dom/client"
import "@/index.css"
import { PixelawProvider } from "@pixelaw/react"
import { BrowserRouter } from "react-router-dom"
import {DojoEngine} from "@pixelaw/core-dojo"
import {MudEngine} from "@pixelaw/core-mud"
import {DEFAULT_WORLD, getCoreDefaultsFromUrl} from "@/utils.ts";
import { StarknetChainProvider } from "@pixelaw/react-dojo"

// TODO for now hardcoded, but planning to retrieve from github URL using env WORLDS_REGISTRY_URL
import worldsRegistry from "@/config/worlds.json"
import { PwarProvider } from "./providers/PwarProvider"


const rootElement = document.getElementById("root")

const engines = [DojoEngine, MudEngine]

const coreDefaults = getCoreDefaultsFromUrl()

const ChainProvider = StarknetChainProvider

console.log("root")
if (rootElement) {
    ReactDOM.createRoot(rootElement).render(
        <React.StrictMode>
            <PixelawProvider worldsRegistry={worldsRegistry} world={DEFAULT_WORLD} engines={engines} coreDefaults={coreDefaults}>
                <PwarProvider>
                    <BrowserRouter>
                        <ChainProvider>
                        <Main />
                        </ChainProvider>
                    </BrowserRouter>
                </PwarProvider>
            </PixelawProvider>
        </React.StrictMode>
    )
} else {
    console.error("Failed to find the root element")
}
