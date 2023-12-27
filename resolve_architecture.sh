#!/bin/bash

arch=$(uname -m)

case $arch in
  x86_64) echo "amd64";;
  aarch64) echo "arm64";;
  *)      ${arch};;
esac