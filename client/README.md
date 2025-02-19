# PixelAW.JS

## Getting started
```
git clone git@github.com:pixelaw/vanilla.git
cd vanilla
```

# Then initialize/update submodules (pixelaw.js):
```
git submodule init
git submodule update
```

# Merging newest changes from `https://github.com/pixelaw/vanilla`
```
cd client
git fetch upstream
git rebase upstream/main
```


# repo structure
client/
└── pixelaw.js/
    ├── package.json          # Main package.json for the monorepo
    ├── lerna.json            # Lerna configuration for managing packages
    ├── biome.json            # Biome configuration for linting and formatting
    ├── packages/
    │   ├── core/
    │   │   ├── package.json  # Package.json for @pixelaw/core
    │   │   └── src/          # Source code for @pixelaw/core
    │   ├── core-dojo/
    │   │   ├── package.json  # Package.json for @pixelaw/core-dojo
    │   │   └── src/          # Source code for @pixelaw/core-dojo
    │   └── ...               # Other packages
    └── examples/             # Example applications or usage
