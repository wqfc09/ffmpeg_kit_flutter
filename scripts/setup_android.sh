#!/bin/bash
set -euo pipefail

RELEASE_OWNER="${FFMPEG_KIT_RELEASE_OWNER:-wqfc09}"
RELEASE_REPO="${FFMPEG_KIT_RELEASE_REPO:-ffmpeg_kit_flutter}"
RELEASE_TAG="${FFMPEG_KIT_ANDROID_RELEASE_TAG:-${FFMPEG_KIT_RELEASE_TAG:-android}}"
ASSET_NAME="${FFMPEG_KIT_ANDROID_ASSET:-ffmpegkit-android-aar.tar.gz}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIBS_DIR="${ROOT_DIR}/android/libs"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

mkdir -p "${LIBS_DIR}"

ASSET_URL="https://github.com/${RELEASE_OWNER}/${RELEASE_REPO}/releases/download/${RELEASE_TAG}/${ASSET_NAME}"
echo "Downloading Android prebuilt from: ${ASSET_URL}"
ASSET_PATH="${TMP_DIR}/${ASSET_NAME}"
curl -fL "${ASSET_URL}" -o "${ASSET_PATH}"

mkdir -p "${TMP_DIR}/unzipped"
case "${ASSET_NAME}" in
  *.zip)
    unzip -q "${ASSET_PATH}" -d "${TMP_DIR}/unzipped"
    ;;
  *.tar.gz|*.tgz)
    tar -xzf "${ASSET_PATH}" -C "${TMP_DIR}/unzipped"
    ;;
  *.aar)
    cp -f "${ASSET_PATH}" "${TMP_DIR}/unzipped/"
    ;;
  *)
    echo "Unsupported Android asset type: ${ASSET_NAME}"
    exit 1
    ;;
esac

AAR_PATH="$(find "${TMP_DIR}/unzipped" -type f -name '*.aar' | head -n 1)"

if [ -z "${AAR_PATH}" ]; then
  echo "No .aar found in ${ASSET_NAME}"
  exit 1
fi

cp -f "${AAR_PATH}" "${LIBS_DIR}/ffmpeg-kit-custom.aar"
echo "Prepared: ${LIBS_DIR}/ffmpeg-kit-custom.aar"
