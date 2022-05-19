//#ifndef AWS_CLIENT_CREDENTIAL_KEYS_H
//#define AWS_CLIENT_CREDENTIAL_KEYS_H
//
//#include <stdint.h>
//
///*
// * PEM-encoded client certificate.
// *
// * Must include the PEM header and footer:
// * "-----BEGIN CERTIFICATE-----\n"\
// * "...base64 data...\n"\
// * "-----END CERTIFICATE-----"
// */
//#define keyCLIENT_CERTIFICATE_PEM \
//"-----BEGIN CERTIFICATE-----\n"\
//"MIIDWTCCAkGgAwIBAgIUAyepoCcPF3nUqxR5WRqSbWdvJaYwDQYJKoZIhvcNAQEL\n"\
//"BQAwTTFLMEkGA1UECwxCQW1hem9uIFdlYiBTZXJ2aWNlcyBPPUFtYXpvbi5jb20g\n"\
//"SW5jLiBMPVNlYXR0bGUgU1Q9V2FzaGluZ3RvbiBDPVVTMB4XDTIxMDMwMjE0NTc0\n"\
//"NFoXDTQ5MTIzMTIzNTk1OVowHjEcMBoGA1UEAwwTQVdTIElvVCBDZXJ0aWZpY2F0\n"\
//"ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM+2zY+Afb+ASKhWP3gi\n"\
//"QM2/Qn62e3LccwN+1ud20dLqJuUVu66S2Llnvt1A5RTVCjTrbLNz76fT+AbEUSdW\n"\
//"GgrV7rYRw5/TTqdZXbmObaEgF4DA75tOyKgPxv1+ReiSuWasvyDhMyD/zeVDuu67\n"\
//"QYMQ0paCmXbf17rD8ol20/5vpZ8PDFi8CUU5kEvcQKzRMtuQFp3KUljdf9m6pqwB\n"\
//"XAkPXW4vDONnreL831Q9QObQC3k2JdC13EfG9GaBVn68St5dI3X4s+vKaWbCUsZR\n"\
//"Oj5fwd6ExmYLoiUEWeuOquc+/r0EomAtmWN6UKyvmB+08sc+JQtSeyhcmWK8Vc6t\n"\
//"Y2UCAwEAAaNgMF4wHwYDVR0jBBgwFoAU/YuuArUpnqrRe08Dnb/CeKHgu/UwHQYD\n"\
//"VR0OBBYEFNPld2hdll/Y3H+/B4SBSoZVuFOMMAwGA1UdEwEB/wQCMAAwDgYDVR0P\n"\
//"AQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4IBAQAO0EmKLwQyF8G8M7UZwWDzI3Mk\n"\
//"IN4FQlE5K3juOYgcgI0SX98eYjLPFhKP2qrT2xRUjk99PpNmDbfmyFRvJeiNmsws\n"\
//"bgAg5G8f/sBswgfbll4Inj3eGPDLxBvwoa78zW7KZCoJQFkdZPtJD2MTCSmtHOC9\n"\
//"YbDNRgZ+cRPOhxzwW4CRLNFDve6YUjfegzAOR6dfeMJFPDOlAojAljTAFHo+/MaS\n"\
//"gUyjDf/v6vuSx0UALqn8hZoJ2oQY662UHTYzaDH4yNPy4JslKJqo2NwsgZK0vtGW\n"\
//"gCuE7wjeo1GVmjCvOEpmgb/dUKdzK6+C/MdtcqRv64cGgw6EEcI19IASEQBN\n"\
//"-----END CERTIFICATE-----"
//
///*
// * PEM-encoded client private key.
// *
// * Must include the PEM header and footer:
// * "-----BEGIN RSA PRIVATE KEY-----\n"\
// * "...base64 data...\n"\
// * "-----END RSA PRIVATE KEY-----"
// */
//#define keyCLIENT_PRIVATE_KEY_PEM \
//"-----BEGIN RSA PRIVATE KEY-----\n"\
//"MIIEpAIBAAKCAQEAz7bNj4B9v4BIqFY/eCJAzb9CfrZ7ctxzA37W53bR0uom5RW7\n"\
//"rpLYuWe+3UDlFNUKNOtss3Pvp9P4BsRRJ1YaCtXuthHDn9NOp1lduY5toSAXgMDv\n"\
//"m07IqA/G/X5F6JK5Zqy/IOEzIP/N5UO67rtBgxDSloKZdt/XusPyiXbT/m+lnw8M\n"\
//"WLwJRTmQS9xArNEy25AWncpSWN1/2bqmrAFcCQ9dbi8M42et4vzfVD1A5tALeTYl\n"\
//"0LXcR8b0ZoFWfrxK3l0jdfiz68ppZsJSxlE6Pl/B3oTGZguiJQRZ646q5z7+vQSi\n"\
//"YC2ZY3pQrK+YH7Tyxz4lC1J7KFyZYrxVzq1jZQIDAQABAoIBAEDIauRO1ulbQU3/\n"\
//"WFxHkp6ZAEw07dutFdIJRU17qYV2shrQ5HBWLHHnAYhQLSKKL1zB8G0nw588ZSb3\n"\
//"I7h5CjZG8uSmNbUrWmSnYqv02AxgzfPCOPjfYYXJJe756yPWXyy+w/2lPyUTo0vW\n"\
//"C/9ZN92A6a03nlWNCuOdKY/mF8hKyh65h/3xuoX2U0/gNBnVhIqniA/GU/TduApv\n"\
//"lO9A84jT3Jl+ChlriDU6cj+epqiH6Ob8b7iJm0Vxr+YuZxOh7x9GUcmB5v7VNbf2\n"\
//"cPEBkdnQIRie6KttQw8eJzbNuI2AglBrjd1sPtuKzqb7+IGrGM8Nci912JRk/+vT\n"\
//"CeEVXAECgYEA7UD/Q5qfpeOAbViC1mF/51curiq7daXYbOFgHKMOoneaL6xaiqzZ\n"\
//"uR9H8P6cyIyW1An4YwPbf9BFH/YghfJ2uGb4SW4kps9gXvjToImTIeDRlyzMwsd5\n"\
//"i7vuO1G/QLQRwzTC+5hblo6Ll3cT/FKc20ElEVHlwFRkdEvuqEl0+KECgYEA4CBL\n"\
//"nfczbWe5a9C83BdLtFHUswD0kGkN7hifFLhq0xiHclL7CfwriyYQ0SbS/YXTmaPg\n"\
//"mFrp8auL+539DdebNHe6ATWSUQjSydavXHoH51PPwi5DEdFlUavm2RpmUU+edLt7\n"\
//"r6+L67BwwAASC9l5Joa4krYEhpkVpgfWUsqqYEUCgYEA4vY4u41hiCpYo0H29+qR\n"\
//"ltdZ+pc6eVNL9OytKvf5egZ8Y3q3qs2sAmIgSjTn+xoy92kKSn5YLq8oUWj8t+a5\n"\
//"F7K5dlV9jm33vSLAIGU7cT9GgR4ES5jTd48yWWDcWqNoEpuYo2KeyypV83GgltLY\n"\
//"5w4szaLQ7OpOpso05pxO38ECgYEAhoQbnlWNsi485W7EyzvYHgO3KzB5mGrVB4AT\n"\
//"inYc91GTiZQwQ4/r+noAQeeRXsQBegcXd5mpK3kQbRYnmTU8W8M4Ch3DEYvAJ5AI\n"\
//"c/Jx5+8vlJX7fyg0LU6FIOxtWIP20Izt8UXlLrIZGcNxEVeXFP5qrPM9yCL9EUdG\n"\
//"5S3qEBkCgYBXv+eNfz6RCbQ/eqMMZRntoaP0pro33Y+4p+PONS98jRDrHjHzjkVY\n"\
//"L+ChT3O8oE91hovUhgMzt5DQT+2ZjeyTsUvyHtUN2HK7IXYSr8MpU6kcex9ylkcF\n"\
//"L29Na/XnOzi8C6NpA7jSnnsT0R0+OK/udEkBqxFZoa58GnqNuWowDA==\n"\
//"-----END RSA PRIVATE KEY-----"
//
///*
// * PEM-encoded Just-in-Time Registration (JITR) certificate (optional).
// *
// * If used, must include the PEM header and footer:
// * "-----BEGIN CERTIFICATE-----\n"\
// * "...base64 data...\n"\
// * "-----END CERTIFICATE-----"
// */
//#define keyJITR_DEVICE_CERTIFICATE_AUTHORITY_PEM  ""
//
//
//#endif /* AWS_CLIENT_CREDENTIAL_KEYS_H */
/*
 * FreeRTOS V202002.00
 * Copyright (C) 2020 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
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

#ifndef AWS_CLIENT_CREDENTIAL_KEYS_H
#define AWS_CLIENT_CREDENTIAL_KEYS_H

/*
 * @brief PEM-encoded client certificate.
 *
 * @todo If you are running one of the FreeRTOS demo projects, set this
 * to the certificate that will be used for TLS client authentication.
 *
 * @note Must include the PEM header and footer:
 * "-----BEGIN CERTIFICATE-----\n"\
 * "...base64 data...\n"\
 * "-----END CERTIFICATE-----\n"
 */
