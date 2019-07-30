#! /bin/bash

os="$1" # `linux`/`darwin`
plugin="$2" # rename the plugin in tests to avoid conflicts with existing installation
dir="$3"

sed "s/name: neat/name: $plugin/" kubectl-neat.yaml >"$dir"/"$plugin".yaml
tar -czf "$dir"/kubectl-neat.tar.gz dist
sha256=$(sha256sum "$dir"/kubectl-neat.tar.gz | awk '{print $1}')
if [ "$os" = "Darwin" ]; then
    sed -i '' "s/sha256:.*/sha256: ${sha256}/" "$dir"/"$plugin".yaml
fi
if [ "$os" = "Linux" ]; then
    sed -i "s/sha256:.*/sha256: ${sha256}/" "$dir"/"$plugin".yaml
fi
