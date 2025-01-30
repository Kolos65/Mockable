#!/bin/bash

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source $ROOT_DIR/Scripts/utils.sh

# When --vm is passed, the build and test commands are executed in a virtualized container.
if [[ " $* " == *" --vm "* ]]; then
    CONTAINER_RUNTIME=$(get_container_runtime)
    $CONTAINER_RUNTIME run --rm \
        --volume "$ROOT_DIR:/package" \
        --workdir "/package" \
        -e MOCKABLE_TEST=$MOCKABLE_TEST \
        swiftlang/swift:nightly-6.1-focal \
        /bin/bash -c \
        "swift build --build-path ./.build/linux"
else
    swift build --package-path "$ROOT_DIR"
    swift test --package-path "$ROOT_DIR"
fi
