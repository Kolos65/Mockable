#!/bin/bash

set -eo pipefail

swift build
swift test