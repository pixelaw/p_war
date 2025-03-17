import { usePixelawProvider } from "@pixelaw/react"
import { useEffect, useRef } from "react"
import { ProposalList } from "@/components/Pwar/Proposal/ProposalList"
import { type Coordinate } from "@pixelaw/core"
import styles from "./PwarPage.module.css"

const PwarPage: React.FC = () => {
    // We still need the core PixeLAW functionality for the grid
    const { pixelawCore, coreStatus } = usePixelawProvider()
    const { viewPort: renderer } = pixelawCore
    const rendererContainerRef = useRef<HTMLDivElement | null>(null)

    // Handle Pwar-specific cell interactions
    useEffect(() => {
        const handlePwarCellClick = async (cell: Coordinate) => {
            // TODO: Implement Pwar-specific interaction logic here
            console.log("Pwar cell clicked:", cell)
            // This is where you'll add your custom contract interactions
        }

        // Set up event listeners
        pixelawCore.events.on("cellClicked", handlePwarCellClick)

        return () => {
            pixelawCore.events.off("cellClicked", handlePwarCellClick)
        }
    }, [pixelawCore])

    // Set up the renderer
    useEffect(() => {
        if (coreStatus !== "ready") return
        renderer.setContainer(rendererContainerRef.current!)
    }, [coreStatus, renderer])

    return (
        <div className={styles.pwarContainer}>
            {/* The pixel grid renderer */}
            <div ref={rendererContainerRef} className={styles.rendererContainer} />
            
            {/* Pwar-specific UI components */}
            <div className={styles.pwarInterface}>
                <ProposalList />
                {/* Add other Pwar-specific components here */}
            </div>
        </div>
    )
}

export default PwarPage
