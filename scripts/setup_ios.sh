#!/bin/bash
set -euo pipefail

RELEASE_OWNER="${FFMPEG_KIT_RELEASE_OWNER:-wqfc09}"
RELEASE_REPO="${FFMPEG_KIT_RELEASE_REPO:-ffmpeg_kit_flutter}"
RELEASE_TAG="${FFMPEG_KIT_IOS_RELEASE_TAG:-${FFMPEG_KIT_RELEASE_TAG:-ios}}"
ASSET_NAME="${FFMPEG_KIT_IOS_ASSET:-ffmpegkit-ios-xcframework.zip}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
FRAMEWORK_DIR="${ROOT_DIR}/ios/Frameworks"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

mkdir -p "${FRAMEWORK_DIR}"
rm -rf "${FRAMEWORK_DIR:?}"/*

ASSET_URL="https://github.com/${RELEASE_OWNER}/${RELEASE_REPO}/releases/download/${RELEASE_TAG}/${ASSET_NAME}"
echo "Downloading iOS prebuilt from: ${ASSET_URL}"
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
  *)
    echo "Unsupported iOS asset type: ${ASSET_NAME}"
    exit 1
    ;;
esac

FOUND=0
while IFS= read -r -d '' xcf; do
  cp -R "${xcf}" "${FRAMEWORK_DIR}/"
  FOUND=1
done < <(find "${TMP_DIR}/unzipped" -type d -name '*.xcframework' -print0)

if [ "${FOUND}" -ne 1 ]; then
  echo "No .xcframework found in ${ASSET_NAME}"
  exit 1
fi

echo "Prepared xcframeworks under: ${FRAMEWORK_DIR}"
