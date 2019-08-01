#! /bin/bash
# This script makes a platform specific krew package
# Arguments:
#   1. target os (`linux`/`darwin`)
#   2. plugin name (rename the plugin in tests to avoid conflicts with existing installation)
#   3. directory where to create artifacts

os="$1"
plugin="$2"
dir="$3"

tar -czf "$dir/kubectl-neat_$os.tar.gz" "dist/$os"
sha256=$(sha256sum "$dir/kubectl-neat_$os.tar.gz" | awk '{print $1}')
tmp="$dir/kubectl-${plugin}_${os}.json"
yq r --tojson krew-template.yaml >"$tmp"
jq 'delpaths([path(.spec.platforms[] | select( .selector.matchLabels.os != $os ))])' --arg os "$os" "$tmp" | sponge "$tmp"
jq '.metadata.name = $name' --arg name "$plugin" "$tmp" | sponge "$tmp"
jq 'setpath(path(.spec.platforms[] | select( .selector.matchLabels.os == $os ) | .sha256); $sha)' --arg os "$os" --arg sha "$sha256" "$tmp" | sponge "$tmp"
yq r "$tmp" > "${tmp%.json}.yaml"
rm "$tmp"