#!/usr/bin/env bats

@test "krew install" {
    dir=$(mktemp -d)
    plugin="neat2"
    runtime_os=$(uname -s | tr '[:upper:]' '[:lower:]')
    ./krew-package.sh "$runtime_os" "$plugin" "$dir"
    kubectl krew install --manifest="$dir/kubectl-${plugin}_${runtime_os}.yaml" --archive="$dir/kubectl-neat_$runtime_os.tar.gz"

    run kubectl "$plugin" svc kubernetes -oyaml

    kubectl krew remove "$plugin"
    rm -rf "$dir"
    [ "$status"  -eq 0 ]
    # just making sure it's the output for the service, not trying to check for correctness
    [ "${lines[1]}" = "kind: Service" ]
}