#!/bin/sh

set -xe

nerdctl pull nginx:mainline-alpine
nerdctl build                                             \
  --label 'maintainer=Pedro Melo <melo@simplicidade.org>' \
  --platform=linux/amd64,linux/arm64                      \
  -t melopt/nginx-alt                                     \
  .
nerdctl push                                              \
  --platform=linux/amd64,linux/arm64                      \
  melopt/nginx-alt

