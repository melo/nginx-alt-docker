#!/bin/sh

docker buildx create --use
docker buildx build --pull --platform=linux/amd64,linux/arm64 -t melopt/nginx-alt --push .
