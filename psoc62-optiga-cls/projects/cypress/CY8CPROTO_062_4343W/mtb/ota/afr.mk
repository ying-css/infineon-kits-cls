################################################################################
# \file afr.mk
# \version 1.0
#
# \brief
# Configuration file for adding/removing aFR files. Modify this file
# to suit the application needs.
#
################################################################################
# \copyright
# Copyright 2019 Cypress Semiconductor Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################


################################################################################
# Global settings
################################################################################

CY_DEVICESUPPORT_PATH=$(CY_AFR_ROOT)/vendors/cypress/psoc6/psoc6pdl

# Use auto-discovery for cypress files and set the paths
CY_EXTAPP_PATH=$(CY_AFR_ROOT)/vendors/cypress
CY_AFR_BOARD_PATH=$(CY_EXTAPP_PATH)/boards/$(CY_AFR_TARGET)

# NOTE this is still aws_demos for cy_code inclusion
# This will change when cy_code is made to be board-level specific (rahter than app-level specific)
CY_AFR_BOARD_APP_PATH=$(CY_AFR_BOARD_PATH)/aws_demos/application_code/cy_code

# cert file for enterprise
CY_AFR_BOARD_APP_INC=$(CY_AFR_BOARD_PATH)/aws_demos/application_code


# Artifact locations for launch configs
CY_SYM_FILE=\$$\{cy_prj_path\}/$(CY_BUILD_RELATIVE_LOCATION)/$(APPNAME)/$(TARGET)/$(CONFIG)/$(APPNAME).elf
ifeq ($(OTA_SUPPORT),1)
CY_PROG_FILE=\$$\{cy_prj_path\}/$(CY_BUILD_RELATIVE_LOCATION)/$(APPNAME)/$(TARGET)/$(CONFIG)/$(APPNAME).signed.hex
else
CY_PROG_FILE=\$$\{cy_prj_path\}/$(CY_BUILD_RELATIVE_LOCATION)/$(APPNAME)/$(TARGET)/$(CONFIG)/$(APPNAME).elf
endif

# Resolve toolchain name 
ifeq ($(TOOLCHAIN),GCC_ARM)
CY_AFR_TOOLCHAIN=GCC
CY_AFR_TOOLCHAIN_LS_EXT=ld
else ifeq ($(TOOLCHAIN),IAR)
CY_AFR_TOOLCHAIN=$(TOOLCHAIN)
CY_AFR_TOOLCHAIN_LS_EXT=icf
else ifeq ($(TOOLCHAIN),ARM)
CY_AFR_TOOLCHAIN=$(TOOLCHAIN)
CY_AFR_TOOLCHAIN_LS_EXT=sct
endif

# Resolve target name and path
CY_AFR_TARGET=$(subst -,_,$(TARGET))

# Explicitly add the BSP makefile
CY_EXTRA_INCLUDES=$(CY_AFR_BOARD_APP_PATH)/$(TARGET).mk

