/*
 * Amazon FreeRTOS V1.4.7
 * Copyright (C) 2017 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * http://aws.amazon.com/freertos
 * http://www.FreeRTOS.org
 */

/* FIX ME: If you are using Ethernet network connections and the FreeRTOS+TCP stack,
 * uncomment the define:
 * #define CY_USE_FREERTOS_TCP 1
 */

/* FreeRTOS includes. */
#include "FreeRTOS.h"
#include "task.h"

#ifdef CY_USE_LWIP
#include "lwip/tcpip.h"
#endif

/* Demo includes */
#include "aws_demo.h"

/* AWS library includes. */
#include "iot_system_init.h"
#include "iot_logging_task.h"
#include "iot_wifi.h"
#include "aws_clientcredential.h"
#include "aws_application_version.h"
#include "aws_dev_mode_key_provisioning.h"

/* START - Optiga Examples */

/* PKCS#11 includes. */
#include "iot_pkcs11_config.h"
#include "iot_pkcs11.h"
#include "iot_logging_task.h"

/* Includes for running the optiga examples */
#include "optiga_example.h"
#include "optiga/pal/pal_os_event.h"
#include "optiga/pal/pal_logger.h"
#include "optiga/pal/pal.h"
// Optional if you need to get the certificate from your OPTIGA sample
#include "get_optiga_certificate.h"

extern pal_logger_t logger_console;

/*******************************************************************************
* Function Prototypes
*******************************************************************************/
extern void example_optiga_crypt_hash (void);
extern void example_optiga_crypt_ecc_generate_keypair(void);
extern void example_optiga_crypt_ecdsa_sign(void);
extern void example_optiga_crypt_ecdsa_verify(void);
extern void example_optiga_crypt_ecdh(void);
extern void example_optiga_crypt_random(void);
extern void example_optiga_crypt_tls_prf_sha256(void);
extern void example_optiga_util_read_data(void);
extern void example_optiga_util_write_data(void);
extern void example_optiga_crypt_rsa_generate_keypair(void);
extern void example_optiga_crypt_rsa_sign(void);
extern void example_optiga_crypt_rsa_verify(void);
extern void example_optiga_crypt_rsa_decrypt_and_export(void);
extern void example_optiga_crypt_rsa_decrypt_and_store(void);
extern void example_optiga_crypt_rsa_encrypt_message(void);
extern void example_optiga_crypt_rsa_encrypt_session(void);
extern void example_optiga_util_update_count(void);
extern void example_optiga_util_protected_update(void);
extern void example_read_coprocessor_id(void);
extern void example_optiga_crypt_hash_data(void);
#ifdef OPTIGA_COMMS_SHIELDED_CONNECTION
extern void example_pair_host_and_optiga_using_pre_shared_secret(void);
#endif
extern void example_optiga_util_hibernate_restore(void);
extern void example_optiga_crypt_symmetric_encrypt_decrypt_ecb(void);
extern void example_optiga_crypt_symmetric_encrypt_decrypt_cbc(void);
extern void example_optiga_crypt_symmetric_encrypt_cbcmac(void);
extern void example_optiga_crypt_hmac(void);
extern void example_optiga_crypt_hkdf(void);
extern void example_optiga_crypt_symmetric_generate_key(void);
extern void example_optiga_hmac_verify_with_authorization_reference(void);
extern void example_optiga_crypt_clear_auto_state(void);

/* END - Optiga Examples */

/* BSP & Abstraction inclues */
#include "cybsp.h"
#include "cy_retarget_io.h"

#include "iot_network_manager_private.h"

#if BLE_ENABLED
    #include "bt_hal_manager_adapter_ble.h"
    #include "bt_hal_manager.h"
    #include "bt_hal_gatt_server.h"

    #include "iot_ble.h"
    #include "iot_ble_config.h"
    #include "iot_ble_wifi_provisioning.h"
    #include "iot_ble_numericComparison.h"

    #include "cyhal_uart.h"

    #define INPUT_MSG_ALLOC_SIZE             (50u)
    #define DELAY_BETWEEN_GETC_IN_TICKS      (1500u)
#endif

