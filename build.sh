#!/bin/bash

timestamp=`date +%s`
find -name "build.log.*" | sort -r | tail -n +3 | xargs rm
mv build.log build.log.$timestamp

export ARCH=arm64
export KBUILD_BUILD_USER=BuildUser
export KBUILD_BUILD_HOST=BuildHost
export PLATFORM_VERSION=10.0.0
export KBUILD_COMPILER_STRING="LLVM Clang 9.0"

GCC_ARM64_BIN_PATH=$HOME/Toolchain/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin
GCC_ARM32_BIN_PATH=$HOME/Toolchain/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin
CLANG_BIN_PATH=/usr/lib/llvm-10/bin

BUILD_CROSS_COMPILE=$GCC_ARM64_BIN_PATH/aarch64-none-linux-gnu-
BUILD_CROSS_COMPILE_ARM32=$GCC_ARM32_BIN_PATH/arm-none-linux-gnueabihf-
CLANG_CC=$CLANG_BIN_PATH/clang
GCC_CC="${BUILD_CROSS_COMPILE}gcc"
CLANG_LD=$CLANG_BIN_PATH/ld.lld
GCC_LD="${BUILD_CROSS_COMPILE}ld"
CLANG_LDLTO=$CLANG_BIN_PATH/ld.lld
GCC_LDLTO="${BUILD_CROSS_COMPILE}ld.gold"

CC=$GCC_CC
LD=$GCC_LD
LDLTO=$GCC_LDLTO

BUILD_JOB_NUMBER="$(nproc)"
# BUILD_JOB_NUMBER=1

OUTPUT_ZIP="g970f_kernel"
RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
OUT="${RDIR}/.build"
mkdir -p $OUT

KERNEL_DEFCONFIG=exynos9820-beyond0lte_defconfig

FUNC_BUILD_KERNEL()
{
	echo ""
	echo "=============================================="
	echo "START : FUNC_BUILD_KERNEL"
	echo "=============================================="
	echo ""
	echo "build common config="${KERNEL_DEFCONFIG}""
	echo "build model config=SM-G970F"

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			O=$OUT \
			CROSS_COMPILE="${BUILD_CROSS_COMPILE}" \
			CROSS_COMPILE_ARM32="${BUILD_CROSS_COMPILE_ARM32}" \
			$KERNEL_DEFCONFIG || exit -1

	cd $OUT
	for var in "$@"
	do
		if [[ "$var" = "--with-lto-clang" ]] ; then
			echo ""
			echo "Enable LTO_CLANG"
			../scripts/config \
			-e CONFIG_LTO \
			-e CONFIG_THINLTO \
			-d CONFIG_LTO_NONE \
			-e CONFIG_LTO_CLANG \
			-e CONFIG_CFI_CLANG \
			-e CONFIG_CFI_PERMISSIVE \
			-e CONFIG_CFI_CLANG_SHADOW
			OUTPUT_ZIP="${OUTPUT_ZIP}.lto"
			CC=$CLANG_CC
			LD=$CLANG_LD
			LDLTO=$CLANG_LDLTO
			continue
		fi
		if [[ "$var" = "--with-lto-gcc" ]] ; then
			echo ""
			echo "Enable LTO_GCC"
			../scripts/config \
			-e CONFIG_LTO \
			-d CONFIG_LTO_NONE \
			-e CONFIG_LTO_GCC
			OUTPUT_ZIP="${OUTPUT_ZIP}.lto"
			continue
		fi
        if [[ "$var" = "--with-supersu" ]] ; then
            echo "Enable ASSISTED_SUPERUSER"
            ../scripts/config \
            -e ASSISTED_SUPERUSER
            continue
        fi
	done
	echo ""

	cd $RDIR
	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			O=$OUT \
			CC=$CC \
			LD=$LD \
			LDLTO=$LDLTO \
			CROSS_COMPILE_ARM32="${BUILD_CROSS_COMPILE_ARM32}" \
			CROSS_COMPILE="${BUILD_CROSS_COMPILE}" || exit -1

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

FUNC_BUILD_RAMDISK()
{
	cp "${OUT}/arch/${ARCH}/boot/Image" "${RDIR}/aik/split_img/boot.img-zImage"
	cd "${RDIR}/aik"
	./repackimg.sh --nosudo
}

FUNC_BUILD_ZIP()
{
	cd "${RDIR}/out/"
	cp "${RDIR}/aik/image-new.img" "${RDIR}/out/boot.img"
	cp "${OUT}/arch/arm64/boot/dtb.img" "${RDIR}/out/dtb.img"
	cp "${OUT}/arch/arm64/boot/dtbo.img" "${RDIR}/out/dtbo.img"
	rm -f "${OUT}/out/system/lib/modules/*.ko"
	find ${OUT} -name "*.ko" -not -path "*/out/*" -exec cp -f {} "${RDIR}/out/system/lib/modules/" \;
	cd "${RDIR}/out/" && zip "../${OUTPUT_ZIP}.zip" -r *
}

# MAIN FUNCTION
rm -rf ./build.log
(
	START_TIME=`date +%s`

	FUNC_BUILD_KERNEL "$@"
	FUNC_BUILD_RAMDISK
	FUNC_BUILD_ZIP

	END_TIME=`date +%s`

	let "ELAPSED_TIME=${END_TIME}-${START_TIME}"
	echo "Total compile time was ${ELAPSED_TIME} seconds"

) 2>&1 | tee -a ./build.log
