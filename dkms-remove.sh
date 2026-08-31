#!/bin/bash
set -euo pipefail
if [[ ${EUID} -ne 0 ]]; then
  echo "Need superuser privileges" >&2
  exit 1
fi
DRV_NAME=rtl88x2eu
DRV_VERSION=5.15.0.1
if dkms status -m "${DRV_NAME}" -v "${DRV_VERSION}" >/dev/null 2>&1; then
  dkms remove -m "${DRV_NAME}" -v "${DRV_VERSION}" --all || true
fi
rm -rf "/usr/src/${DRV_NAME}-${DRV_VERSION}"
echo "Removed ${DRV_NAME}/${DRV_VERSION}"