#define keyCLIENT_CERTIFICATE_PEM                   ""

/*
 * @brief PEM-encoded issuer certificate for AWS IoT Just In Time Registration (JITR).
 *
 * @todo If you are using AWS IoT Just in Time Registration (JITR), set this to
 * the issuer (Certificate Authority) certificate of the client certificate above.
 *
 * @note This setting is required by JITR because the issuer is used by the AWS
 * IoT gateway for routing the device's initial request. (The device client
 * certificate must always be sent as well.) For more information about JITR, see:
 *  https://docs.aws.amazon.com/iot/latest/developerguide/jit-provisioning.html,
 *  https://aws.amazon.com/blogs/iot/just-in-time-registration-of-device-certificates-on-aws-iot/.
 *
 * If you're not using JITR, set below to NULL.
 *
 * Must include the PEM header and footer:
 * "-----BEGIN CERTIFICATE-----\n"\
 * "...base64 data...\n"\
 * "-----END CERTIFICATE-----\n"
 */
#define keyJITR_DEVICE_CERTIFICATE_AUTHORITY_PEM    ""

/*
 * @brief PEM-encoded client private key.
 *
 * @todo If you are running one of the FreeRTOS demo projects, set this
 * to the private key that will be used for TLS client authentication.
 *
 * @note Must include the PEM header and footer:
 * "-----BEGIN RSA PRIVATE KEY-----\n"\
 * "...base64 data...\n"\
 * "-----END RSA PRIVATE KEY-----\n"
 */
#define keyCLIENT_PRIVATE_KEY_PEM                   ""

#endif /* AWS_CLIENT_CREDENTIAL_KEYS_H */
