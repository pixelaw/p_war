import Apps from "@/components/GamePage/Apps/Apps.tsx"
import SimpleColorPicker from "@/components/GamePage/ColorPicker/SimpleColorPicker.tsx"
import {clearDomChildren} from "@/utils.ts"
import { type Coordinate } from "@pixelaw/core"
import { usePixelawProvider } from "@pixelaw/react"
import { useEffect, useMemo, useRef } from "react"
import styles from "./GamePage.module.css"
import dialogStyles from "./dialog.css"



const GamePage: React.FC = () => {
    // TODO: Ideally pixelawCore doesnt need to be exposed here, and we have a setter for renderer
    const { pixelawCore, coreStatus, world, app, color, center, zoom, setColor } = usePixelawProvider()
    const { viewPort: renderer } = pixelawCore
    const rendererContainerRef = useRef<HTMLDivElement | null>(null)
    const dialogContainerRef = useRef<HTMLDivElement | null>(null)


    const zoombasedAdjustment = useMemo(() => {
        return zoom > 3000 ? "1rem" : "-100%"
    }, [zoom])

    // Updating the URL
    useEffect(() => {
        const updateURL = () => {
            const queryParams = new URLSearchParams()
            queryParams.set("app", app ?? "")
            queryParams.set("center", `${center[0]},${center[1]}`)
            queryParams.set("zoom", zoom.toString())
            queryParams.set("color", color.toString())
            queryParams.set("world", world)
            const newSearch = `?${queryParams.toString()}`

            if (window.location.search !== newSearch) {
                window.history.replaceState(null, "", newSearch)
            }
        }
        updateURL()

    }, [app, center, zoom, color, world])


    // Handle viewport events
    useEffect(() => {

        const handleCellClick = (cell?: Coordinate) => {
            if (!dialogContainerRef || !dialogContainerRef.current) return

            // setClickedCell(cell)
            const interaction = pixelawCore.handleInteraction(cell)

            // Clear existing children (dialogs)
            clearDomChildren(dialogContainerRef.current)

            // It is possible the interaction has no dialog, like with "paint"
            // In this case, the onchain action is immediately performed
            if (interaction.dialog) {
                // Append the new dialog
                dialogContainerRef.current.appendChild(interaction.dialog)

                interaction.dialog.showModal()
            }
        }

        // pixelawCore.events.on("cellHovered", handleCellHover)
        pixelawCore.events.on("cellClicked", handleCellClick)

        return () => {
            // pixelawCore.events.off("cellHovered", handleCellHover)
            pixelawCore.events.off("cellClicked", handleCellClick)
        }
    }, [pixelawCore])


    useEffect(() => {
        if (coreStatus !== "ready") return

        renderer.setContainer(rendererContainerRef.current!)

    }, [coreStatus, renderer])

    return (
        <>
            <div ref={rendererContainerRef} style={{ width: "100%", height: "100%" }} />

            <div className={styles.colorpicker} style={{ bottom: zoombasedAdjustment }}>
                <SimpleColorPicker color={color} onColorSelect={setColor} />
            </div>

            <div className={styles.apps} style={{ left: zoombasedAdjustment }}>
                <Apps />
            </div>
            <div ref={dialogContainerRef}>
                <dialog>
                    <p>Dialog content goes here.</p>
                </dialog>
            </div>
        </>
    )

    //</editor-fold>
}

export default GamePage