/* Logging Task Defines. */
#define mainLOGGING_MESSAGE_QUEUE_LENGTH    ( 15 )
#define mainLOGGING_TASK_STACK_SIZE         ( configMINIMAL_STACK_SIZE * 8 )

/* The task delay for allowing the lower priority logging task to print out Wi-Fi
 * failure status before blocking indefinitely. */
#define mainLOGGING_WIFI_STATUS_DELAY       pdMS_TO_TICKS( 1000 )

/* Unit test defines. */
#define mainTEST_RUNNER_TASK_STACK_SIZE     ( configMINIMAL_STACK_SIZE * 16 )

/* The name of the devices for xApplicationDNSQueryHook. */
#define mainDEVICE_NICK_NAME				"cypress_demo" /* FIX ME.*/

/* Length of the WIFI password saved in the optiga */
#define mainWIFI_PASSWORD_LENGTH 20


/* Static arrays for FreeRTOS-Plus-TCP stack initialization for Ethernet network
 * connections are declared below. If you are using an Ethernet connection on your MCU
 * device it is recommended to use the FreeRTOS+TCP stack. The default values are
 * defined in FreeRTOSConfig.h. */

#ifdef CY_USE_FREERTOS_TCP
/* Default MAC address configuration.  The application creates a virtual network
 * connection that uses this MAC address by accessing the raw Ethernet data
 * to and from a real network connection on the host PC.  See the
 * configNETWORK_INTERFACE_TO_USE definition for information on how to configure
 * the real network connection to use. */
const uint8_t ucMACAddress[ 6 ] =
{
    configMAC_ADDR0,
    configMAC_ADDR1,
    configMAC_ADDR2,
    configMAC_ADDR3,
    configMAC_ADDR4,
    configMAC_ADDR5
};

/* The default IP and MAC address used by the application.  The address configuration
 * defined here will be used if ipconfigUSE_DHCP is 0, or if ipconfigUSE_DHCP is
 * 1 but a DHCP server could not be contacted.  See the online documentation for
 * more information. */
static const uint8_t ucIPAddress[ 4 ] =
{
    configIP_ADDR0,
    configIP_ADDR1,
    configIP_ADDR2,
    configIP_ADDR3
};
static const uint8_t ucNetMask[ 4 ] =
{
    configNET_MASK0,
    configNET_MASK1,
    configNET_MASK2,
    configNET_MASK3
};
static const uint8_t ucGatewayAddress[ 4 ] =
{
    configGATEWAY_ADDR0,
    configGATEWAY_ADDR1,
    configGATEWAY_ADDR2,
    configGATEWAY_ADDR3
};
static const uint8_t ucDNSServerAddress[ 4 ] =
{
    configDNS_SERVER_ADDR0,
    configDNS_SERVER_ADDR1,
    configDNS_SERVER_ADDR2,
    configDNS_SERVER_ADDR3
};
#endif /* CY_USE_FREERTOS_TCP */

/**
 * @brief Application task startup hook for applications using Wi-Fi. If you are not
 * using Wi-Fi, then start network dependent applications in the vApplicationIPNetorkEventHook
 * function. If you are not using Wi-Fi, this hook can be disabled by setting
 * configUSE_DAEMON_TASK_STARTUP_HOOK to 0.
 */
void vApplicationDaemonTaskStartupHook( void );

/**
 * @brief Connects to Wi-Fi.
 */
static void prvWifiConnect( void );

/**
 * @brief Initializes the board.
 */
static void prvMiscInitialization( void );

static void vRunOptigaExamples( void );

/* Buffer to store the wifi password read from the optiga */
uint8_t wifi_password_buf[mainWIFI_PASSWORD_LENGTH] = {0};

/*-----------------------------------------------------------*/

/**
 * @brief Application runtime entry point.
 */
int main( void )
{
    /* Perform any hardware initialization that does not require the RTOS to be
     * running.  */
    prvMiscInitialization();

    /* Create tasks that are not dependent on the Wi-Fi being initialized. */
    xLoggingTaskInitialize( mainLOGGING_TASK_STACK_SIZE,
                            tskIDLE_PRIORITY,
                            mainLOGGING_MESSAGE_QUEUE_LENGTH );

#ifdef CY_USE_FREERTOS_TCP
    FreeRTOS_IPInit( ucIPAddress,
                     ucNetMask,
                     ucGatewayAddress,
                     ucDNSServerAddress,
                     ucMACAddress );
#endif /* CY_USE_FREERTOS_TCP */

    /* Start the scheduler.  Initialization that requires the OS to be running,
     * including the Wi-Fi initialization, is performed in the RTOS daemon task
     * startup hook. */
    vTaskStartScheduler();

    return 0;
}
/*-----------------------------------------------------------*/

