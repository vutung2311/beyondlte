obj-$(CONFIG_EXYNOS_NPU_PUBLISH_NPU_BUILD_VER)	+= npu-ver-info.o

$(srctree)/drivers/vision/npu/generated/npu-ver-info.c:	FORCE
	($(srctree)/drivers/vision/npu/generated/update_ver_info.sh \
	|| cp -n $(srctree)/drivers/vision/npu/generated/npu-ver-info-default.c $(srctree)/drivers/vision/npu/generated/npu-ver-info~) 2>/dev/null
