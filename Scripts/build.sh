#!/bin/sh

set -eo pipefail

export MOCKABLE_DEV=false
swift build --configuration release