static void prvMiscInitialization( void )
{
    cy_rslt_t result = cybsp_init();
    if (result != CY_RSLT_SUCCESS)
    {
        configPRINTF( (  "BSP initialization failed \r\n" ) );
    }
    result = cy_retarget_io_init(CYBSP_DEBUG_UART_TX, CYBSP_DEBUG_UART_RX, CY_RETARGET_IO_BAUDRATE);
    if (result != CY_RSLT_SUCCESS)
    {
        configPRINTF( ( "Retarget IO initializatoin failed \r\n" ) );
    }

    #if BLE_ENABLED
        NumericComparisonInit();
    #endif
}

/*-----------------------------------------------------------*/
void vRunOptigaExamples( void )
{
	CK_RV xResult = CKR_OK;
    CK_FUNCTION_LIST_PTR pxFunctionList = NULL;
    CK_SESSION_HANDLE xSession = 0;

    /* Create a pkcs token and open a session  */
    xResult = C_GetFunctionList( &pxFunctionList );

    /* Initialize the PKCS Module */
    if( xResult == CKR_OK )
    {
        xResult = xInitializePkcs11Token();
    }

    if( xResult == CKR_OK )
    {
        xResult = xInitializePkcs11Session( &xSession );
    }

    if( xResult == CKR_OK )
    {
    	example_optiga_hmac_verify_with_authorization_reference();

    	/* Close the pkcs connection */
        pxFunctionList->C_CloseSession( xSession );
    }
}

/*-----------------------------------------------------------*/
void vApplicationDaemonTaskStartupHook( void )
{
    /* FIX ME: Perform any hardware initialization, that require the RTOS to be
     * running, here. */

	//vRunOptigaExamples();

    /* FIX ME: If your MCU is using Wi-Fi, delete surrounding compiler directives to
    * enable the unit tests and after MQTT, Bufferpool, and Secure Sockets libraries
    * have been imported into the project. If you are not using Wi-Fi, see the
    * vApplicationIPNetworkEventHook function. */
    if( SYSTEM_Init() == pdPASS )
    {
        #ifdef CY_USE_LWIP
        /* Initialize lwIP stack. This needs the RTOS to be up since this function will spawn
            * the tcp_ip thread.
            */
        tcpip_init(NULL, NULL);
        #endif

        vGetOptigaCertificate();

        prvWifiConnect();

        vDevModeKeyProvisioning();

        /* Start the demo tasks. */
        DEMO_RUNNER_RunDemos();
    }
}

/*-----------------------------------------------------------*/

