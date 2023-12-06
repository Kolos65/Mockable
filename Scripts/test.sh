#!/bin/sh

set -eo pipefail

export MOCKBALE_DEV=false
swift build

export MOCKBALE_DEV=true
swift test