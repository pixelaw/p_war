
export WORLD_ADDRESS=0x60916a73fe631fcba3b2a930e21c6f7bb2533ea398c7bfa75c72f71a8709fc2
export SERVER_PORT=3000
export STORAGE_DIR=/pixelaw/storage/$WORLD_ADDRESS/
export STORAGE_INIT_DIR=/pixelaw/storage_init/$WORLD_ADDRESS/

# Remove last line of startup (the tail that keeps running)
head -n -9 /pixelaw/scripts/startup.sh > temp && mv temp /pixelaw/scripts/startup.sh

# Startup
bash /pixelaw/scripts/startup.sh

# build and prep
pushd build
sozo build
sozo migrate plan
sozo migrate apply
popd


# shutdown nicely
pm2 stop /pixelaw/core/docker/ecosystem.config.js

# Zip the databases
pushd $STORAGE_DIR
zip -1 -r katana_db.zip katana_db
zip -1 torii.sqlite.zip torii.sqlite

# Move them to the init dir
mv katana_db.zip $STORAGE_INIT_DIR
mv torii.sqlite.zip $STORAGE_INIT_DIR
popd