void prvWifiConnect( void )
{
    WIFINetworkParams_t xNetworkParams;
    WIFIReturnCode_t xWifiStatus;
    uint8_t ucTempIp[4] = { 0 };
   static BaseType_t xTasksAlreadyCreated = pdFALSE;

    xWifiStatus = WIFI_On();

    if( xWifiStatus == eWiFiSuccess )
    {

        configPRINTF( ( "Wi-Fi module initialized. Connecting to AP...\r\n" ) );
    }
    else
    {
        configPRINTF( ( "Wi-Fi module failed to initialize.\r\n" ) );

        /* Delay to allow the lower priority logging task to print the above status.
            * The while loop below will block the above printing. */
        vTaskDelay( mainLOGGING_WIFI_STATUS_DELAY );

        while( 1 )
        {
        }
    }

    /* Setup parameters. */
    xNetworkParams.pcSSID = clientcredentialWIFI_SSID;
    xNetworkParams.ucSSIDLength = sizeof( clientcredentialWIFI_SSID ) - 1;
    xNetworkParams.pcPassword = clientcredentialWIFI_PASSWORD;
    xNetworkParams.ucPasswordLength = sizeof( clientcredentialWIFI_PASSWORD ) - 1;
    xNetworkParams.xSecurity = clientcredentialWIFI_SECURITY;
    xNetworkParams.cChannel = 0;

    xWifiStatus = WIFI_ConnectAP( &( xNetworkParams ) );

    if( xWifiStatus == eWiFiSuccess )
    {
        configPRINTF( ( "Wi-Fi Connected to AP. Creating tasks which use network...\r\n" ) );

        xWifiStatus = WIFI_GetIP( ucTempIp );
        if ( eWiFiSuccess == xWifiStatus )
        {
            configPRINTF( ( "IP Address acquired %d.%d.%d.%d\r\n",
                            ucTempIp[ 0 ], ucTempIp[ 1 ], ucTempIp[ 2 ], ucTempIp[ 3 ] ) );
        }

        if( ( xTasksAlreadyCreated == pdFALSE ) && ( SYSTEM_Init() == pdPASS ) )
        {
            xTasksAlreadyCreated = pdTRUE;
        }
    }
    else
    {
        /* Connection failed, configure SoftAP. */
        configPRINTF( ( "Wi-Fi failed to connect to AP %s.\r\n", xNetworkParams.pcSSID ) );

        xNetworkParams.pcSSID = wificonfigACCESS_POINT_SSID_PREFIX;
        xNetworkParams.pcPassword = wificonfigACCESS_POINT_PASSKEY;
        xNetworkParams.xSecurity = wificonfigACCESS_POINT_SECURITY;
        xNetworkParams.cChannel = wificonfigACCESS_POINT_CHANNEL;

        configPRINTF( ( "Connect to SoftAP %s using password %s. \r\n",
                        xNetworkParams.pcSSID, xNetworkParams.pcPassword ) );

        while( WIFI_ConfigureAP( &xNetworkParams ) != eWiFiSuccess )
        {
            configPRINTF( ( "Connect to SoftAP %s using password %s and configure Wi-Fi. \r\n",
                            xNetworkParams.pcSSID, xNetworkParams.pcPassword ) );
        }

        configPRINTF( ( "Wi-Fi configuration successful. \r\n" ) );
    }
}

/*-----------------------------------------------------------*/

/**
 * @brief User defined Idle task function.
 *
 * @note Do not make any blocking operations in this function.
 */
void vApplicationIdleHook( void )
{
    /* FIX ME. If necessary, update to application idle periodic actions. */

    static TickType_t xLastPrint = 0;
    TickType_t xTimeNow;
    const TickType_t xPrintFrequency = pdMS_TO_TICKS( 5000 );

    xTimeNow = xTaskGetTickCount();

    if( ( xTimeNow - xLastPrint ) > xPrintFrequency )
    {
        configPRINT( "." );
        xLastPrint = xTimeNow;
    }
}

void vApplicationTickHook()
{
	pal_os_event_trigger_registered_callback();
}

/*-----------------------------------------------------------*/

/**
* @brief User defined application hook to process names returned by the DNS server.
*/
#if ( ipconfigUSE_LLMNR != 0 ) || ( ipconfigUSE_NBNS != 0 )
    BaseType_t xApplicationDNSQueryHook( const char * pcName )
    {
        /* FIX ME. If necessary, update to applicable DNS name lookup actions. */

        BaseType_t xReturn;

        /* Determine if a name lookup is for this node.  Two names are given
         * to this node: that returned by pcApplicationHostnameHook() and that set
         * by mainDEVICE_NICK_NAME. */
        if( strcmp( pcName, pcApplicationHostnameHook() ) == 0 )
        {
            xReturn = pdPASS;
        }
        else if( strcmp( pcName, mainDEVICE_NICK_NAME ) == 0 )
        {
            xReturn = pdPASS;
        }
        else
        {
            xReturn = pdFAIL;
        }

        return xReturn;
    }

#endif /* if ( ipconfigUSE_LLMNR != 0 ) || ( ipconfigUSE_NBNS != 0 ) */
/*-----------------------------------------------------------*/

/**
 * @brief User defined assertion call. This function is plugged into configASSERT.
 * See FreeRTOSConfig.h to define configASSERT to something different.
 */
