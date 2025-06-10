# P/WAR Contracts

This directory contains the smart contracts for the P/WAR project built with Cairo and Dojo.

## Prerequisites

Make sure you have the following tools installed:

- [asdf](https://asdf-vm.com/)
- [scarb](https://docs.swmansion.com/scarb/)
- [dojo](https://github.com/dojoengine/dojo)

The required versions are specified in the `.tool-versions` file in this directory.

## Setup

1. Install the dependencies:

```bash
asdf install
```

## Building

To build the contracts:

```bash
sozo build
```

To generate TypeScript bindings:

```bash
sozo build --typescript-v2
```

The TypeScript bindings will be generated in the bindings/typescript directory.

## Deploying

To deploy the contracts locally:

```bash
sozo migrate
```

This will deploy the contracts to your local Katana instance.