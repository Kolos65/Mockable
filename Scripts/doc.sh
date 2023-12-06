#!/bin/sh

export MOCKABLE_DEV=true
swift package \
 --allow-writing-to-directory ./docs \
 generate-documentation \
 --target Mockable \
 --output-path ./docs \
 --transform-for-static-hosting \
 --hosting-base-path Mockable