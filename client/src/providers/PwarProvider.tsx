import { createContext, type ReactNode, useContext, useEffect, useState } from "react"
import type { Coordinate } from "@pixelaw/core"
import { type BaseWallet } from "@pixelaw/core"
import { Contract, RpcProvider } from "starknet"

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
                const provider = new RpcProvider({ nodeUrl: "http://127.0.0.1:5050" })
                
                // This should be the address where your actions.cairo contract is deployed
                const contractAddress = "0x1f04b61e71f2afa9610c422db007807f73ebad6b4c069e72bb6e22ff032a93c"
                const { abi } = await provider.getClassAt(contractAddress)
                
                if (!abi) {
                    throw new Error("No ABI found for contract")
                }

                const contract = new Contract(abi, contractAddress, provider)
                setPwarContract(contract)
                setContextValues(prev => ({ ...prev, pwarStatus: "ready" }))
            } catch (error) {
                console.error("Failed to initialize Pwar:", error)
                setContextValues(prev => ({ ...prev, pwarStatus: "error" }))
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
