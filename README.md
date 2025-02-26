<picture>
<source media="(prefers-color-scheme: dark)" srcset="https://avatars.githubusercontent.com/u/140254228?s=200&v=4">  
<img alt="Dojo logo" align="right" width="100" src="https://avatars.githubusercontent.com/u/140254228?s=200&v=4">
</picture>

<a href="https://x.com/0xpixelaw">
<img src="https://img.shields.io/twitter/follow/0xpixelaw?style=social"/>
</a>
<a href="https://github.com/pixelaw/core">
<img src="https://img.shields.io/github/stars/pixelaw/core?style=social"/>
</a>

[![discord](https://img.shields.io/badge/join-PixeLAW-green?logo=discord&logoColor=white)](https://t.co/jKDjNbFdZ5)

# p/war

Contracts written in Cairo using Dojo to showcase a Pixel World with app interoperability. Its interoperability is made possible with core actions. Apps are any other contracts that are deployed to the Pixel World.

## Prerequisites

- [asdf](https://asdf-vm.com/)
- [scarb](https://docs.swmansion.com/scarb/)
- [dojo](https://github.com/dojoengine/dojo)

## Install asdf

Follow the asdf installation instructions.

## Install dojo

```
asdf plugin add dojo https://github.com/dojoengine/asdf-dojo
asdf install dojo 1.0.0-alpha.11
```

## Install scarb

```
asdf plugin add scarb
asdf install scarb 2.7.0
```

And after moving into contracts directory, the versions for these libs are set in the .tool-versions file.

## Running Locally

pnpm install
pnpm --filter @pixelaw/client run dev


## change made in pixelaw.js
export const StarknetChainProvider: React.FC<ChainProviderProps> = ({ children }) => {
    return (
        <StarknetConfig chains={[mainnet, devnet]} provider={publicProvider()} connectors={[]}>
            <ConnectorProvider>{children}</ConnectorProvider>
        </StarknetConfig>
    )
}
