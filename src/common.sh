#! /bin/bash
set -e -o pipefail

# determine which output format to use (json/yaml)
function detectOutput() {
    local o
    o=$(detectOutputFlag "$@")
    if [ -n "$o" ]; then
        echo "$o"
        return
    fi
    if [ -n "$KUBECTL_OUTPUT" ]; then
        echo "$KUBECTL_OUTPUT"
        return
    fi 
    echo "yaml"
}

# look for a flag that resembles kubectl accepted output options
# e.g. -ojson; -o json; -o=json; --output josn; --output=json;
function detectOutputFlag() {
    local o
    while (( "$#" )); do
        case "$1" in
        -o=*|--output=*)
            o=${1#*=}
            break
            ;;
        -ojson|-oyaml)
            o=${1#-o}
            break
            ;;
        -o|--output)
            o="$2"
            break
            ;;
        *)
            shift
            ;;
        esac
    done
    echo "$o"
}

# get raw input, from Kubernetes API or from STDIN
function getInput() {
    if [ -n "$1" ]; then # if there are any arguments
        # in any case that the user didn't specify output as flag, we need to include a default
        # so we add another (perhaps redundant) output flag as the last flag (which will override any previously defined)
        kubectl get "$@" -o "$o" 
    else
        cat <&0
    fi
}

# verify that the required dependencies are present
function checkDependencies() {
    jq --version >/dev/null 2>&1 && \
    yq --version >/dev/null 2>&1 && \
    echo "test" | sponge >/dev/null 2>&1 && \
    true && return
    echo "at least one dependency is missing" >&2 && false
}