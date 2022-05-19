
# -------------------------------------------------------------------------------------------------
# For OTA_SUPPORT, we need to sign the Hex output for use with cy_mcuboot
# This is used in a POST BUILD Step (see bottom of function(cy_kit_generate) )
# -------------------------------------------------------------------------------------------------
# These can be defined before calling to over-ride
#      - define in <application>/CMakeLists.txt )
#
#   CMake Variable                  Default
#   --------------                  -------
# MCUBOOT_KEY_FILE           "cypress-test-ec-p256.pem"
#
function(config_cy_mcuboot_sign_script)
    # Python script for the image signing
    set(IMGTOOL_SCRIPT_NAME     "./imgtool.py")
    set(IMGTOOL_SCRIPT_PATH     "${MCUBOOT_SCRIPT_FILE_DIR}/imgtool.py")

    # cy_mcuboot key file
    if((NOT MCUBOOT_KEY_FILE) OR ("${MCUBOOT_KEY_FILE}" STREQUAL ""))
        set(MCUBOOT_KEY_FILE  "cypress-test-ec-p256.pem")
    endif()
    set(SIGNING_KEY_PATH         "${MCUBOOT_KEY_DIR}/${MCUBOOT_KEY_FILE}")

    # Is flash erase value defined ?
    # NOTE: Do not define anything for erase value 0xff
    if((NOT CY_FLASH_ERASE_VALUE) OR ("${CY_FLASH_ERASE_VALUE}" STREQUAL "0") OR ("${CY_FLASH_ERASE_VALUE}" STREQUAL "0x00"))
        set(FLASH_ERASE_VALUE "-R 0")
    else()
        set(FLASH_ERASE_VALUE "")
    endif()

    # Slot Start
    if(NOT CY_BOOT_PRIMARY_1_START)
        message(FATAL_ERROR "You must define CY_BOOT_PRIMARY_1_START in your board CMakeLists.txt for OTA_SUPPORT")
    endif()

    if(NOT CY_BOOT_PRIMARY_1_SIZE)
        message(FATAL_ERROR "You must define CY_BOOT_PRIMARY_1_SIZE in your board CMakeLists.txt for OTA_SUPPORT")
    endif()

    if(NOT MCUBOOT_HEADER_SIZE)
        message(FATAL_ERROR "You must define MCUBOOT_HEADER_SIZE in your board CMakeLists.txt for OTA_SUPPORT")
    endif()

    if(NOT MCUBOOT_MAX_IMG_SECTORS)
        message(FATAL_ERROR "You must define MCUBOOT_MAX_IMG_SECTORS in your board CMakeLists.txt for OTA_SUPPORT")
    endif()

    # Create version for sign_script.sh
    set(CY_BUILD_VERSION "${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${APP_VERSION_BUILD}")

    configure_file("${cy_psoc6_dir}/cmake/sign_script.sh.in" "${SIGN_SCRIPT_FILE_PATH}" @ONLY NEWLINE_STYLE LF)

endfunction(config_cy_mcuboot_sign_script)

