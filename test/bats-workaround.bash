# run2 reimplements the "run" helper function from bats in order to make it handle stdout and stderr seperately
# issue tracked: https://github.com/bats-core/bats-core/issues/47
# original function: https://github.com/bats-core/bats-core/blob/90ce85884ca89b48960194b3d3bf6b816285e053/lib/bats-core/test_functions.bash#L32:L45
function run2() {
    local origFlags="$-"
    set +eETx
    local origIFS="$IFS"
    # 'output', 'status', 'lines' are global variables available to tests.
    local tmperr=$(mktemp)
    stdout="$("$@" 2>"$tmperr")"
    # shellcheck disable=SC2034
    status="$?"
    # shellcheck disable=SC2034
    stderr="$(cat <"$tmperr")"
    rm "$tmperr"
    # shellcheck disable=SC2034,SC2206
    IFS=$'\n' stdoutLines=($stdout)
    # shellcheck disable=SC2034,SC2206
    IFS=$'\n' stderrLines=($stderr)
    IFS="$origIFS"
    set "-$origFlags"
}