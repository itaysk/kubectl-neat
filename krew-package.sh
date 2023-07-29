#!/usr/bin/env bash
# This script makes a platform specific krew package
# it assumes goreleaser had already run and created the archives and the checksums
# Arguments:
#   1. target os (`linux`/`darwin`)
#   2. target arch (`amd64`/`arm64`)
#   2. plugin name (rename the plugin in tests to avoid conflicts with existing installation)
#   3. path to goreleaser dist directory

os="$1"
arch="$2"
plugin="$3"
dir="$4"

sha256=$(grep "${os}_$arch" "$dir/checksums.txt" | cut -f1 -d ' ')
tmp="$dir/kubectl-${plugin}_${os}_${arch}.json"
yq r --tojson krew-template.yaml >"$tmp"
jq 'delpaths([path(.spec.platforms[] | select( .selector.matchLabels.os != $os or .selector.matchLabels.arch != $arch ))])' --arg os "$os" --arg arch "$arch" "$tmp" | sponge "$tmp"
jq '.metadata.name = $name' --arg name "$plugin" "$tmp" | sponge "$tmp"
jq 'setpath(path(.spec.platforms[] | select( .selector.matchLabels.os == $os and .selector.matchLabels.arch == $arch) | .sha256); $sha)' --arg os "$os" --arg arch "$arch" --arg sha "$sha256" "$tmp" | sponge "$tmp"
yq r --prettyPrint "$tmp" > "${tmp%.json}.yaml"
rm "$tmp"