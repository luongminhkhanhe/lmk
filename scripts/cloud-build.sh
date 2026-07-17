#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT/output"
exec > >(tee "$ROOT/output/build.log") 2>&1

echo "=== LMK RK3229 cloud build ==="
date -u
uname -a
echo "RELEASE=${RELEASE:-bookworm}"
echo "BRANCH=${BRANCH:-legacy}"

sudo apt-get update
sudo apt-get install -y git curl wget rsync bc bison flex build-essential \
  gcc-arm-linux-gnueabihf device-tree-compiler libssl-dev libncurses-dev \
  python3 python3-pip qemu-user-static binfmt-support debootstrap \
  parted dosfstools e2fsprogs zip unzip xz-utils jq aria2 pv

echo "=== Inspect original DTB ==="
dtc -I dtb -O dts \
  -o "$ROOT/output/txcz-rk3229-v2.3-original.dts" \
  "$ROOT/board/txcz-rk3229-v2.3-original.dtb"

echo "=== Clone RK322x community build framework ==="
git clone --depth=1 https://github.com/paolosabatino/armbian-build.git "$ROOT/build"

cd "$ROOT/build"

echo "=== Start image build ==="
./compile.sh \
  BOARD=rk322x-box \
  BRANCH="${BRANCH:-legacy}" \
  RELEASE="${RELEASE:-bookworm}" \
  BUILD_MINIMAL=yes \
  BUILD_DESKTOP=no \
  KERNEL_CONFIGURE=no \
  COMPRESS_OUTPUTIMAGE=sha,img

echo "=== Collect output ==="
find output/images -maxdepth 1 -type f -print 2>/dev/null || true
cp -av output/images/* "$ROOT/output/" 2>/dev/null || true

cd "$ROOT/output"
sha256sum * > SHA256SUMS.txt 2>/dev/null || true

echo "=== Build finished ==="
echo "IMPORTANT: image is experimental and must not be flashed to raw NAND before review."
