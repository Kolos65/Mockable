#!/bin/sh

set -eo pipefail

export MOCKABLE_DEV=true
swift build
swift test