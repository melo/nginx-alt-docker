#!/bin/sh

set -xe

nerdctl pull nginx:mainline-alpine
nerdctl build                                             \
  --build-arg BASE='nginx:mainline-alpine'                \
  --label 'maintainer=Pedro Melo <melo@simplicidade.org>' \
  --platform=linux/amd64,linux/arm64                      \
  -t melopt/nginx-alt                                     \
  .

nerdctl build                                             \
  --build-arg BASE='cgr.dev/chainguard/nginx'             \
  --label 'maintainer=Pedro Melo <melo@simplicidade.org>' \
  --platform=linux/amd64,linux/arm64                      \
  -t melopt/nginx-alt:chainguard                          \
  .

nerdctl push                                              \
  --platform=linux/amd64,linux/arm64                      \
  melopt/nginx-alt


nerdctl push                                              \
  --platform=linux/amd64,linux/arm64                      \
  melopt/nginx-alt:chainguard