void vAssertCalled(const char * pcFile,
	uint32_t ulLine)
{
    /* FIX ME. If necessary, update to applicable assertion routine actions. */

	const uint32_t ulLongSleep = 1000UL;
	volatile uint32_t ulBlockVariable = 0UL;
	volatile char * pcFileName = (volatile char *)pcFile;
	volatile uint32_t ulLineNumber = ulLine;

	(void)pcFileName;
	(void)ulLineNumber;

	printf("vAssertCalled %s, %ld\n", pcFile, (long)ulLine);
	fflush(stdout);

	/* Setting ulBlockVariable to a non-zero value in the debugger will allow
	* this function to be exited. */
	taskDISABLE_INTERRUPTS();
	{
		while (ulBlockVariable == 0UL)
		{
			vTaskDelay( pdMS_TO_TICKS( ulLongSleep ) );
		}
	}
	taskENABLE_INTERRUPTS();
}
/*-----------------------------------------------------------*/

/**
 * @brief User defined application hook need by the FreeRTOS-Plus-TCP library.
 */
#if ( ipconfigUSE_LLMNR != 0 ) || ( ipconfigUSE_NBNS != 0 ) || ( ipconfigDHCP_REGISTER_HOSTNAME == 1 )
    const char * pcApplicationHostnameHook(void)
    {
        /* FIX ME: If necessary, update to applicable registration name. */

        /* This function will be called during the DHCP: the machine will be registered
         * with an IP address plus this name. */
        return clientcredentialIOT_THING_NAME;
    }

#endif

#if BLE_ENABLED
    /**
     * @brief "Function to receive user input from a UART terminal. This function reads until a line feed or 
     * carriage return character is received and returns a null terminated string through a pointer to INPUTMessage_t.
     * 
     * @note The line feed and carriage return characters are removed from the returned string.
     * 
     * @param pxINPUTmessage Message structure using which the user input and the message size are returned.
     * @param xAuthTimeout Time in ticks to be waited for the user input.
     * @returns pdTrue if the user input was successfully captured, else pdFalse.
     */
    BaseType_t getUserMessage( INPUTMessage_t * pxINPUTmessage, TickType_t xAuthTimeout )
    {
        BaseType_t xReturnMessage = pdFALSE;
        TickType_t xTimeOnEntering;
        uint8_t *ptr;
        uint32_t numBytes = 0;
        uint8_t msgLength = 0;

        /* Dynamically allocate memory to store user input. */
        pxINPUTmessage->pcData = ( uint8_t * ) pvPortMalloc( sizeof( uint8_t ) * INPUT_MSG_ALLOC_SIZE ); 

        /* ptr points to the memory location where the next character is to be stored. */
        ptr = pxINPUTmessage->pcData;   

        /* Store the current tick value to implement a timeout. */
        xTimeOnEntering = xTaskGetTickCount();

        do
        {
            /* Check for data in the UART buffer with zero timeout. */
            numBytes = cyhal_uart_readable(&cy_retarget_io_uart_obj);
            if (numBytes > 0)
            {
                /* Get a single character from UART buffer. */
                cyhal_uart_getc(&cy_retarget_io_uart_obj, ptr, 0);

                /* Stop checking for more characters when line feed or carriage return is received. */
                if((*ptr == '\n') || (*ptr == '\r'))
                {
                    *ptr = '\0';
                    xReturnMessage = pdTRUE;
                    break;
                }

                ptr++;
                msgLength++;

                /* Check if the allocated buffer for user input storage is full. */
                if (msgLength >= INPUT_MSG_ALLOC_SIZE) 
                {
                    break;
                }
            }

            /* Yield to other tasks while waiting for user data. */
            vTaskDelay( DELAY_BETWEEN_GETC_IN_TICKS );

        } while ((xTaskGetTickCount() - xTimeOnEntering) < xAuthTimeout); /* Wait for user data until timeout period is elapsed. */

        if (xReturnMessage == pdTRUE)
        {
            pxINPUTmessage->xDataSize = msgLength;
        }
        else if (msgLength >= INPUT_MSG_ALLOC_SIZE)
        {
            configPRINTF( ( "User input exceeds buffer size !!\n" ) );
        }
        else
        {
            configPRINTF( ( "Timeout period elapsed !!\n" ) );
        }       

        return xReturnMessage;
    }

#endif /* if BLE_ENABLED */  
