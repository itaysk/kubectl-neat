#! /bin/bash
# This script makes a platform specific krew package
# it assumes goreleaser had already run and created the archives and the checksums
# Arguments:
#   1. target os (`linux`/`darwin`)
#   2. plugin name (rename the plugin in tests to avoid conflicts with existing installation)
#   3. path to goreleaser dist directory

os="$1"
plugin="$2"
dir="$3"

sha256=$(grep "$os" "$dir/checksums.txt" | cut -f1 -d ' ')
tmp="$dir/kubectl-${plugin}_${os}.json"
yq r --tojson krew-template.yaml >"$tmp"
jq 'delpaths([path(.spec.platforms[] | select( .selector.matchLabels.os != $os ))])' --arg os "$os" "$tmp" | sponge "$tmp"
jq '.metadata.name = $name' --arg name "$plugin" "$tmp" | sponge "$tmp"
jq 'setpath(path(.spec.platforms[] | select( .selector.matchLabels.os == $os ) | .sha256); $sha)' --arg os "$os" --arg sha "$sha256" "$tmp" | sponge "$tmp"
yq r --prettyPrint "$tmp" > "${tmp%.json}.yaml"
rm "$tmp"