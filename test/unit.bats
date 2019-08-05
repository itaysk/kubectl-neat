#!/usr/bin/env bats
. src/kubectl-neat >/dev/null
. src/common.sh >/dev/null

# Testing detectOutput

@test "detect output - flag" {
    run detectOutput bar -o foo
    echo $output
    [ $output == "foo" ]
}

@test "detect output - shell var" {
    KUBECTL_OUTPUT=json run detectOutput bar
    echo $output
    [ $output == "json" ]
}

@test "detect output - flag and shell var" {
    KUBECTL_OUTPUT=json run detectOutput bar -o foo
    echo $output
    [ $output == "foo" ]
}

@test "detect output - default" {
    run detectOutput bar
    echo $output
    [ $output == "yaml" ]
}

# Testing detectOutputFlag

@test "output flag parsing - no args" {
    run detectOutputFlag
    [ -z $output ]
}

@test "output flag parsing - no output" {
    run detectOutputFlag foo bar
    [ -z $output ]
}

@test "output flag parsing - ojson" {
    run detectOutputFlag foo bar -ojson
    [ $output == "json" ]
}

@test "output flag parsing - oyaml" {
    run detectOutputFlag foo bar -oyaml
    [ $output == "yaml" ]
}

@test "output flag parsing - ofoo" {
    run detectOutputFlag foo bar -ofoo
    [ -z $output ]
}

@test "output flag parsing - o foo" {
    run detectOutputFlag foo bar -o foo
    [ $output == "foo" ]
}

@test "output flag parsing - o=foo" {
    run detectOutputFlag foo bar -o=foo
    [ $output == "foo" ]
}

@test "output flag parsing - output=foo" {
    run detectOutputFlag foo bar --output=foo
    [ $output == "foo" ]
}

@test "output flag parsing - output foo" {
    run detectOutputFlag foo bar --output foo
    [ $output == "foo" ]
}

# Testing detectDir

@test "detectDir - none" {
    run detectDir
    [ $output == $(pwd) ]
}

@test "detectDir - link" {
    local dir1=$(mktemp -d)
    local dir2=$(mktemp -d)
    local file="$dir1"/file
    local link="$dir2"/link

    touch "$file"
    ln -s "$file" "$link"
    run detectDir "$link"
    rm -rf "$dir1" "$dir2"
    [ $output == "$dir1" ]
}

@test "detectDir - file" {
    local dir1=$(mktemp -d)
    local file="$dir1"/file

    touch "$file"
    run detectDir "$file"
    rm -rf "$dir1"
    [ $output == "$dir1" ]
}

# Testing checkDependencies

@test "checkDependencies - all ok" {
    run checkDependencies
    [ "$status" -eq 0 ]
    echo $output
    [ "$output" = "" ]
}

@test "missing dependency" {
    backup=$(which jq)
    sudo mv "$backup" "${backup}_"
    run checkDependencies
    sudo mv "${backup}_" "$backup"
    [ "$status" -eq 1 ]
    [ "$output" = "at least one dependency is missing" ]
}