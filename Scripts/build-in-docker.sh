#!/bin/sh

set -eo pipefail

docker run --rm \
    --volume "$(pwd):/package" \
    --workdir "/package" \
    -e MOCKABLE_DEV='false' \
    swift:5.9 \
    /bin/bash -c \
    "swift package fetch && swift build --configuration release"