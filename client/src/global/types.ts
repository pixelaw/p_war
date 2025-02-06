
/// Manifest types
type ImplType = {
    type: "impl"
    name: string
    interface_name: string
}

type BaseType = {
    name: string
    type: string
}

type FunctionType = {
    type: "function"
    name: string
    inputs: BaseType[]
    outputs: { type: string }[]
    state_mutability: "external" | "view"
}

export type InterfaceType = {
    type: "interface"
    name: string
    items: FunctionType[]
}

type StructType = {
    type: "struct"
    name: string
    members: BaseType[]
}

export type EnumType = {
    type: "enum"
    name: string
    variants: BaseType[]
}

type EventMember = {
    name: string
    type: string
    kind: string
}

type EventStructType = {
    type: "event"
    name: string
    kind: "struct"
    members: EventMember[]
}

type EventEnumType = {
    type: "event"
    name: string
    kind: "enum"
    variants: EventMember[]
}

export type AbiType = (
    | ImplType
    | InterfaceType
    | StructType
    | EnumType
    | FunctionType
    | EventStructType
    | EventEnumType
)[]

type ComputedValueEntryPoint = {
    contract: string
    entrypoint: string
    model?: string
}

type Contract = {
    name: string
    address?: string
    class_hash: string
    abi: AbiType
    reads: string[]
    writes: string[]
    computed: ComputedValueEntryPoint[]
}

type Class = {
    name: string
    class_hash: string
    abi: AbiType
}

type Member = {
    name: string
    type: string
    key: boolean
}

type Model = {
    name: string
    members: Member[]
    class_hash: string
    abi: AbiType
}

export type Manifest = {
    world: Contract
    executor: Contract
    base: Class
    contracts: Contract[]
    models: Model[]
}

export type Position = {
    x: number
    y: number
}
