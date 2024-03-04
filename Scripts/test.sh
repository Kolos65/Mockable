#!/bin/sh

set -eo pipefail

export MOCKABLE_DEV=true
swift test