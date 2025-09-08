#!/usr/bin/env bash
set -euo pipefail

# 1) Configuration
VERSION="1.2.0"
# Known SHA256 sums for each supported platform
declare -A SHASUMS=(
  ["x86_64-linux-gnu"]="aee9f2f21ebc90cc1dbfb20ee93d3aa03d325127a8e3f7f91dd02c5a9e0a7b25"
  ["aarch64-linux-gnu"]="4e320240586ecc5cdfdcff0488647879077027506c68c919ccdd2754642d0fbb"
)

# 2) Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)     PLATFORM="x86_64-linux-gnu" ;;
  aarch64|arm64) PLATFORM="aarch64-linux-gnu" ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

EXPECTED_SHA="${SHASUMS[$PLATFORM]}"
if [ -z "$EXPECTED_SHA" ]; then
  echo "No checksum known for platform: $PLATFORM" >&2
  exit 1
fi

FILE="edit-${VERSION}-${PLATFORM}.tar.zst"
URL="https://github.com/microsoft/edit/releases/download/v${VERSION}/${FILE}"

# 3) Prep temp dir & cleanup
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# 4) Ensure deps
if ! command -v curl >/dev/null || ! command -v zstd >/dev/null; then
  echo "Installing dependencies (curl, zstd) ..."
  sudo apt-get update
  sudo apt-get install -y curl zstd
fi

# 5) Download
echo "Downloading $FILE …"
curl -L --fail "$URL" -o "$TMPDIR/$FILE"

# 6) Verify checksum
echo "Verifying checksum …"
echo "${EXPECTED_SHA}  $TMPDIR/$FILE" | sha256sum -c -

# 7) Extract only the 'edit' binary into /usr/local/bin
echo "Extracting binary to /usr/local/bin …"
sudo mkdir -p /usr/local/bin
sudo tar --transform 's:.*/::' -I zstd -xvf "$TMPDIR/$FILE" -C /usr/local/bin

# 8) Done
echo
echo "✔ edit v${VERSION} installed to /usr/local/bin/edit"
echo "Run 'edit --help' to get started."
