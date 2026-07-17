#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT/output"
exec > >(tee "$ROOT/output/build.log") 2>&1

echo "=== LMK RK3229 cloud build ==="
echo "RELEASE=${RELEASE:-bookworm}"
echo "BRANCH=${BRANCH:-current}"

sudo apt-get update
sudo update-binfmts --disable qemu-loongarch64 2>/dev/null || true
sudo rm -f /var/lib/binfmts/qemu-loongarch64 2>/dev/null || true
sudo apt-get remove -y qemu-user-binfmt qemu-user-static binfmt-support 2>/dev/null || true
sudo apt-get -f install -y

sudo apt-get install -y git curl wget rsync bc bison flex build-essential   gcc-arm-linux-gnueabihf device-tree-compiler libssl-dev libncurses-dev   python3 python3-pip debootstrap parted dosfstools e2fsprogs   zip unzip xz-utils jq aria2 pv

dtc -I dtb -O dts   -o "$ROOT/output/txcz-rk3229-v2.3-original.dts"   "$ROOT/board/txcz-rk3229-v2.3-original.dtb"

git clone --depth=1 https://github.com/paolosabatino/armbian-build.git "$ROOT/build"
cd "$ROOT/build"

./compile.sh   BOARD=rk322x-box   BRANCH="${BRANCH:-current}"   RELEASE="${RELEASE:-bookworm}"   BUILD_MINIMAL=yes   BUILD_DESKTOP=no   KERNEL_CONFIGURE=no   COMPRESS_OUTPUTIMAGE=sha,img

cp -av output/images/* "$ROOT/output/" 2>/dev/null || true
cd "$ROOT/output"
sha256sum * > SHA256SUMS.txt 2>/dev/null || true
