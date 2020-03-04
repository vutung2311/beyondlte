#!/bin/bash

ARCH=arm64
export KBUILD_BUILD_USER=BuildUser
export KBUILD_BUILD_HOST=BuildHost
export PLATFORM_VERSION=10.0.0
export KBUILD_COMPILER_STRING="LLVM Clang 9.0"

GCC_BIN_PATH=$HOME/Toolchain/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu/bin
CLANG_BIN_PATH=$HOME/Toolchain/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04/bin

BUILD_CROSS_COMPILE=$GCC_BIN_PATH/aarch64-linux-gnu-
BUILD_CC=$CLANG_BIN_PATH/clang
# BUILD_CC="${BUILD_CROSS_COMPILE}gcc"
BUILD_LD=$CLANG_BIN_PATH/ld.lld
# BUILD_LD="${BUILD_CROSS_COMPILE}ld"
BUILD_LDLTO=$CLANG_BIN_PATH/ld.lld
# BUILD_LDLTO="${BUILD_CROSS_COMPILE}ld.gold"
BUILD_JOB_NUMBER="$(nproc)"
# BUILD_JOB_NUMBER=1

OUTPUT_ZIP="g970f_kernel"
RDIR="$(pwd)"

KERNEL_DEFCONFIG=exynos9820-beyond0lte_defconfig

FUNC_CLEAN_DTB()
{
	if ! [ -d ${RDIR}/arch/${ARCH}/boot/dts ] ; then
		echo "no directory : "${RDIR}/arch/${ARCH}/boot/dts""
	else
		echo "rm files in : "${RDIR}/arch/${ARCH}/boot/dts/*.dtb""
		rm ${RDIR}/arch/${ARCH}/boot/dts/exynos/*.dtb
	fi
}

FUNC_BUILD_KERNEL()
{
	echo ""
	echo "=============================================="
	echo "START : FUNC_BUILD_KERNEL"
	echo "=============================================="
	echo ""
	echo "build common config="$KERNEL_DEFCONFIG ""
	echo "build model config=SM-G970F"

	FUNC_CLEAN_DTB

	make -j$BUILD_JOB_NUMBER ARCH=${ARCH} \
			CC=$BUILD_CC \
			LD=$BUILD_LD \
			LDLTO=$BUILD_LDLTO \
			CROSS_COMPILE="$BUILD_CROSS_COMPILE" \
			$KERNEL_DEFCONFIG || exit -1

	for var in "$@"
	do
		if [[ "$var" = "--with-lto" ]] ; then
			echo ""
			echo "Enable LTO_CLANG"
			echo ""
			./scripts/config \
			-d LTO_NONE \
			-e LTO_CLANG \
			-e CFI_CLANG \
			-e CFI_PERMISSIVE \
			-e CFI_CLANG_SHADOW \
			-d ARM64_ERRATUM_843419 \
			-d MODVERSIONS
			OUTPUT_ZIP=${OUTPUT_ZIP}".lto"
			break
		fi
	done

	make -j$BUILD_JOB_NUMBER ARCH=${ARCH} \
			CC=$BUILD_CC \
			LD=$BUILD_LD \
			LDLTO=$BUILD_LDLTO \
			CROSS_COMPILE="$BUILD_CROSS_COMPILE" || exit -1

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

FUNC_BUILD_RAMDISK()
{
	cp ${RDIR}/arch/${ARCH}/boot/Image ${RDIR}/aik/split_img/boot.img-zImage
	cd ${RDIR}/aik
	./repackimg.sh
}

FUNC_BUILD_ZIP()
{
	cd ${RDIR}/out/
	cp ${RDIR}/aik/image-new.img ${RDIR}/out/boot.img
	rm -f "${RDIR}/out/system/lib/modules/*.ko"
	find ${RDIR} -name "*.ko" -not -path "*/out/*" -exec cp -f {} ${RDIR}/out/system/lib/modules/ \;
	cd ${RDIR}/out/ && zip ../${OUTPUT_ZIP}.zip -r *
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
