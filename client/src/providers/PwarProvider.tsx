import { createContext, type ReactNode, useContext, useEffect, useState } from "react"
import type { Coordinate } from "@pixelaw/core"
import { type BaseWallet } from "@pixelaw/core"
import { Contract, RpcProvider, constants } from "starknet"

// Define types based on the Cairo contract
type DefaultParameters = {
    position: Coordinate
    color: number
    for_player: number
    for_system: number
}

// Modify action types to match contract functions
type PwarAction = {
    type: "INIT" | "INTERACT"
    params?: DefaultParameters
}

export type IPwarContext = {
    pwarStatus: "uninitialized" | "ready" | "error"
    wallet: BaseWallet | null
    selectedUnit: string | null
    selectedPosition: Coordinate | null
    setWallet: (wallet: BaseWallet | null) => void
    setSelectedUnit: (unit: string | null) => void
    setSelectedPosition: (position: Coordinate | null) => void
    handlePwarAction: (action: PwarAction) => Promise<void>
}

export const PwarContext = createContext<IPwarContext | undefined>(undefined)

// Add this helper function at the top of the file
const formatAddress = (address: string): string => {
    // Remove '0x' if present and pad to 64 characters
    return '0x' + address.replace('0x', '').padStart(64, '0')
}

const checkNetwork = async (provider: RpcProvider) => {
    try {
        const chainId = await provider.getChainId()
        console.log("Connected to network with chainId:", chainId)
        return true
    } catch (error) {
        console.error("Failed to connect to network:", error)
        return false
    }
}

const sepoliaProvider = new RpcProvider({ nodeUrl: constants.NetworkName.SN_SEPOLIA });
// const myProvider = new RpcProvider({ nodeUrl: constants.NetworkName.SN_MAIN });

export const PwarProvider = ({ children }: { children: ReactNode }) => {
    const [pwarContract, setPwarContract] = useState<Contract | null>(null)
    
    const [contextValues, setContextValues] = useState<IPwarContext>({
        pwarStatus: "uninitialized",
        wallet: null,
        selectedUnit: null,
        selectedPosition: null,
        setWallet: (wallet: BaseWallet | null) => {
            setContextValues(prev => ({ ...prev, wallet }))
        },
        setSelectedUnit: (unit: string | null) => {
            setContextValues(prev => ({ ...prev, selectedUnit: unit }))
        },
        setSelectedPosition: (position: Coordinate | null) => {
            setContextValues(prev => ({ ...prev, selectedPosition: position }))
        },
        handlePwarAction: async (action: PwarAction) => {
            if (!pwarContract || !contextValues.wallet) {
                console.error("Contract or wallet not initialized")
                return
            }

            try {
                switch (action.type) {
                    case "INIT":
                        await pwarContract.invoke("init", [])
                        break
                    case "INTERACT":
                        if (!action.params) {
                            throw new Error("Parameters required for interact")
                        }
                        await pwarContract.invoke("interact", [action.params])
                        break
                    default:
                        throw new Error(`Unknown action type: ${action.type}`)
                }
            } catch (error) {
                console.error("Failed to execute Pwar action:", error)
                throw error
            }
        }
    })

    useEffect(() => {
        const initializePwar = async () => {
            try {
                // Configure provider with better options
                
                const networkAvailable = await checkNetwork(sepoliaProvider)
                if (!networkAvailable) {
                    throw new Error("Cannot connect to Starknet network")
                }
                
                const contractAddress = formatAddress("0x05665ef6b299012bf20afdeec1d413ced884bc698567a4c17fcebe841dde9197")
                console.log("Attempting to connect to contract at:", contractAddress)
                
                try {
                    const { abi } = await sepoliaProvider.getClassAt(contractAddress)
                    if (!abi) {
                        throw new Error("No ABI found for contract")
                    }

                    const contract = new Contract(abi, contractAddress, sepoliaProvider)
                    setPwarContract(contract)
                    setContextValues(prev => ({ ...prev, pwarStatus: "ready" }))
                } catch (error: unknown) {
                    // Type guard for error
                    if (error instanceof Error && error.message.includes("Contract not found")) {
                        throw new Error(`Contract not found at address ${contractAddress}`)
                    }
                    throw error
                }
            } catch (error) {
                console.error("Failed to initialize Pwar:", error)
                setContextValues(prev => ({ 
                    ...prev, 
                    pwarStatus: "error",
                    error: error instanceof Error ? error.message : 'Unknown error'
                }))
            }
        }

        initializePwar()
    }, [])

    return (
        <PwarContext.Provider value={contextValues}>
            {contextValues.pwarStatus === "error" ? (
                <div>Error: Failed to initialize Pwar</div>
            ) : (
                children
            )}
        </PwarContext.Provider>
    )
}

export const usePwarProvider = (): IPwarContext => {
    const context = useContext(PwarContext)
    if (!context) throw new Error("usePwarProvider can only be used within a PwarProvider")
    return context
}
