#!/bin/bash

ARCH=$(uname -m)

for i in "$@"; do
    case $i in
        --arch=*)
            ARCH="${i#*=}"
            ;;
        *)
            ;;
    esac
done

echo "Building for architecture: $ARCH"

case $ARCH in
    riscv64)
        CROSS_COMPILE="riscv64-unknown-elf-"
        TARGET="riscv64-unknown-linux-musl"
        ;;
    x86_64)
        CROSS_COMPILE="x86_64-unknown-elf-"
        TARGET="x86_64-unknown-linux-musl"
        ;;
    loongarch64)
        CROSS_COMPILE="loongarch64-unknown-elf-"
        TARGET="loongarch64-unknown-linux-musl"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

export CROSS_COMPILE
export HOSTCC="clang"
export CC="clang"
export CFLAGS="--target=$TARGET -fuse-ld=lld $CFLAGS"
export LD="ld.lld"
export AR="llvm-ar"
export NM="llvm-nm"
export RANLIB="llvm-ranlib"
export STRIP="llvm-strip"

make glenda_defconfig
make CROSS_COMPILE="$CROSS_COMPILE" HOSTCC="$HOSTCC" CC="$CC" LD="$LD" AR="$AR" NM="$NM" RANLIB="$RANLIB" STRIP="$STRIP" -j$(nproc)
make CROSS_COMPILE="$CROSS_COMPILE" HOSTCC="$HOSTCC" CC="$CC" LD="$LD" AR="$AR" NM="$NM" RANLIB="$RANLIB" STRIP="$STRIP" install
mkdir -p build
cp busybox build/busybox.elf