# Set the linker script 
ifeq ($(OTA_SUPPORT),1)
    # Additional / custom linker flags.
    ifeq ($(TOOLCHAIN),GCC_ARM)
    LDFLAGS="-Wl,--undefined=uxTopUsedPriority,--defsym,MCUBOOT_HEADER_SIZE=$(MCUBOOT_HEADER_SIZE),--defsym,MCUBOOT_BOOTLOADER_SIZE=$(MCUBOOT_BOOTLOADER_SIZE),--defsym,CY_BOOT_PRIMARY_1_SIZE=$(CY_BOOT_PRIMARY_1_SIZE)"
    else
    ifeq ($(TOOLCHAIN),IAR)
    LDFLAGS="--keep uxTopUsedPriority --defsym,MCUBOOT_HEADER_SIZE=$(MCUBOOT_HEADER_SIZE) --defsym,MCUBOOT_BOOTLOADER_SIZE=$(MCUBOOT_BOOTLOADER_SIZE) --defsym,CY_BOOT_PRIMARY_1_SIZE=$(CY_BOOT_PRIMARY_1_SIZE)"
    else
    ifeq ($(TOOLCHAIN),ARM)
    LDFLAGS="--undefined=uxTopUsedPriority --defsym,MCUBOOT_HEADER_SIZE=$(MCUBOOT_HEADER_SIZE) --defsym,MCUBOOT_BOOTLOADER_SIZE=$(MCUBOOT_BOOTLOADER_SIZE) --defsym,CY_BOOT_PRIMARY_1_SIZE=$(CY_BOOT_PRIMARY_1_SIZE)"
    else
    LDFLAGS=
    endif #ARM
    endif #IAR
    endif #GCC_ARM

	# Linker Script
	LINKER_SCRIPT_ABSOLUTE:=$(subst \,/,$(abspath $(wildcard $(CY_AFR_BOARD_APP_PATH)/COMPONENT_$(CORE)/TOOLCHAIN_$(TOOLCHAIN)/ota/*_ota_int.$(CY_AFR_TOOLCHAIN_LS_EXT))))
else
	# Non-OTA support builds

# linker flags and Linker Script
    ifeq ($(TOOLCHAIN),GCC_ARM)
    LDFLAGS=-Wl,--undefined=uxTopUsedPriority
    else
    ifeq ($(TOOLCHAIN),IAR)
    LDFLAGS=--keep uxTopUsedPriority
    else
    ifeq ($(TOOLCHAIN),ARM)
    LDFLAGS=--undefined=uxTopUsedPriority
    else
    LDFLAGS=
    endif #ARM
    endif #IAR
    endif #GCC_ARM

	# Linker Script
    LINKER_SCRIPT_ABSOLUTE=$(wildcard $(CY_AFR_BOARD_APP_PATH)/COMPONENT_$(CORE)/TOOLCHAIN_$(TOOLCHAIN)/*.$(CY_AFR_TOOLCHAIN_LS_EXT))
endif

# Fix for Windows Cygwin builds
ifeq ($(OS),Windows_NT)
	CY_WHICH_CYGPATH:=$(shell which cygpath)
    #
    # CygWin/MSYS ?
    #
    ifneq ($(CY_WHICH_CYGPATH),)
    	LINKER_SCRIPT_ABSOLUTE:=$(shell cygpath -m --absolute $(LINKER_SCRIPT_ABSOLUTE))
    endif
endif
LINKER_SCRIPT:=$(LINKER_SCRIPT_ABSOLUTE)

################################################################################
# vendors/cypress
################################################################################

# Cypress-specific directories and files to ignore
CY_IGNORE+=\
	$(CY_EXTAPP_PATH)/boards\
	$(CY_EXTAPP_PATH)/WICED_SDK\
	$(CY_EXTAPP_PATH)/apps\
	$(CY_EXTAPP_PATH)/libraries
    
CY_CONFIG_MODUS_FILE=./$(CY_AFR_BOARD_APP_PATH)/design.modus

SOURCES+=\
	$(wildcard $(CY_EXTAPP_PATH)/apps/$(CY_AFR_BUILD)/*.c)\
	$(wildcard $(CY_AFR_BOARD_APP_PATH)/*.c)\
	$(wildcard $(CY_AFR_BOARD_APP_PATH)/GeneratedSource/*.c)\
	$(wildcard $(CY_AFR_BOARD_APP_PATH)/COMPONENT_$(CORE)/*.c)\
	$(wildcard $(CY_AFR_BOARD_APP_PATH)/COMPONENT_$(CORE)/TOOLCHAIN_$(TOOLCHAIN)/*.S)\
	$(wildcard $(CY_AFR_BOARD_APP_PATH)/COMPONENT_$(CORE)/TOOLCHAIN_$(TOOLCHAIN)/*.s)\
	$(wildcard $(CY_AFR_BOARD_PATH)/ports/ble/*.c)\
	$(wildcard $(CY_AFR_BOARD_PATH)/ports/pkcs11/*.c)\
	$(wildcard $(CY_AFR_BOARD_PATH)/ports/wifi/*.c)

# Include app-specific config_files and include dirs before AFR "demo" includes
INCLUDES+=\
	$(CY_EXTAPP_PATH)/apps/$(CY_AFR_BUILD)\
	$(CY_EXTAPP_PATH)/apps/$(CY_AFR_BUILD)/config_files\
	$(CY_AFR_BOARD_PATH)/aws_demos/config_files\
	$(CY_EXTAPP_PATH)/apps/$(CY_AFR_BUILD)/include\
	$(CY_AFR_ROOT)/demos/include\
	$(CY_AFR_BOARD_APP_PATH)\
	$(CY_AFR_BOARD_APP_PATH)/GeneratedSource\
	$(CY_AFR_BOARD_APP_PATH)/startup\
	$(CY_AFR_BOARD_PATH)/ports/ble\
	$(CY_AFR_BOARD_PATH)/ports/pkcs11\
	$(CY_AFR_BOARD_PATH)/ports/wifi\
	$(CY_AFR_BOARD_APP_INC)

# SDIO_HOST sources and includes
ifneq ($(filter $(TARGET),CY8CKIT-062-WIFI-BT CYW943012P6EVB-01),)
SOURCES+=\
	$(wildcard $(CY_AFR_BOARD_APP_PATH)/SDIO_HOST/*.c)

INCLUDES+=\
	$(CY_AFR_BOARD_APP_PATH)/SDIO_HOST
endif


################################################################################
# freertos_kernel
################################################################################

SOURCES+=\
	$(wildcard $(CY_AFR_ROOT)/freertos_kernel/*.c)\
	$(wildcard $(CY_AFR_ROOT)/freertos_kernel/portable/$(CY_AFR_TOOLCHAIN)/ARM_CM4F/*.c)\
	$(CY_AFR_ROOT)/freertos_kernel/portable/MemMang/heap_4.c

INCLUDES+=\
	$(CY_AFR_ROOT)/freertos_kernel\
	$(CY_AFR_ROOT)/freertos_kernel/include\
	$(CY_AFR_ROOT)/freertos_kernel/portable/$(CY_AFR_TOOLCHAIN)/ARM_CM4F

################################################################################
# demos
################################################################################

SOURCES+=\
	$(wildcard $(CY_AFR_ROOT)/demos/ble/*.c)\
	$(CY_AFR_ROOT)/demos/demo_runner/aws_demo_version.c\
	$(CY_AFR_ROOT)/demos/demo_runner/iot_demo_freertos.c\
	$(CY_AFR_ROOT)/demos/demo_runner/iot_demo_runner.c\
	$(wildcard $(CY_AFR_ROOT)/demos/dev_mode_key_provisioning/src/*.c)\
	$(wildcard $(CY_AFR_ROOT)/demos/https/*.c)\
	$(wildcard $(CY_AFR_ROOT)/demos/mqtt/*.c)\
	$(wildcard $(CY_AFR_ROOT)/demos/network_manager/*.c)\
	$(wildcard $(CY_AFR_ROOT)/demos/tcp/*.c)\

INCLUDES+=\
	$(CY_AFR_ROOT)/demos/dev_mode_key_provisioning\
	$(CY_AFR_ROOT)/demos/dev_mode_key_provisioning/include\
	$(CY_AFR_ROOT)/demos/https\
	$(CY_AFR_ROOT)/demos/network_manager\
	$(CY_AFR_ROOT)/demos/tcp

################################################################################
# libraries (3rd party)
################################################################################

SOURCES+=\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/http_parser/http_parser.c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/api/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/core/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/core/ipv4/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/core/ipv6/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/netif/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/netif/ppp/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/netif/ppp/polarssl/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/portable/arch/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/mbedtls/library/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/mbedtls/utils/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/tinycbor/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/unity/extras/fixture/src/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/3rdparty/unity/src/*c)

INCLUDES+=\
	$(CY_AFR_ROOT)/libraries/3rdparty/http_parser\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/compat/posix\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/compat/posix/arpa\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/compat/posix/net\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/compat/posix/sys\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/compat/stdc\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/lwip\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/lwip/apps\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/lwip/priv\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/lwip/prot\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/netif\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/netif/ppp\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/include/netif/ppp/polarssl\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/portable\
	$(CY_AFR_ROOT)/libraries/3rdparty/lwip/src/portable/arch\
	$(CY_AFR_ROOT)/libraries/3rdparty/mbedtls/include\
	$(CY_AFR_ROOT)/libraries/3rdparty/mbedtls/include/mbedtls\
	$(CY_AFR_ROOT)/libraries/3rdparty/pkcs11\
	$(CY_AFR_ROOT)/libraries/3rdparty/tinycbor\
	$(CY_AFR_ROOT)/libraries/3rdparty/unity/extras/fixture/src\
	$(CY_AFR_ROOT)/libraries/3rdparty/unity/src


################################################################################
# libraries (abstractions)
################################################################################

SOURCES+=\
	$(wildcard $(CY_AFR_ROOT)/libraries/abstractions/ble_hal/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/abstractions/pkcs11/mbedtls/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/abstractions/platform/freertos/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/abstractions/secure_sockets/lwip/*c)

INCLUDES+=\
	$(CY_AFR_ROOT)/libraries/abstractions/ble_hal\
	$(CY_AFR_ROOT)/libraries/abstractions/ble_hal/include\
	$(CY_AFR_ROOT)/libraries/abstractions/pkcs11\
	$(CY_AFR_ROOT)/libraries/abstractions/pkcs11/include\
	$(CY_AFR_ROOT)/libraries/abstractions/pkcs11/mbedtls\
	$(CY_AFR_ROOT)/libraries/abstractions/platform/freertos\
	$(CY_AFR_ROOT)/libraries/abstractions/platform/freertos/include\
	$(CY_AFR_ROOT)/libraries/abstractions/platform/freertos/include/platform\
	$(CY_AFR_ROOT)/libraries/abstractions/platform/include\
	$(CY_AFR_ROOT)/libraries/abstractions/platform/include/platform\
	$(CY_AFR_ROOT)/libraries/abstractions/platform/include/types\
	$(CY_AFR_ROOT)/libraries/abstractions/secure_sockets\
	$(CY_AFR_ROOT)/libraries/abstractions/secure_sockets/include\
	$(CY_AFR_ROOT)/libraries/abstractions/wifi\
	$(CY_AFR_ROOT)/libraries/abstractions/wifi/include


################################################################################
# libraries (c_sdk)
################################################################################

SOURCES+=\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/ble/src/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/ble/src/services/device_information/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/ble/src/services/mqtt_ble/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/ble/src/services/wifi_provisioning/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/common/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/common/logging/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/common/taskpool/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/https/src/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/mqtt/src/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/serializer/src/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/serializer/src/cbor/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/standard/serializer/src/json/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/c_sdk/aws/shadow/src/*c)

INCLUDES+=\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/ble\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/ble/include\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/ble/src\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/common\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/common/include\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/common/include/private\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/common/include/types\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/https\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/https/include\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/https/include/types\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/https/src\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/https/src/private\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/mqtt\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/mqtt/include\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/mqtt/include/types\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/mqtt/src\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/mqtt/src/private\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/serializer\
	$(CY_AFR_ROOT)/libraries/c_sdk/standard/serializer/include\
	$(CY_AFR_ROOT)/libraries/c_sdk/aws/shadow/include\
	$(CY_AFR_ROOT)/libraries/c_sdk/aws/shadow/include/types\

################################################################################
# libraries (freertos_plus)
################################################################################

SOURCES+=\
	$(wildcard $(CY_AFR_ROOT)/libraries/freertos_plus/standard/crypto/src/*c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/freertos_plus/standard/freertos_plus_tcp/source/*c)\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/freertos_plus_tcp/source/portable/BufferManagement/BufferAllocation_2.c\
	$(wildcard $(CY_AFR_ROOT)/libraries/freertos_plus/standard/freertos_plus_tcp/source/portable/NetworkInterface/board_family/*.c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/freertos_plus/standard/freertos_plus_tcp/source/portable/Compiler/$(CY_AFR_TOOLCHAIN)/*.c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/freertos_plus/standard/pkcs11/src/*.c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/freertos_plus/standard/tls/src/*.c)\
	$(wildcard $(CY_AFR_ROOT)/libraries/freertos_plus/standard/utils/src/*.c)\

INCLUDES+=\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/crypto\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/crypto/include\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/freertos_plus_posix\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/freertos_plus_posix/include\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/freertos_plus_tcp\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/freertos_plus_tcp/include\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/freertos_plus_tcp/source/portable/Compiler/$(CY_AFR_TOOLCHAIN)\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/pkcs11\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/pkcs11/include\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/tls\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/tls/include\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/utils\
	$(CY_AFR_ROOT)/libraries/freertos_plus/standard/utils/include

################################################################################
# Additional Source files and includes needed for OTA support 
################################################################################

ifeq ($(OTA_SUPPORT),1)
SOURCES+=\
	$(wildcard $(CY_AFR_ROOT)/demos/ota/*.c)\
	$(wildcard $(CY_AFR_BOARD_PATH)/ports/ota/*.c)\
	$(CY_AFR_ROOT)/demos/demo_runner/aws_demo_version.c\
	$(CY_AFR_ROOT)/demos/demo_runner/iot_demo_freertos.c\
	$(CY_AFR_ROOT)/demos/demo_runner/iot_demo_runner.c\
	$(CY_AFR_ROOT)/libraries/freertos_plus/aws/ota/src/aws_iot_ota_agent.c\
	$(CY_AFR_ROOT)/libraries/freertos_plus/aws/ota/src/aws_ota_cbor.c\
    $(CY_AFR_ROOT)/libraries/3rdparty/jsmn/jsmn.c\
	$(MCUBOOT_CYFLASH_PAL_DIR)/cy_flash_map.c\
	$(MCUBOOT_CYFLASH_PAL_DIR)/cy_flash_psoc6.c\
    $(MCUBOOT_BOOTUTIL_SRC_DIR)/bootutil_misc.c\
	$(CY_AFR_BOARD_PATH)/ports/ota/aws_ota_pal.c
	
INCLUDES+=\
    $(MCUBOOT_CY_BOOTAPP_DIR)\
    $(MCUBOOT_BOOTAPP_CONFIG_DIR)\
    $(MCUBOOT_BOOTUTIL_INC_DIR)\
    $(MCUBOOT_CYFLASH_PAL_DIR)/include\
	$(CY_AFR_BOARD_PATH)/ports/ota\
    $(CY_AFR_ROOT)/libraries/freertos_plus/standard/crypto/include\
    $(CY_AFR_ROOT)/libraries/3rdparty/jsmn\
	$(CY_AFR_ROOT)/libraries/freertos_plus/aws/ota/include\
	$(CY_AFR_ROOT)/libraries/freertos_plus/aws/ota/src\
    $(CY_AFR_ROOT)/libraries/abstractions/wifi/include
    
endif
	