#!/bin/sh
# Requires https://github.com/rust-lang/measureme/tree/master/summarize to be installed
set -eu

# TODO: use hyperfine?
# RUSTC=$(rustup which rustc) hyperfine -p 'cargo clean'  --show-output "$(rustup which cargo) check -q"

unset CARGO_TARGET_DIR
mkdir -p benchmarks

CARGO=$(rustup which cargo)
RUSTC=$(rustup which rustc)

# for n in 1; do
for n in 1 10 100 1000 10000; do

    ./add_deps.sh $n
    # for m in 1; do
    for m in 1 10 100; do

        ./add_functions.sh $m
        rm -rf target benchmarks/measure-*-*
        # TODO: measure codegen too?
        $CARGO rustc --quiet -- --emit=metadata -Zself-profile=benchmarks/measure-$n-$m
        time=$(summarize summarize benchmarks/measure-$n-$m/*.mm_profdata | grep 'Total cpu time:' | cut -d ' ' -f 4)
        echo '{"crates": "'"$n"'", "functions": "'"$m"'", "time": "'"$time"'"}' >> timings.json
    done
done

echo "Generated timings.json"