# -------------------------------------------------------------------------------------------------
# Configure ModusToolbox cmake environment
# -------------------------------------------------------------------------------------------------
function(cy_kit_generate)
    cmake_parse_arguments(
    PARSE_ARGV 0
    "ARG"
    ""
    "DEVICE;LINKER_SCRIPT;COMPONENTS;DEFINES"
    ""
    )

    # is SDIO supported?
    string(FIND "${ARG_DEFINES}" "CYHAL_UDB_SDIO" check_sdio)
    if (NOT ("${check_sdio}" STREQUAL "-1"))
        set(CYHAL_UDB_SDIO "1")
    endif()


    #--------------------------------------------------------------------
    # Utilities
    #
    include("${cy_psoc6_dir}/cmake/cy_utils.cmake")
    if(EXISTS "${cy_psoc6_dir}/cmake/toolchains/${AFR_TOOLCHAIN}.cmake")
        include("${cy_psoc6_dir}/cmake/toolchains/${AFR_TOOLCHAIN}.cmake")
    elseif(AFR_METADATA_MODE)
        function(cy_cfg_toolchain)
        endfunction()
        set(ENV{CY_FREERTOS_TOOLCHAIN} GCC)
    else()
        message(FATAL_ERROR "Unsupported toolchain: ${AFR_TOOLCHAIN}")
    endif()

    # Set dirs for use below:
    #
    # app_dir: base application directory
    #        |
    #        |-- config_files           (AWS configuration files)
    #        |-- include                (AWS IOT config files)
    #        \-- main.c
    #
    # aws_credentials_incude: Location of aws_clientcredential_keys.h and aws_clientcredential.h
    # iot_common_include: Location of other iot_xxx.h files
    # cy_code_dir: used to locate the linker script files
    #
    if(CY_ALTERNATE_APP)
        set(app_dir "${AFR_ROOT_DIR}/${AFR_TARGET_APP_DIR}")
        if(NOT "${CY_APP_CONFIG_DIR}" STREQUAL "")
            set(aws_config_dir "${CY_APP_CONFIG_DIR}")
        else()
            set(aws_config_dir "${app_dir}/config_files")
        endif()
        if(NOT "${CY_APP_IOT_CONFIG_DIR}" STREQUAL "")
            set(iot_common_include "${CY_APP_IOT_CONFIG_DIR}")
        else()
            set(iot_common_include "${app_dir}/include")
        endif()
        set(cy_code_dir "${cy_board_dir}/aws_demos/application_code/cy_code")
    elseif(AFR_IS_TESTING)
        set(app_dir "${cy_board_dir}/aws_tests")
        set(aws_config_dir "${app_dir}/config_files")
        set(iot_common_include "${AFR_TESTS_DIR}/include")
        set(cy_code_dir "${app_dir}/application_code/cy_code")
    else()
        set(app_dir "${cy_board_dir}/aws_demos")
        set(aws_config_dir "${app_dir}/config_files")
        set(iot_common_include "${AFR_DEMOS_DIR}/include")
        set(cy_code_dir "${app_dir}/application_code/cy_code")
    endif()

    # verify we have an AWS config files dir
    if(NOT (EXISTS "${aws_config_dir}"))
        message( FATAL_ERROR "No config directory found: '${aws_config_dir}' (ex: <application>/config_files)")
    endif()

    # verify we have an AWS IOT config files dir
    if(NOT (EXISTS "${iot_common_include}"))
        message( FATAL_ERROR "No IOT common config directory found: '${iot_common_include}' (ex: <application>/include)")
    endif()

    # For now, the "cy_code" directory is under <board>/<app_name>/application_code/cy_code
    # Eventually we want cy_code_dir to be under the board directory, not the application
    # Allow over-rides of the linker script location

    set(CY_LINKER_PATH  "${cy_code_dir}")
    set(CY_ARCH_DIR     "${cy_clib_dir};${cy_psoc6_dir};${cy_whd_dir};${cy_capsense_dir}")

    cy_cfg_env(
        TARGET        "${AFR_BOARD_NAME}"
        DEVICE        "${ARG_DEVICE}"
        TOOLCHAIN     "${AFR_TOOLCHAIN}"
        LINKER_PATH   "${CY_LINKER_PATH}"
        LINKER_SCRIPT "${ARG_LINKER_SCRIPT}"
        COMPONENTS    "${AFR_BOARD_NAME};SOFTFP;BSP_DESIGN_MODUS;FREERTOS;${ARG_COMPONENTS}"
        ARCH_DIR      "${CY_ARCH_DIR}"
    )

    # -------------------------------------------------------------------------------------------------
    # Configure ModusToolbox target (used to build ModusToolbox firmware)
    # -------------------------------------------------------------------------------------------------

    # Find Application-specific files
    cy_find_files(app_exe_files DIRECTORY "${app_dir}")
    if(NOT ("${app_exe_files}" STREQUAL ""))
        cy_get_includes(app_inc ITEMS "${app_exe_files}" ROOT "${app_dir}")
        target_include_directories(${AFR_TARGET_APP_NAME} BEFORE PUBLIC "${app_dir}")
        cy_get_src(app_src ITEMS "${app_exe_files}")
        if(NOT ("${app_src}" STREQUAL ""))
            target_sources(${AFR_TARGET_APP_NAME} PUBLIC             "${app_src}" )
        endif()
        cy_get_libs(app_libs ITEMS "${app_exe_files}")
        if(NOT ("${app_libs}" STREQUAL ""))
            target_link_libraries(${AFR_TARGET_APP_NAME} PUBLIC        "${app_libs}")
        endif()
    endif()

    # Find Config-specific files
    target_include_directories(${AFR_TARGET_APP_NAME} BEFORE PUBLIC "${aws_config_dir}")
    cy_find_files(cfg_files DIRECTORY "${aws_config_dir}")
    if(NOT ("${cfg_files}" STREQUAL ""))
        cy_get_src(cfg_src ITEMS "${cfg_files}" ROOT "${aws_config_dir}")
        target_sources(${AFR_TARGET_APP_NAME} PUBLIC            "${cfg_src}")
    endif()

    # Find Board-specific files
    cy_find_files(board_exe_files DIRECTORY "${cy_code_dir}")
    cy_get_includes(board_inc ITEMS "${board_exe_files}" ROOT "${cy_code_dir}")
    target_include_directories(${AFR_TARGET_APP_NAME} PUBLIC "${board_inc}")
    cy_get_src(board_src ITEMS "${board_exe_files}")
    target_sources(${AFR_TARGET_APP_NAME} PUBLIC            "${board_src}")
    cy_get_libs(board_libs ITEMS "${board_exe_files}")
    target_link_libraries(${AFR_TARGET_APP_NAME} PUBLIC        "${board_libs}")

    # Find MTB files
    cy_find_files(mtb_files DIRECTORY "$ENV{CY_ARCH_DIR}")
    cy_get_includes(mtb_inc ITEMS "${mtb_files}" ROOT "$ENV{CY_ARCH_DIR}")
    target_include_directories(${AFR_TARGET_APP_NAME} PUBLIC "${mtb_inc}")
    cy_get_src(mtb_src ITEMS "${mtb_files}")
    target_sources(${AFR_TARGET_APP_NAME} PUBLIC             "${mtb_src}")
    cy_get_libs(mtb_libs ITEMS "${mtb_files}")
    target_link_libraries(${AFR_TARGET_APP_NAME} PUBLIC        "${mtb_libs}")

    # -------------------------------------------------------------------------------------------------
    # Compiler settings
    # -------------------------------------------------------------------------------------------------
    # If you support multiple compilers, you can use AFR_TOOLCHAIN to conditionally define the compiler
    # settings. This variable will be set to the file name of CMAKE_TOOLCHAIN_FILE. It might also be a
    # good idea to put your compiler settings to different files and just include them here, e.g.,
    # include(compilers/${AFR_TOOLCHAIN}.cmake)

    afr_mcu_port(compiler)
    cy_add_args_to_target(
        AFR::compiler::mcu_port INTERFACE
        OPTIMIZATION "$ENV{OPTIMIZATION}"
        DEBUG_FLAG "$ENV{DEBUG_FLAG}"
        DEFINE_FLAGS "$ENV{DEFINE_FLAGS}"
        COMMON_FLAGS "$ENV{COMMON_FLAGS}"
        VFP_FLAGS "$ENV{VFP_FLAGS}"
        CORE_FLAGS "$ENV{CORE_FLAGS}"
        ASFLAGS "$ENV{ASFLAGS}"
        LDFLAGS "$ENV{LDFLAGS}"
    )
    cy_add_std_defines(AFR::compiler::mcu_port INTERFACE)
    target_compile_definitions(
        AFR::compiler::mcu_port INTERFACE
        CYBSP_WIFI_CAPABLE
        CY_RTOS_AWARE
        CY_USING_HAL
        ${ARG_DEFINES}
    )

    # -------------------------------------------------------------------------------------------------
    # Amazon FreeRTOS portable layers
    # -------------------------------------------------------------------------------------------------
    # Define portable layer targets with afr_mcu_port(<module_name>). We will create an CMake
    # INTERFACE IMPORTED target called AFR::${module_name}::mcu_port for you. You can use it with
    # standard CMake functions like target_*. To better organize your files, you can define your own
    # targets and use target_link_libraries(AFR::${module_name}::mcu_port INTERFACE <your_targets>)
    # to provide the public interface you want expose.

    # Kernel
    afr_mcu_port(kernel)
    file(GLOB cy_freertos_port_src ${AFR_KERNEL_DIR}/portable/$ENV{CY_FREERTOS_TOOLCHAIN}/ARM_CM4F/*.[chsS])
    target_sources(
        AFR::kernel::mcu_port
        INTERFACE
        ${cy_freertos_port_src}
        "${AFR_KERNEL_DIR}/portable/MemMang/heap_4.c"
    )

    target_include_directories(AFR::kernel::mcu_port INTERFACE
        "${AFR_KERNEL_DIR}/include"
        "${AFR_KERNEL_DIR}/portable/$ENV{CY_FREERTOS_TOOLCHAIN}/ARM_CM4F"	# for portmacro.h
        "${aws_config_dir}"                                                 # for FreeRTOSconfig.h
        "${iot_common_include}"                                             # for iot_config_common.h
        "${AFR_3RDPARTY_DIR}/lwip/src/include"
        "${AFR_3RDPARTY_DIR}/lwip/src/include/lwip"
        "${AFR_3RDPARTY_DIR}/lwip/src/portable/arch"
        "${AFR_3RDPARTY_DIR}/lwip/src/portable"
        "${AFR_3RDPARTY_DIR}/tinycrypt/lib/include"
    )

    add_library(CyObjStore INTERFACE)
    target_sources(CyObjStore INTERFACE
        "${cy_psoc6_dir}/mw/objstore/cyobjstore.c"
        "${cy_psoc6_dir}/mw/emeeprom/cy_em_eeprom.c"
    )
    target_include_directories(CyObjStore INTERFACE
        "${cy_psoc6_dir}/psoc6csp/abstraction/rtos/include/COMPONENT_FREERTOS"
        "${cy_psoc6_dir}/mw/emeeprom"
        "${cy_psoc6_dir}/mw/objstore"
    )

    # WiFi
    afr_mcu_port(wifi)
    target_sources(
        AFR::wifi::mcu_port
        INTERFACE
        "${afr_ports_dir}/wifi/iot_wifi.c"
        "${afr_ports_dir}/wifi/iot_wifi_lwip.c"
        "${AFR_3RDPARTY_DIR}/lwip/src/portable/arch/sys_arch.c"
    )
    target_include_directories(AFR::wifi::mcu_port INTERFACE
        "${afr_ports_dir}/wifi"
        "${cy_psoc6_dir}/psoc6csp/abstraction/rtos/include/COMPONENT_FREERTOS"
        "${cy_psoc6_dir}/common"
        "${cy_psoc6_dir}/mw/objstore"
        "${cy_whd_dir}/src/include"
    )
    target_link_libraries(
        AFR::wifi::mcu_port
        INTERFACE
        3rdparty::lwip
    )

    # BLE
    # set(BLE_SUPPORTED 1 CACHE INTERNAL "BLE is supported on this platform.")

    if(BLE_SUPPORTED)
        afr_mcu_port(ble_hal DEPENDS CyObjStore)
        target_sources(
            AFR::ble_hal::mcu_port
            INTERFACE
            "${afr_ports_dir}/ble/iot_ble_hal_manager.c"
            "${afr_ports_dir}/ble/iot_ble_hal_manager_adapter_ble.c"
            "${afr_ports_dir}/ble/iot_ble_hal_gatt_server.c"
            "${afr_ports_dir}/ble/wiced_bt_cfg.c"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyosal/src/cybt_osal_amzn_freertos.c"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyosal/src/wiced_time_common.c"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform_gpio.c"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform_clock.c"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform_uart.c"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform.c"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform_bluetooth.c"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform_bt_nvram.c"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/ring_buffer.c"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/bt_firmware_controller.c"
        )

        target_include_directories(AFR::ble_hal::mcu_port INTERFACE
            "${afr_ports_dir}/ble"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyosal/include"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/include"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/include"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/include/stackHeaders"
        )

        target_link_libraries(
            AFR::ble_hal::mcu_port
            INTERFACE
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/bluetooth.FreeRTOS.ARM_CM4.release.a"
            "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/shim.FreeRTOS.ARM_CM4.release.a"
        )

        target_compile_definitions(
            AFR::ble_hal::mcu_port
            INTERFACE
            BLE_SUPPORTED=1
        )
    endif()

    # Secure sockets
    afr_mcu_port(secure_sockets)

    target_link_libraries(
        AFR::secure_sockets::mcu_port
        INTERFACE
        AFR::tls
        AFR::secure_sockets_lwip
    )

    # PKCS11
    afr_mcu_port(pkcs11_implementation DEPENDS CyObjStore)
    target_sources(
        AFR::pkcs11_implementation::mcu_port
        INTERFACE
        "${afr_ports_dir}/pkcs11/iot_pkcs11_pal.c"
    )
    target_include_directories(AFR::pkcs11_implementation::mcu_port INTERFACE
        "${cy_psoc6_dir}/psoc6csp/abstraction/rtos/include"
    )

    # Link to AFR::pkcs11_mbedtls if you want to use default implementation based on mbedtls.
    target_link_libraries(
        AFR::pkcs11_implementation::mcu_port
        INTERFACE
        AFR::pkcs11_mbedtls
    )

    target_sources(
        afr_3rdparty_mbedtls
        INTERFACE
        "${afr_ports_dir}/pkcs11/hw_poll.c"
    )
    target_include_directories(afr_3rdparty_mbedtls INTERFACE
        "${cy_psoc6_dir}/psoc6csp/hal/include"
        "${cy_psoc6_dir}/psoc6csp/core_lib/include"
        "${cy_psoc6_dir}/psoc6pdl/cmsis/include"
        "${cy_psoc6_dir}/psoc6pdl/devices/include"
        "${cy_psoc6_dir}/psoc6pdl/drivers/include"
        "${cy_psoc6_dir}/psoc6csp/abstraction/rtos/include"
        "${cy_code_dir}"
    )

    target_include_directories(afr_3rdparty_lwip PUBLIC
        "${cy_psoc6_dir}/psoc6csp/hal/include"
        "${cy_psoc6_dir}/psoc6csp/core_lib/include"
        "${cy_psoc6_dir}/psoc6pdl/cmsis/include"
        "${cy_psoc6_dir}/psoc6pdl/devices/include"
        "${cy_psoc6_dir}/psoc6pdl/drivers/include"
        "${cy_whd_dir}/inc"
        "${cy_code_dir}"
        "${cy_psoc6_dir}/psoc6csp/abstraction/rtos/include"
    )


    #----------------------------------------------------------------
    # is SDIO supported?
    if(CYHAL_UDB_SDIO)
        target_include_directories(AFR::kernel::mcu_port INTERFACE
            "${cy_code_dir}/SDIO_HOST"
        )

        target_include_directories( AFR::secure_sockets::mcu_port INTERFACE
            "${cy_code_dir}/SDIO_HOST"
            )

        target_include_directories(afr_3rdparty_mbedtls PUBLIC
            "${cy_code_dir}/SDIO_HOST"
            )
    endif()

    #----------------------------------------------------------------
if(BLE_SUPPORTED)
    target_link_libraries(${AFR_TARGET_APP_NAME}  PUBLIC
        AFR::utils
        AFR::wifi
        AFR::wifi::mcu_port
        AFR::common
        AFR::ble
        AFR::ble_hal::mcu_port
        )
else()
    target_link_libraries(${AFR_TARGET_APP_NAME}  PUBLIC
        AFR::utils
        AFR::wifi
        AFR::wifi::mcu_port
        AFR::common
        )
endif()

    set(CMAKE_EXECUTABLE_SUFFIX ".elf" PARENT_SCOPE)

    # If we are using our own app, remove aws_demos and aws_tests directories
    # We want to keep the cy_code directory, save and restore those files to the list
    if(CY_ALTERNATE_APP)
        # Save the cy_code
        set(save_cy_code "${exe_src}")
        list(FILTER save_cy_code INCLUDE REGEX "cy_code")

        # filter out the default build app sources
        # Do both in aws_demos and aws_tests
        list(FILTER exe_src EXCLUDE REGEX "aws_demos")
        list(FILTER exe_src EXCLUDE REGEX "aws_tests")

        # add the saved cy_code back into the build
        set(exe_src "${exe_src}" "${save_cy_code}")

        #----------------------------------------------------------------
        # Remove unwanted modules from the build
        # Create a list in your <application_dir>/CMakeLists.txt file
        #
        # ex: set(CY_APP_DISABLE_AFR_MODULES
        #           "defender"
        #           "mqtt"
        #           "greengrass"
        #           )
        #
        foreach(module IN LISTS CY_APP_DISABLE_AFR_MODULES)
           # message("cy_kit_utils.cmake: disable module ${module}")
           afr_module_dependencies(${module} INTERFACE 3rdparty::does_not_exist)
        endforeach()

        #----------------------------------------------------------------
        # OTA SUPPORT
        #----------------------------------------------------------------
        if(OTA_SUPPORT)
            # Add OTA defines
            target_compile_definitions(${AFR_TARGET_APP_NAME} PUBLIC
                "-DOTA_SUPPORT=1"
                "-DMCUBOOT_KEY_FILE=${MCUBOOT_KEY_FILE}"
                "-DCY_FLASH_ERASE_VALUE=${CY_FLASH_ERASE_VALUE}"
                "-DMCUBOOT_HEADER_SIZE=${MCUBOOT_HEADER_SIZE}"
                "-DCY_BOOT_SCRATCH_SIZE=${CY_BOOT_SCRATCH_SIZE}"
                "-DCY_BOOT_BOOTLOADER_SIZE=${MCUBOOT_BOOTLOADER_SIZE}"
                "-DMCUBOOT_BOOTLOADER_SIZE=${MCUBOOT_BOOTLOADER_SIZE}"
                "-DCY_BOOT_PRIMARY_1_START=${CY_BOOT_PRIMARY_1_START}"
                "-DCY_BOOT_PRIMARY_1_SIZE=${CY_BOOT_PRIMARY_1_SIZE}"
                "-DCY_BOOT_SECONDARY_1_SIZE=${CY_BOOT_PRIMARY_1_SIZE}"
                "-DMCUBOOT_MAX_IMG_SECTORS=${MCUBOOT_MAX_IMG_SECTORS}"
                )

            #----------------------------------------------------------------
            # Add Linker options
            #
            if(MCUBOOT_HEADER_SIZE)
                if ("${AFR_TOOLCHAIN}" STREQUAL "arm-gcc")
                    target_link_options(${AFR_TARGET_APP_NAME} PUBLIC "-Wl,--defsym,MCUBOOT_HEADER_SIZE=${MCUBOOT_HEADER_SIZE}")
                elseif("${AFR_TOOLCHAIN}" STREQUAL "arm-armclang")
                    target_link_options(${AFR_TARGET_APP_NAME} PUBLIC "-Wl,--defsym,MCUBOOT_HEADER_SIZE=${MCUBOOT_HEADER_SIZE}")
                elseif("${AFR_TOOLCHAIN}" STREQUAL "arm-iar")
                    target_link_options(${AFR_TARGET_APP_NAME} PUBLIC "--defsym MCUBOOT_HEADER_SIZE=${MCUBOOT_HEADER_SIZE}")
                endif()
            endif()
            if(MCUBOOT_BOOTLOADER_SIZE)
                if ("${AFR_TOOLCHAIN}" STREQUAL "arm-gcc")
                    target_link_options(${AFR_TARGET_APP_NAME} PUBLIC "-Wl,--defsym,MCUBOOT_BOOTLOADER_SIZE=${MCUBOOT_BOOTLOADER_SIZE}")
                elseif("${AFR_TOOLCHAIN}" STREQUAL "arm-armclang")
                    target_link_options(${AFR_TARGET_APP_NAME} PUBLIC "-Wl,--defsym,MCUBOOT_BOOTLOADER_SIZE=${MCUBOOT_BOOTLOADER_SIZE}")
                elseif("${AFR_TOOLCHAIN}" STREQUAL "arm-iar")
                    target_link_options(${AFR_TARGET_APP_NAME} PUBLIC "--defsym MCUBOOT_BOOTLOADER_SIZE=${MCUBOOT_BOOTLOADER_SIZE}")
                endif()
            endif()
            if(CY_BOOT_PRIMARY_1_SIZE)
                if ("${AFR_TOOLCHAIN}" STREQUAL "arm-gcc")
                    target_link_options(${AFR_TARGET_APP_NAME} PUBLIC "-Wl,--defsym,CY_BOOT_PRIMARY_1_SIZE=${CY_BOOT_PRIMARY_1_SIZE}")
                elseif("${AFR_TOOLCHAIN}" STREQUAL "arm-armclang")
                    target_link_options(${AFR_TARGET_APP_NAME} PUBLIC "-Wl,--defsym,CY_BOOT_PRIMARY_1_SIZE=${CY_BOOT_PRIMARY_1_SIZE}")
                elseif("${AFR_TOOLCHAIN}" STREQUAL "arm-iar")
                    target_link_options(${AFR_TARGET_APP_NAME} PUBLIC "--defsym CY_BOOT_PRIMARY_1_SIZE=${CY_BOOT_PRIMARY_1_SIZE}")
                endif()
            endif()

            #----------------------------------------------------------------
            # Add AWS OTA Library

            afr_mcu_port(ota)

            # Add extra sources for our port
            target_sources(AFR::ota::mcu_port INTERFACE
                "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/boards/${AFR_BOARD_NAME}/ports/ota/aws_ota_pal.c"
                "${AFR_DEMOS_DIR}/demo_runner/aws_demo_version.c"
                "${AFR_DEMOS_DIR}/demo_runner/iot_demo_freertos.c"
                "${AFR_DEMOS_DIR}/demo_runner/iot_demo_runner.c"
                "${AFR_DEMOS_DIR}/network_manager/aws_iot_demo_network.c"
                "${AFR_DEMOS_DIR}/network_manager/aws_iot_network_manager.c"
                "${AFR_DEMOS_DIR}/ota/aws_iot_ota_update_demo.c"
                "${AFR_MODULES_FREERTOS_PLUS_DIR}/aws/ota/src/aws_iot_ota_agent.c"
                "${MCUBOOT_SIGNATURE_DIR}/signature.c"
                "${MCUBOOT_CYFLASH_PAL_DIR}/cy_flash_map.c"
                "${MCUBOOT_CYFLASH_PAL_DIR}/cy_flash_psoc6.c"
                "${MCUBOOT_BOOTUTIL_SRC_DIR}/bootutil_misc.c"
                )

            # add extra includes
            target_include_directories(AFR::ota::mcu_port INTERFACE
                "${AFR_DEMOS_DIR}/network_manager"
                "${AFR_MODULES_FREERTOS_PLUS_DIR}/standard/crypto/include"
                "${AFR_MODULES_ABSTRACTIONS_DIR}/wifi/include"
                "${MCUBOOT_CY_BOOTAPP_DIR}"
                "${MCUBOOT_BOOTAPP_CONFIG_DIR}"
                "${MCUBOOT_BOOTUTIL_INC_DIR}"
                "${MCUBOOT_CYFLASH_PAL_DIR}/include"
                "${cy_psoc6_dir}/psoc6csp/abstraction/rtos/include"
                "${cy_psoc6_dir}/psoc6pdl/cmsis/include"
                "${cy_psoc6_dir}/psoc6pdl/devices/include"
                "${cy_psoc6_dir}/psoc6pdl/drivers/include"
                "${aws_config_dir}"                                                 # for FreeRTOSconfig.h
                "${iot_common_include}"                                             # for iot_config_common.h
                "${cy_code_dir}"                                                    # for system_psoc6.h
                )

            # Add versioning defines
            target_compile_definitions(AFR::ota::mcu_port INTERFACE
                "-DAPP_VERSION_MAJOR=${APP_VERSION_MAJOR}"
                "-DAPP_VERSION_MINOR=${APP_VERSION_MINOR}"
                "-DAPP_VERSION_BUILD=${APP_VERSION_BUILD}"
                "-DMCUBOOT_HEADER_SIZE=${MCUBOOT_HEADER_SIZE}"
                "-DCY_BOOT_SCRATCH_SIZE=${CY_BOOT_SCRATCH_SIZE}"
                "-DCY_BOOT_BOOTLOADER_SIZE=${MCUBOOT_BOOTLOADER_SIZE}"
                "-DMCUBOOT_BOOTLOADER_SIZE=${MCUBOOT_BOOTLOADER_SIZE}"
                "-DCY_BOOT_PRIMARY_1_START=${CY_BOOT_PRIMARY_1_START}"
                "-DCY_BOOT_PRIMARY_1_SIZE=${CY_BOOT_PRIMARY_1_SIZE}"
                "-DCY_BOOT_SECONDARY_1_SIZE=${CY_BOOT_PRIMARY_1_SIZE}"
                "-DMCUBOOT_MAX_IMG_SECTORS=${MCUBOOT_MAX_IMG_SECTORS}"
                )

            # link libs to our app
            target_link_libraries(${AFR_TARGET_APP_NAME} PUBLIC
                "AFR::mqtt"
                "AFR::ota"
                "afr_dev_mode_key_provisioning"
                "AFR::pkcs11"
                )

            # extra includes for pkcs11 and the kernel
            target_include_directories(AFR::pkcs11_implementation::mcu_port INTERFACE
                "${MCUBOOT_FLASH_MAP_INC_DIR}"
                "${MCUBOOT_BOOTAPP_CONFIG_DIR}"
                )
            target_include_directories(AFR::kernel::mcu_port INTERFACE
                "${MCUBOOT_FLASH_MAP_INC_DIR}"
                "${MCUBOOT_BOOTAPP_CONFIG_DIR}"
                )

            #------------------------------------------------------------
            # Create our script filename in this scope
            set(SIGN_SCRIPT_FILE_PATH           "${CMAKE_BINARY_DIR}/sign_${AFR_TARGET_APP_NAME}.sh")
            set(CY_OUTPUT_FILE_PATH             "${CMAKE_BINARY_DIR}/${AFR_TARGET_APP_NAME}")
            set(CY_OUTPUT_FILE_PATH_ELF         "${CY_OUTPUT_FILE_PATH}.elf")
            set(CY_OUTPUT_FILE_PATH_HEX         "${CY_OUTPUT_FILE_PATH}.hex")
            set(CY_OUTPUT_FILE_PATH_SIGNED_HEX  "${CY_OUTPUT_FILE_PATH}.signed.hex")
            set(CY_OUTPUT_FILE_PATH_BIN         "${CY_OUTPUT_FILE_PATH}.bin")
            set(CY_OUTPUT_FILE_PATH_WILD        "${CY_OUTPUT_FILE_PATH}.*")

            # creates the script to call imgtool.py to sign the image
            config_cy_mcuboot_sign_script("${CMAKE_BINARY_DIR}")

            add_custom_command(
                TARGET "${AFR_TARGET_APP_NAME}" POST_BUILD
                WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E remove -f "${CY_OUTPUT_FILE_PATH_HEX}" "${CY_OUTPUT_FILE_PATH_SIGNED_HEX}" "${CY_OUTPUT_FILE_PATH_BIN}"
                COMMAND "${SIGN_SCRIPT_FILE_PATH}"
                )
            endif(OTA_SUPPORT)
    endif(CY_ALTERNATE_APP)

endfunction(cy_kit_generate)
