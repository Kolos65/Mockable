#!/bin/sh

set -eo pipefail

export MOCKABLE_DEV=false
swift build

export MOCKABLE_DEV=true
swift test