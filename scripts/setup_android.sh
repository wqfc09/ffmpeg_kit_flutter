#!/bin/bash
set -euo pipefail

RELEASE_OWNER="${FFMPEG_KIT_RELEASE_OWNER:-wqfc09}"
RELEASE_REPO="${FFMPEG_KIT_RELEASE_REPO:-ffmpeg-kit}"
RELEASE_TAG="${FFMPEG_KIT_RELEASE_TAG:-test}"
ASSET_NAME="${FFMPEG_KIT_ANDROID_ASSET:-ffmpegkit-android-aar.zip}"

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
curl -fL "${ASSET_URL}" -o "${TMP_DIR}/android.zip"

unzip -q "${TMP_DIR}/android.zip" -d "${TMP_DIR}/unzipped"
AAR_PATH="$(find "${TMP_DIR}/unzipped" -type f -name '*.aar' | head -n 1)"

if [ -z "${AAR_PATH}" ]; then
  echo "No .aar found in ${ASSET_NAME}"
  exit 1
fi

cp -f "${AAR_PATH}" "${LIBS_DIR}/ffmpeg-kit-custom.aar"
echo "Prepared: ${LIBS_DIR}/ffmpeg-kit-custom.aar"
