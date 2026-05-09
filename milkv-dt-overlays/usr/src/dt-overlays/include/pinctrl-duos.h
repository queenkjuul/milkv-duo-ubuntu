/* SPDX-License-Identifier: GPL-2.0-only OR BSD-2-Clause */
/*
 * Copyright (C) 2024 Inochi Amaoto <inochiama@outlook.com>
 *
 * This file is generated from vendor pinout definition.
 */

#ifndef _DT_BINDINGS_PINCTRL_SG2000_H
#define _DT_BINDINGS_PINCTRL_SG2000_H

#include <pinctrl-cv18xx.h>

#define PINPOS(row, col)			\
	((((row) - 'A' + 1) << 8) + ((col) - 1))

#define A15               PINPOS('M', 4)  // PIN_UART0_RX
#define A16               PINPOS('M', 5)  // PIN_UART0_TX
#define A18               PINPOS('N', 4)  // PIN_JTAG_CPU_TCK
#define A19               PINPOS('N', 6)  // PIN_JTAG_CPU_TMS
#define A20               PINPOS('M', 6)  // PIN_JTAG_CPU_TRST
#define A28               PINPOS('R', 6)  // PIN_IIC0_SCL
#define A29               PINPOS('P', 6)  // PIN_IIC0_SDA
#define B1                PINPOS('E', 15) // PIN_ADC3
#define B2                PINPOS('E', 14) // PIN_ADC2
#define B3                PINPOS('E', 13) // PIN_ADC1
#define B11               PINPOS('A', 12) // PIN_VIVO_D10
#define B12               PINPOS('B', 12) // PIN_VIVO_D9
#define B13               PINPOS('C', 11) // PIN_VIVO_D8
#define B14               PINPOS('B', 11) // PIN_VIVO_D7
#define B15               PINPOS('C', 10) // PIN_VIVO_D6
#define B16               PINPOS('B', 10) // PIN_VIVO_D5
#define B17               PINPOS('D', 10) // PIN_VIVO_D4
#define B18               PINPOS('A', 10) // PIN_VIVO_D3
#define B19               PINPOS('A', 9)  // PIN_VIVO_D2
#define B20               PINPOS('B', 9)  // PIN_VIVO_D1
#define B21               PINPOS('E', 10) // PIN_VIVO_D0
#define B22               PINPOS('C', 9)  // PIN_VIVO_CLK
#define C12               PINPOS('E', 2)  // PIN_MIPI_TXM0
#define C13               PINPOS('E', 1)  // PIN_MIPI_TXP0
#define C14               PINPOS('D', 2)  // PIN_MIPI_TXM1
#define C15               PINPOS('D', 1)  // PIN_MIPI_TXP1
#define C16               PINPOS('C', 2)  // PIN_MIPI_TXM2
#define C17               PINPOS('C', 1)  // PIN_MIPI_TXP2
#define C18               PINPOS('A', 2)  // PIN_MIPI_TXM4
#define C19               PINPOS('B', 3)  // PIN_MIPI_TXP4
#define C20               PINPOS('B', 2)  // PIN_MIPI_TXM3
#define C21               PINPOS('B', 1)  // PIN_MIPI_TXP3
#define E0                PINPOS('M', 13) // PIN_PWR_GPIO0
#define E1                PINPOS('N', 13) // PIN_PWR_GPIO1
#define E2                PINPOS('M', 12) // PIN_PWR_GPIO2
#define PIN_MIPIRX0N			PINPOS('A', 4)
#define PIN_MIPIRX3P			PINPOS('A', 6)
#define PIN_MIPIRX4P			PINPOS('A', 7)
#define PIN_USB_VBUS_DET		PINPOS('A', 13)
#define PIN_MIPIRX0P			PINPOS('B', 4)
#define PIN_MIPIRX1N			PINPOS('B', 5)
#define PIN_MIPIRX2N			PINPOS('B', 6)
#define PIN_MIPIRX4N			PINPOS('B', 7)
#define PIN_MIPIRX5N			PINPOS('B', 8)
#define PIN_USB_ID			PINPOS('B', 13)
#define PIN_ETH_RXM			PINPOS('B', 15)
#define PIN_CAM_PD0			PINPOS('C', 3)
#define PIN_CAM_MCLK0			PINPOS('C', 4)
#define PIN_MIPIRX1P			PINPOS('C', 5)
#define PIN_MIPIRX2P			PINPOS('C', 6)
#define PIN_MIPIRX3N			PINPOS('C', 7)
#define PIN_MIPIRX5P			PINPOS('C', 8)
#define PIN_USB_VBUS_EN			PINPOS('C', 12)
#define PIN_ETH_RXP			PINPOS('C', 14)
#define PIN_GPIO_RTX			PINPOS('C', 15)
#define PIN_CAM_MCLK1			PINPOS('D', 3)
#define PIN_IIC3_SCL			PINPOS('D', 4)
#define PIN_ETH_TXM			PINPOS('D', 14)
#define PIN_ETH_TXP			PINPOS('D', 15)
#define PIN_CAM_PD1			PINPOS('E', 4)
#define PIN_CAM_RST0			PINPOS('E', 5)
#define PIN_AUD_AOUTL			PINPOS('F', 2)
#define PIN_IIC3_SDA			PINPOS('F', 4)
#define PIN_SD1_D2			PINPOS('F', 14)
#define PIN_AUD_AOUTR			PINPOS('G', 2)
#define PIN_SD1_D3			PINPOS('G', 13)
#define PIN_SD1_CLK			PINPOS('G', 14)
#define PIN_SD1_CMD			PINPOS('G', 15)
#define PIN_AUD_AINL_MIC		PINPOS('H', 1)
#define PIN_RSTN			PINPOS('H', 12)
#define PIN_PWM0_BUCK			PINPOS('H', 13)
#define PIN_SD1_D1			PINPOS('H', 14)
#define PIN_SD1_D0			PINPOS('H', 15)
#define PIN_AUD_AINR_MIC		PINPOS('J', 1)
#define PIN_IIC2_SCL			PINPOS('J', 13)
#define PIN_IIC2_SDA			PINPOS('J', 14)
#define PIN_SD0_CD			PINPOS('K', 2)
#define PIN_SD0_D1			PINPOS('K', 3)
#define PIN_UART2_RX			PINPOS('K', 13)
#define PIN_UART2_CTS			PINPOS('K', 14)
#define PIN_UART2_TX			PINPOS('K', 15)
#define PIN_SD0_CLK			PINPOS('L', 1)
#define PIN_SD0_D0			PINPOS('L', 2)
#define PIN_SD0_CMD			PINPOS('L', 3)
#define PIN_CLK32K			PINPOS('L', 14)
#define PIN_UART2_RTS			PINPOS('L', 15)
#define PIN_SD0_D3			PINPOS('M', 1)
#define PIN_SD0_D2			PINPOS('M', 2)
#define PIN_PWR_ON			PINPOS('M', 11)
#define PIN_CLK25M			PINPOS('M', 14)
#define PIN_SD0_PWR_EN			PINPOS('N', 1)
#define PIN_SPK_EN			PINPOS('N', 3)
#define PIN_PWR_WAKEUP1			PINPOS('N', 11)
#define PIN_PWR_WAKEUP0			PINPOS('N', 12)
#define PIN_EMMC_DAT3			PINPOS('P', 1)
#define PIN_EMMC_DAT0			PINPOS('P', 2)
#define PIN_EMMC_DAT2			PINPOS('P', 3)
#define PIN_EMMC_RSTN			PINPOS('P', 4)
#define PIN_AUX0			PINPOS('P', 5)
#define PIN_PWR_SEQ3			PINPOS('P', 10)
#define PIN_PWR_VBAT_DET		PINPOS('P', 11)
#define PIN_PWR_SEQ1			PINPOS('P', 12)
#define PIN_PWR_BUTTON1			PINPOS('P', 13)
#define PIN_EMMC_DAT1			PINPOS('R', 2)
#define PIN_EMMC_CMD			PINPOS('R', 3)
#define PIN_EMMC_CLK			PINPOS('R', 4)
#define PIN_GPIO_ZQ			PINPOS('R', 10)
#define PIN_PWR_RSTN			PINPOS('R', 11)
#define PIN_PWR_SEQ2			PINPOS('R', 12)
#define PIN_XTAL_XIN			PINPOS('R', 13)

#endif /* _DT_BINDINGS_PINCTRL_SG2000_H */
