#!/usr/bin/env bats

load bats-workaround.bash

function exercise_run2() {
  echo "out1"
  echo "err1" >&2
  echo "out2"
  echo "err2" >&2
  return 42
}

@test "run2" {
  run2 exercise_run2
  [[ "$status" -eq 42 ]]
  [[ "$stdout" == "out1
out2" ]]
  [[ "$stderr" == "err1
err2" ]]
  [[ "${stdoutLines[1]}" == "out2" ]]
  [[ "${stderrLines[1]}" == "err2" ]] 
}