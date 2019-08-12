#!/bin/sh

VERSION=$(grep -e "ARG ZAPROXY_VERSION=" Dockerfile)
VERSION="${VERSION#ARG ZAPROXY_VERSION=\"}"
VERSION="${VERSION%\"}"
echo "Tagging version ${VERSION}"
docker tag "${DOCKER_USERNAME}/zaproxy:latest" "${DOCKER_USERNAME}/zaproxy:${VERSION}"
