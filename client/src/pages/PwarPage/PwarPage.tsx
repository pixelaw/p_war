import { usePixelawProvider } from "@pixelaw/react"
import { useEffect, useRef } from "react"
import { ProposalList } from "@/components/Pwar/Proposal/ProposalList"
import { Position, type Coordinate } from "@pixelaw/core"
import styles from "./PwarPage.module.css"
import { PwarProvider, usePwar } from "@/Provider/PwarProvider"

// The content of the Pwar page, wrapped by PwarProvider
const PwarPageContent: React.FC = () => {
    // We still need the core PixeLAW functionality for the grid
    const { pixelawCore, coreStatus } = usePixelawProvider()
    const { viewPort: renderer } = pixelawCore
    const rendererContainerRef = useRef<HTMLDivElement | null>(null)
    
    // Get the contract service from the PwarProvider
    const { contractService } = usePwar();
    
    // Handle Pwar-specific cell interactions
    useEffect(() => {
        const handlePwarCellClick = async (cell: Coordinate) => { //Position, Coordinate or Cell
            // TODO: Implement Pwar-specific interaction logic here
            console.log("Pwar cell clicked:", cell)
            const wallet = pixelawCore.getWallet() as DojoWallet
            const account = wallet.getAccount()
            const provider = pixelawCore.engine["dojoSetup"].provider
            const world = setupWorld(pixelawCore.engine["dojoSetup"].provider)
            console.log(`Loading world ${world}`)

            // try {
            //     return await provider.execute(
            //         account,
            //         {contractAddress: "0x00af6854b90b294223050a2bb369e7e4ca386fe251a5f6ccbdcdc335c9e7b052",
            //         entrypoint: "interact",
            //         calldata: [
            //             "0x1",
            //             "0x1",
            //             "0x1",
            //             254, 255,
            //             255
            //     ]},
            //     );
            // } catch (error) {
            //     console.error(error);
            //     throw error;
            // }
            
            // Use the contract service to interact with the pixel
            if (contractService) {
                try {
                    const result = await contractService.interact(cell);
                    console.log("Interaction result:", result);
                } catch (error) {
                    console.error("Failed to interact with pixel:", error);
                }
            }
        }

        // Set up event listeners
        pixelawCore.events.on("cellClicked", handlePwarCellClick)

        return () => {
            pixelawCore.events.off("cellClicked", handlePwarCellClick)
        }
    }, [pixelawCore, contractService])

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

// Wrap the PwarPage content with the PwarProvider
const PwarPage: React.FC = () => {
    return (
        <PwarProvider defaultGameId={1}>
            <PwarPageContent />
        </PwarProvider>
    )
}

export default PwarPage
