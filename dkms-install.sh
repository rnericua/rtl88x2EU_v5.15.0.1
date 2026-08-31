#!/bin/bash
set -euo pipefail
if [[ ${EUID} -ne 0 ]]; then
  echo "Need superuser privileges" >&2
  exit 1
fi
DRV_NAME=rtl88x2eu
DRV_VERSION=5.15.0.1
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
rm -rf "/usr/src/${DRV_NAME}-${DRV_VERSION}"
mkdir -p "/usr/src/${DRV_NAME}-${DRV_VERSION}"
cp -a "${SRC_DIR}/." "/usr/src/${DRV_NAME}-${DRV_VERSION}/"
dkms add -m "${DRV_NAME}" -v "${DRV_VERSION}"
dkms build -m "${DRV_NAME}" -v "${DRV_VERSION}"
dkms install -m "${DRV_NAME}" -v "${DRV_VERSION}"
echo "Installed ${DRV_NAME}/${DRV_VERSION}"
