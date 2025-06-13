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
asdf install dojo
```

## Install scarb

```
asdf plugin add scarb
asdf install scarb 2.7.0
```

And after moving into contracts directory, the versions for these libs are set in the .tool-versions file.

## Running Locally

### Clone the Repository

To clone this repository with all submodules, run:

```bash
git clone https://github.com/pixelaw/pwar.git
cd pwar
```

### Locally running pwar

**Pwar** runs inside the [PixeLAW Core World](https://github.com/pixelaw/core), which is why we initally have to spin up an empty PixeLAW world.

For this we have built a docker container that builds the PixeLAW world:

```bash
cd client
docker compose up --build
```

This docker container builds the PixeLAW world and runs Torii and Katana.

Find `client/docker-compose.yml` for more information.

Feel free to:

```bash
docker exec -it pixelaw-core bash
klog
```

To find katana logs or `tlog` for torii logs.

### Deploy pwar contracts

Once we initialised the PixeLAW world and its contracts, we now have to deploy the pwar contracts.

```bash
cd contracts
sozo build
sozo migrate
```


### Run the client

In order to spin up the pwar client run:

```bash
cd client
pnpm install
pnpm run dev
```

### Build on top of pwar

If you would like to make changes feel free to raise a PR. Changes for the client inside `client`, and changes for the contracts inside `contracts`. Be sure to test the contracts.

For that you will have to repeat to

```bash
sozo build --typescript
sozo migrate
```

Copy the generated typescript files in `contracts/bindings/typescript` (i.e. `contracts.gen.ts` and `models.gen.ts` into `client/src/config`.  

Lastly you will also have to copy the contract section inside `contracts/manifest_dev.json` into `client/src/config/manifest.contracts.ts` (be sure to only replace the contracts array).

For any questions reach out to us in our Discord or Twitter.
