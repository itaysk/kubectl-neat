#!/usr/bin/env bats

@test "krew install" {
    os=$(uname -s)
    dir=$(mktemp -d)
    # rename the plugin to avoid conflicts with existing installation
    plugin="neat2"
    sed "s/name: neat/name: "$plugin"/" kubectl-neat.yaml >"$dir"/"$plugin".yaml
	tar -czf "$dir"/kubectl-neat.tar.gz dist
	sha256=$(sha256sum "$dir"/kubectl-neat.tar.gz | awk '{print $1}')
    if [ "$os" = "Darwin" ]; then
	    sed -i '' "s/sha256:.*/sha256: "${sha256}"/" "$dir"/"$plugin".yaml
    fi
    if [ "$os" = "Linux" ]; then
	    sed -i "s/sha256:.*/sha256: "${sha256}"/" "$dir"/"$plugin".yaml
    fi
	kubectl krew install --manifest="$dir"/"$plugin".yaml --archive="$dir"/kubectl-neat.tar.gz
    
    run kubectl "$plugin" svc kubernetes
    
    kubectl krew remove "$plugin"
    rm -rf "$dir"
    [ "$status"  -eq 0 ]
    # just making sure it's the output for the service, not trying to check for correctness
    [ "${lines[1]}" = "kind: Service" ]
}