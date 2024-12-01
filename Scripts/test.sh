#!/bin/sh

set -eo pipefail

swift build
swift test