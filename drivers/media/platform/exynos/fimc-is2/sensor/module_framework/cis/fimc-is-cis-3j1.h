/*
 * Samsung Exynos SoC series Sensor driver
 *
 *
 * Copyright (c) 2016 Samsung Electronics Co., Ltd
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#ifndef FIMC_IS_CIS_3J1_H
#define FIMC_IS_CIS_3J1_H

#include "fimc-is-cis.h"

#define EXT_CLK_Mhz (26)

/* FIXME */
#define SENSOR_3J1_MAX_WIDTH		(3976 + 0)
#define SENSOR_3J1_MAX_HEIGHT		(2736 + 0)

#define SENSOR_3J1_FINE_INTEGRATION_TIME_MIN                0x100
#define SENSOR_3J1_FINE_INTEGRATION_TIME_MAX                0x100
#define SENSOR_3J1_COARSE_INTEGRATION_TIME_MIN              0x2
#define SENSOR_3J1_COARSE_INTEGRATION_TIME_MAX_MARGIN       0x4
#define SENSOR_3J1_POST_INIT_SETTING_MAX	30

#define SENSOR_3J1_EXPOSURE_TIME_MAX						250000 /* 250ms */

#define USE_GROUP_PARAM_HOLD	(0)

enum sensor_3j1_mode_enum {
	SENSOR_3J1_3648X2736_30FPS = 0,
	SENSOR_3J1_2736X2736_30FPS,
	SENSOR_3J1_3968X2232_30FPS,
	SENSOR_3J1_3968X1880_30FPS,
	SENSOR_3J1_2944X2208_30FPS,
	SENSOR_3J1_3216X1808_30FPS,
	SENSOR_3J1_3216X1528_30FPS,
	SENSOR_3J1_2208X2208_30FPS,
	SENSOR_3J1_1824X1368_30FPS,
	SENSOR_3J1_1988X1120_120FPS,
	SENSOR_3J1_1988X1120_240FPS,
	SENSOR_3J1_912X684_120FPS,
	SENSOR_3J1_3648X2736_30FPS_NONPD,
	SENSOR_3J1_3968X2232_30FPS_NONPD,
	SENSOR_3J1_1824X1368_30FPS_NONPD,
	SENSOR_3J1_1472X1104_30FPS,
	SENSOR_3J1_1616X904_30FPS,
	SENSOR_3J1_1616X768_30FPS,
	SENSOR_3J1_1104X1104_30FPS,
	SENSOR_3J1_3648X2736_60FPS,
	SENSOR_3J1_3968X2232_60FPS,
};
#endif

