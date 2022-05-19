# Security Use Cases for CyberSecurity Labelling Scheme

1. [About](#about)
3. [Security Use Cases for CLS  Scheme](#use_cases) 
    - [UC1 - Pairing OPTIGA Trust M with Host MCU (Pre-shared Secret Based)](#uc1)
    - [UC2 - Secured I2C BusCommunication](#uc2)
    - [UC3 - Secured Storage](#uc3)
    - [UC4 - Secured Device Identity](#uc4)
    - [UC5 - Secured Key Generation and CSR](#uc5)
    - [UC6 - Registration and On-Boarding to Cloud ](#uc6)
    - [UC7 -Establishing SecuredCommunication to Cloud](#uc7)
    - [UC8 - Decommissioning](#uc8)
      - [UC8.1 - Temporary Decommissioning](#uc8.1)
      - [UC8.2 - Permanent Decommissioning](#uc8.2)

## <a name="about"></a>About

This README is focusing on the use cases for CyberSecurity Labelling Scheme. For Getting started and first building library, please refer to the README under directory "linux-optiga-trust-m"

## <a name="use_cases"></a>Security Use Cases for CLS  Scheme

### <a name="uc1"></a>UC1 - Pairing OPTIGA Trust M with Host MCU

The objective of this use case is to generate a pre-shared secret between the Host MCU and the OPTIGATM Trust M so that the Host MCU and OPTIGATM Trust M will be able to cryptographically authenticate each other and prevent the attack scenario of the authorized removal of the OPTIGATM Trust M from the device to clone and illegal device.

To pair the host with OPTIGA™ Trust M, please run the test script "pairing_host_with_trustm_provision.sh" inside "**linux-optiga-trust-m/scripts/UC1**" to write the default shared secret into OPTIGA™ Trust M. 

In this example, 0xe0e8 is used as the trust anchor OID,0xe140 is the OID to store Shared Platform Binding Secret.

```console
foo@bar:~/linux-optiga-trust-m/scripts/UC1 $ ./pairing_host_with_trustm_provision.sh 
```

After running the script, the metadata of OID 0xe140 will be:

```console
Shared Platform Binding Secret. [0xe140] 
[Size 0043] : 
	20 29 C0 01 01 C1 02 00 00 C4 01 40 C5 01 40 D0 
	07 E1 FC 07 FE 20 E1 40 D1 03 E1 FC 07 D3 01 00 
	D8 03 21 E0 E8 E8 01 22 F0 01 01 
	LcsO:0x01, Version:0000, Max Size:64, Used Size:64, Change:LcsO<0x07||Conf-0xE140, Read:LcsO<0x07, Execute:ALW, MUD:Int-0xE0E8, Data Type:PTFBIND, Reset Type:SETCRE, 
```

Once you change the Lcso to 0x07(Operational State), the binding secret can not be read out or change. Only Integrity protection(0Xe0e8) can reset Lcso to 0x01(Creation State) or 0x03(Initialization State).

### <a name="uc2"></a>UC2 - Secured I2C Bus Communication

This use case demonstrates how to establish aprotected communication (aka Shielded Connection) on the I2C bus between theHost MCU and the OPTIGATM Trust M so that data being transferbetween the MCU and Trust M will be protected by encryption.

TheShielded Connection feature is actually implement in the I2C protocol driverthat is provided by Infineon as part of the OPTIGATM Trust M hostcode library.

All commands in the linux tools for OPTIGA Trust M are with "**Shielded Connection Enabled**" and hence will increase the security counter by one. It is at the user discretion to disable "**Shielded Connection**" by using "**-X**" option if required by the application.   

Run the test script "AC_conf_e140_test.sh " inside "**linux-optiga-trust-m/scripts/UC2**"

```console
foo@bar:~/linux-optiga-trust-m/scripts/UC2 $ ./AC_conf_e140_test.sh 
```

After running this script, the metadata for target OID has been set as shown as below:

	========================================================
	App DataStrucObj type 3     [0xF1D6] 
	[Size 0021] : 
	20 13 C0 01 01 C4 01 8C C5 01 64 D0 03 20 E1 40 
	D1 03 20 E1 40 
	LcsO:0x01, Max Size:140, Used Size:100, Change:Conf-0xE140, Read:Conf-0xE140, 
	========================================================

Only the paired host can read/write data into this OID.

### <a name="uc3"></a>UC3 - Secured Storage

This use case demonstrates how to establish the OPTIGA Trust M as a secured storage for user cryptographic keys and credentials by using hmac verify functions

Run the test script "hmac_authenticated_storage_provisioning_step1.sh " inside "**linux-optiga-trust-m/scripts/UC3**" to do the provision for secret OID(set the data object type to  AUTOREF, data object 0xf1d0 is used in this Example) and Target OID(data object 0xf1d5 is used in this Example)

After the provision, the metadata for secret OID(0xf1d0) is shown as below:

```console
foo@bar:~/linux-optiga-trust-m $ ./bin/trustm_metadata -r 0xf1d0 
========================================================
App DataStrucObj type 3     [0xF1D0] 
[Size 0027] : 
	20 19 C0 01 01 C4 01 8C C5 01 40 D0 03 E1 FC 07 
	D1 03 E1 FC 07 D3 01 00 E8 01 31 
	LcsO:0x01, Max Size:140, Used Size:64, Change:LcsO<0x07, Read:LcsO<0x07, Execute:ALW, Data Type:AUTHREF, 

========================================================
```

After the provision, the metadata for target OID(0xf1d5) is shown as below:

```console
========================================================
App DataStrucObj type 3     [0xF1D5] 
[Size 0021] : 
	20 13 C0 01 01 C4 01 8C C5 01 20 D0 03 23 F1 D0 
	D1 03 23 F1 D0 
	LcsO:0x01, Max Size:140, Used Size:32, Change:Auto-0xF1D0, Read:Auto-0xF1D0, 

========================================================
```

Run "hmac_authenticated_read_write_step2.sh" inside "**linux-optiga-trust-m/scripts/UC3**"  to write in or readout the data in target OID after hmac verify successfully. 

The output is shown as below:

```console
Step2: Read out data after HMAC verify sucessfully

Input Secret OID: 0xF1D0
Target OID: 0xF1D5
output the data stored inside target OID. 
========================================================
HMAC Type         : 0x0020 
Output File Name : data_f1d5.bin 
HMAC verified successfully 
Read data from target OID successfully 
Data inside target OID :
	49 C9 F4 92 A9 92 F6 D4 C5 4F 5B 12 C5 7E DB 27 
	CE D2 24 04 8F 25 48 2A A1 49 C9 F4 92 A9 92 F6 
	
========================================================
```

### <a name="uc4"></a>UC4 - Secured Device Identity

This use case(Performing External Secured Device Identity Verification using TLS as example) is implemented with UC5 together and will showcase how to establish a TLS session with the cloud or server based on the implementation of UC5 using cipher suites.

Customer can choose to use Infineon default device certificate (OID: 0xE0E0) or the customer defined device certificate (OID: to be advised by customer) to verify the identity of the device with the cloud and/or server.

The detailed implementation are shown in the script under directory UC4-UC5-UC6-UC7.

### <a name="uc5"></a>UC5 - Secured Key Generation and CSR

This use case demonstrates how to perform a secure key (ECC) generation for cloud communication and perform a Certificate Signing Request (CSR) for this newly generate key pair.

Example : Generating a certificate request using OID 0xE0F1 with new key generated, ECC 256 key length and Auth/Enc/Sign usage 

```console
foo@bar:~$ openssl req -keyform engine -engine trustm_engine -key 0xe0f1:^:NEW:0x03:0x13 -new -out client1_e0f1.csr -subj /CN=trustm_cls
engine "trustm_engine" set.
```

client1_e0f1.csr can be displayed as below: 

```console
foo@bar:~$openssl req -in client1_e0f1.csr -text
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: CN = trustm_cls
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:64:67:e3:7d:03:97:7d:20:32:27:78:c4:49:38:
                    cf:64:8e:ab:63:49:36:1b:73:6a:40:0a:a5:33:57:
                    7e:b9:66:92:4a:96:3a:92:76:f7:2c:99:39:0f:d4:
                    a3:7d:bc:74:f1:73:dd:3b:c8:a9:95:59:39:7b:b8:
                    c1:c9:0d:61:79
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        Attributes:
            a0:00
    Signature Algorithm: ecdsa-with-SHA256
         30:46:02:21:00:c3:4d:31:c8:73:b1:d2:91:27:19:47:8a:87:
         6d:33:7b:85:44:5a:2e:4a:82:cf:e0:c3:ab:76:97:03:2e:42:
         0a:02:21:00:d4:8e:4f:b8:f8:5e:be:12:6c:81:ec:44:e7:ed:
         b7:b3:e7:ff:5d:3b:48:a1:2e:52:fb:a4:a1:af:fa:d9:a9:5f
-----BEGIN CERTIFICATE REQUEST-----
MIHQMHcCAQAwFTETMBEGA1UEAwwKdHJ1c3RtX2NsczBZMBMGByqGSM49AgEGCCqG
SM49AwEHA0IABGRn430Dl30gMid4xEk4z2SOq2NJNhtzakAKpTNXfrlmkkqWOpJ2
9yyZOQ/Uo328dPFz3TvIqZVZOXu4wckNYXmgADAKBggqhkjOPQQDAgNJADBGAiEA
w00xyHOx0pEnGUeKh20ze4VEWi5Kgs/gw6t2lwMuQgoCIQDUjk+4+F6+EmyB7ETn
7bez5/9dO0ihLlL7pKGv+tmpXw==
-----END CERTIFICATE REQUEST-----
```

### <a name="uc6"></a>UC6 - Registration and On-Boarding to Cloud

In this use case, we will use the key and device certificate that was generated in **step1_generate_keys.sh** to register the device to the respective cloud service provider.

As the cloud registration process is highly dependent on the service provider, we provide an example using AWS 

Please refer to the README under directory **infineon-kits-cls/psoc62-optiga-cls**

### <a name="uc7"></a>UC7 - Establishing Secured Communication to Cloud

In this use case, we will use the key and device certificate that was generated in section 5.5. to register the device to the respective cloud service provider.

As the cloud registration process is highly dependent on the service provider, we provide an example using AWS 

Please refer to the README under directory **infineon-kits-cls/psoc62-optiga-cls**

### <a name="uc8"></a>UC8 - Decommissioning

This use case demonstrates the necessary steps to permanently/temporarily disable the user data objects on the OPTIGA Trust M as part of the device decommissioning process.

#### <a name="uc8-1"></a>UC8.1 - Temporary Decommissioning

Temporary decommissioning addresses the scenario when the device is removed for maintenance purposed.  In this case, the device keys and user data need to be temporarily blocked, but needs to be re-enabled later when the device is put into service.

The following example shows how to do temporary decommissioning by using Integrity Protected Update for data object. 

1. Write Trust Anchor into the data object(can choose from 0xE0E1-0xE0E3, 0xE0E8-0XE0E9) and change the data object type to TA.

   In the test script "**temporary_decommissioning_provisioning_step1.sh**" inside  "**linux-optiga-trust-m/scripts/UC8/temporary_decommissioning/**", the data object 0xE0E8 is used to store the trust anchor. The metadata of the trust anchor OID can be set as shown in the test script: 

   ```console
   # Trust Anchor metadata setting
   TRUST_ANCHOR_META="2003E80111"
   ```

   E8 means data object Type, the following "01" means the length of the coming data, and the last"11" means Trust Anchor type.

   After running  "**temporary_decommissioning_provisioning_step1.sh**", the data object type is set to Trust Anchor. 

   ```console
   foo@bar:~$ ./bin/trustm_metadata -r 0xe0e8
   ========================================================
   Root CA Public Key Cert1    [0xE0E8] 
   [Size 0027] : 
   	20 19 C0 01 01 C4 02 04 B0 C5 02 02 5C D0 03 E1 
   	FC 07 D1 01 00 D3 01 00 E8 01 11 
   	LcsO:0x01, Max Size:1200, Used Size:604, Change:LcsO<0x07, Read:ALW, Execute:ALW, Data Type:TA, 

   ========================================================
   ```

   For detailed data object type, please refer to Table70(Page100) in https://github.com/Infineon/optiga-trust-m/blob/trust_m1_m3/documents/OPTIGA_Trust_M_Solution_Reference_Manual_v3.15.pdf

   For detailed metadata associated with data and key objects, please refer to Table74(Page106) in https://github.com/Infineon/optiga-trust-m/blob/trust_m1_m3/documents/OPTIGA_Trust_M_Solution_Reference_Manual_v3.15.pdf

2. Write Protected Update Secret into the data object(can choose from 0xF1D0, 0xF1D4-0XF1DB) and change the data object type to UPDATSEC.

   In the test script "**temporary_decommissioning_provisioning_step1.sh**" inside  "**linux-optiga-trust-m/scripts/UC8/temporary_decommissioning/**", the data object 0xF1D4 is used to store the protected update secret. The metadata of the protected update secret OID can be set as shown in the test script: 

   ```console
   # Protected Update OID metadata setting
   PROTECTED_UPDATE_SECRET_META="200BD103E1FC07D30100E80123"
   ```

   E8 means data object Type, the following "01" means the length of the coming data, and the last"23" means Protected Update Secret type.

   After running  "**temporary_decommissioning_provisioning_step1.sh**", the data object type is set to Protected Update Secret. 

   ```console
   foo@bar:~$ ./bin/trustm_metadata -r 0xf1d4
   App DataStrucObj type 3     [0xF1D4] 
   [Size 0027] : 
   	20 19 C0 01 01 C4 01 8C C5 01 40 D0 03 E1 FC 07 
   	D1 03 E1 FC 07 D3 01 00 E8 01 23 
   	LcsO:0x01, Max Size:140, Used Size:64, Change:LcsO<0x07, Read:LcsO<0x07, Execute:ALW, Data Type:UPDATSEC, 
   ```

   For detailed data object type, please refer to Table70(Page100) in https://github.com/Infineon/optiga-trust-m/blob/trust_m1_m3/documents/OPTIGA_Trust_M_Solution_Reference_Manual_v3.15.pdf

   For detailed metadata associated with data and key objects, please refer to Table74(Page106) in https://github.com/Infineon/optiga-trust-m/blob/trust_m1_m3/documents/OPTIGA_Trust_M_Solution_Reference_Manual_v3.15.pdf

3. Write test data into the target data object and change the metadata of the target OID accordingly. The version number,metadata update descriptor and Reset type are the parts which are needed to be changed. The metadata of the Target OID can be set as shown in the test script: 

   ```console
   # Target OID metadata setting for protected update 
   TARGET_OID_META="2010C1020000F00101D80721${TRUST_ANCHOR_OID}FD20${PROTECTED_UPDATE_SECRET_OID}"
   ```

   C1 means the version number, the following "02" means the length of the coming data, and the following"0000" the means version number is "0000".

   F0 means Reset type, the following "01" means the length of the coming data, and the following"11" means bring back to creation state and flush the data inside.

   D8 means metadata Update descriptor, this  tag  defines  the  condition  under  which  the  metadata update is permitted. The following "03" means the length of the coming data."21" means integrity protection," *${TRUST_ANCHOR_OID" is the OID}"* used to store Trust Anchor,"20" means confidentiality protection,"${PROTECTED_UPDATE_SECRET_OID}"is the OID used to store Protected Update Secret.

   For detailed metadata associated with data and key objects, please refer to Table74(Page106) in https://github.com/Infineon/optiga-trust-m/blob/trust_m1_m3/documents/OPTIGA_Trust_M_Solution_Reference_Manual_v3.15.pdf

   After running  "**temporary_decommissioning_provisioning_step1.sh**", the metadata of target OID should be like this: 

   ```console
   foo@bar:~$ ./bin/trustm_metadata -r 0xe0e1
   ========================================================
   Device Public Key           [0xE0E1] 
   [Size 0043] : 
   	20 29 C0 01 01 C1 02 00 00 C4 02 06 C0 C5 02 00 
   	40 D0 03 E1 FC 07 D1 01 00 D3 01 00 D8 07 21 E0 
   	E8 FD 20 F1 D4 E8 01 12 F0 01 01 
   	LcsO:0x01, Version:0000, Max Size:1728, Used Size:64, Change:LcsO<0x07, Read:ALW, Execute:ALW, MUD:Int-0xE0E8&&Conf-0xF1D4, Data Type:DEVCERT, Reset Type:SETCRE, 

   ========================================================
   ```

4. Set the Lcso to Operational state by running the command below:

   ```console
   foo@bar:~$ ./bin/trustm_metadata -w 0xe0e1 -O
   ========================================================
   Device Public Key           [0xE0E1] 

   	20 03 C0 01 07 	
   	LcsO:0x07, 
   Write Success.
   ========================================================
   ```

   The metadata of the target OID is shown as below:

   ```console
   foo@bar:~$ ./bin/trustm_metadata -r 0xe0e1 
   ========================================================
   Device Public Key           [0xE0E1] 
   [Size 0043] : 
   	20 29 C0 01 01 C1 02 00 00 C4 02 06 C0 C5 02 00 
   	40 D0 03 E1 FC 07 D1 01 00 D3 01 00 D8 07 21 E0 
   	E8 FD 20 F1 D4 E8 01 12 F0 01 01 
   	LcsO:0x07, Version:0000, Max Size:1728, Used Size:64, Change:LcsO<0x07, Read:ALW, Execute:ALW, MUD:Int-0xE0E8&&Conf-0xF1D4, Data Type:DEVCERT, Reset Type:SETCRE, 
   ========================================================
   ```

5. Change LcsO to Termination State to remove the device(temporary decommissioning )

6. Run the command to get the correct manifest and fragment 

   1. Go to  "**\linux-optiga-trust-m\ex_protected_update_data_set/Linux**" and open command prompt

   2. Run this example command:

      ```shell
      foo@bar:~/linux-optiga-trust-m/ex_protected_update_data_set/Linux $ ./bin/trustm_protected_update_set payload_version=3 trust_anchor_oid=E0E8 target_oid=E0E1 sign_algo=ES_256 priv_key=../samples/integrity/sample_ec_256_priv.pem payload_type=metadata metadata=../samples/payload/metadata/metadata.txt content_reset=0 secret=../samples/confidentiality/secret.txt label="test" enc_algo="AES-CCM-16-64-128" secret_oid=F1D4
      ```

      Note:

      1. There are some options to configure in this command. For more details, please go to https://github.com/Infineon/optiga-trust-m/tree/master/examples/tools/protected_update_data_set
      2. The example metadata.txt used here as sample is: 200BC00101D10100D003E1FC07
      3. The private key for sample_ec_256_cert.pem and metadata.txt must be available in the corresponding folder

7. Convert the manifest and fragment to manifest.dat and fragment.dat file

8. Use the manifest and fragment as input for trustm_protected_update as stated in "**temporary_decommissioning_step2.sh **"under "**linux-optiga-trust-m/scripts/UC8/temporary_decommissioning/**"

   If the protected update is successful, Lcso of this data object will be changed back to creation state and the certificate inside the target data object will be flushed.

   ```console
   ========================================================
   Device Public Key           [0xE0E1] 
   [Size 0043] : 
   	20 29 C0 01 01 C1 02 00 00 C4 02 06 C0 C5 02 00 
   	40 D0 03 E1 FC 07 D1 01 00 D3 01 00 D8 07 21 E0 
   	E8 FD 20 F1 D4 E8 01 12 F0 01 01 
   	LcsO:0x01, Version:0003, Max Size:1728, Used Size:64, Change:LcsO<0x07, Read:ALW, Execute:ALW, MUD:Int-0xE0E8&&Conf-0xF1D4, Data Type:DEVCERT, Reset Type:SETCRE, 
   ========================================================
   ```

Note: For detailed use case, please refer to the sample test scripts inside  "**linux-optiga-trust-m/scripts/UC8/temporary_decommissioning**/"

<a name="uc8.2"></a>UC8.2 - permanent decommissioning

Permanent decommissioning addresses the scenario when the device has to be permanently deactivated due to end of life.  In this case, the keys and sensitive user data has to be permanently deleted and data objects blocked.

The following example shows how to do temporary decommissioning by using Integrity Protected Update for data object. 

1. Write Trust Anchor into the data object(can choose from 0xE0E1-0xE0E3, 0xE0E8-0XE0E9) and change the data object type to TA.

   In the test script "**permanent_decommissioning_provisioning_step1.sh**" inside  "**linux-optiga-trust-m/scripts/UC8/permanent_decommissioning/**", the data object 0xE0E8 is used to store the trust anchor. The metadata of the trust anchor OID can be set as shown in the test script: 

   ```console
   # Trust Anchor metadata setting
   TRUST_ANCHOR_META="2003E80111"
   ```

   E8 means data object Type, the following "01" means the length of the coming data, and the last"11" means Trust Anchor type.

   After running  "**permanent_decommissioning_provisioning_step1.sh**", the data object type is set to Trust Anchor. 

   ```console
   foo@bar:~$ ./bin/trustm_metadata -r 0xe0e8
   ========================================================
   Root CA Public Key Cert1    [0xE0E8] 
   [Size 0027] : 
   	20 19 C0 01 01 C4 02 04 B0 C5 02 02 5C D0 03 E1 
   	FC 07 D1 01 00 D3 01 00 E8 01 11 
   	LcsO:0x01, Max Size:1200, Used Size:604, Change:LcsO<0x07, Read:ALW, Execute:ALW, Data Type:TA, 

   ========================================================
   ```

   For detailed data object type, please refer to Table70(Page100) in https://github.com/Infineon/optiga-trust-m/blob/trust_m1_m3/documents/OPTIGA_Trust_M_Solution_Reference_Manual_v3.15.pdf

   For detailed metadata associated with data and key objects, please refer to Table74(Page106) in https://github.com/Infineon/optiga-trust-m/blob/trust_m1_m3/documents/OPTIGA_Trust_M_Solution_Reference_Manual_v3.15.pdf

2. Write Protected Update Secret into the data object(can choose from 0xF1D0, 0xF1D4-0XF1DB) and change the data object type to UPDATSEC.

   In the test script "**permanent_decommissioning_provisioning_step1.sh**" inside  "**linux-optiga-trust-m/scripts/UC8/permanent_decommissioning/**", the data object 0xF1D4 is used to store the protected update secret. The metadata of the protected update secret OID can be set as shown in the test script: 

   ```console
   # Protected Update OID metadata setting
   PROTECTED_UPDATE_SECRET_META="200BD103E1FC07D30100E80123"
   ```

   E8 means data object Type, the following "01" means the length of the coming data, and the last"23" means Protected Update Secret type.

   After running  "**permanent_decommissioning_provisioning_step1.sh**", the data object type is set to Protected Update Secret. 

   ```console
   foo@bar:~$ ./bin/trustm_metadata -r 0xf1d4
   App DataStrucObj type 3     [0xF1D4] 
   [Size 0027] : 
   	20 19 C0 01 01 C4 01 8C C5 01 40 D0 03 E1 FC 07 
   	D1 03 E1 FC 07 D3 01 00 E8 01 23 
   	LcsO:0x01, Max Size:140, Used Size:64, Change:LcsO<0x07, Read:LcsO<0x07, Execute:ALW, Data Type:UPDATSEC, 
   ```

   For detailed data object type, please refer to Table70(Page100) in https://github.com/Infineon/optiga-trust-m/blob/trust_m1_m3/documents/OPTIGA_Trust_M_Solution_Reference_Manual_v3.15.pdf

   For detailed metadata associated with data and key objects, please refer to Table74(Page106) in https://github.com/Infineon/optiga-trust-m/blob/trust_m1_m3/documents/OPTIGA_Trust_M_Solution_Reference_Manual_v3.15.pdf

3. Write test data into the target data object and change the metadata of the target OID accordingly. The version number,metadata update descriptor and Reset type are the parts which are needed to be changed. The metadata of the Target OID can be set as shown in the test script: 

   ```console
   # Target OID metadata setting for protected update 
   TARGET_OID_META="2010C1020000F00101D80721${TRUST_ANCHOR_OID}FD20${PROTECTED_UPDATE_SECRET_OID}"
   ```

   C1 means the version number, the following "02" means the length of the coming data, and the following"0000" the means version number is "0000".

   F0 means Reset type, the following "01" means the length of the coming data, and the following"01" means bring back to creation state but never flush the data inside.

   D8 means metadata Update descriptor, this  tag  defines  the  condition  under  which  the  metadata update is permitted. The following "03" means the length of the coming data."21" means integrity protection," *${TRUST_ANCHOR_OID" is the OID}"* used to store Trust Anchor,"20" means confidentiality protection,"${PROTECTED_UPDATE_SECRET_OID}"is the OID used to store Protected Update Secret.

   For detailed metadata associated with data and key objects, please refer to Table74(Page106) in https://github.com/Infineon/optiga-trust-m/blob/trust_m1_m3/documents/OPTIGA_Trust_M_Solution_Reference_Manual_v3.15.pdf

   After running  "**permanent_decommissioning_provisioning_step1.sh**", the metadata of target OID should be like this: 

   ```console
   foo@bar:~$ ./bin/trustm_metadata -r 0xe0e1
   ========================================================
   Device Public Key           [0xE0E1] 
   [Size 0043] : 
   	20 29 C0 01 01 C1 02 00 00 C4 02 06 C0 C5 02 00 
   	40 D0 03 E1 FC 07 D1 01 00 D3 01 00 D8 07 21 E0 
   	E8 FD 20 F1 D4 E8 01 12 F0 01 01 
   	LcsO:0x01, Version:0000, Max Size:1728, Used Size:64, Change:LcsO<0x07, Read:ALW, Execute:ALW, MUD:Int-0xE0E8&&Conf-0xF1D4, Data Type:DEVCERT, Reset Type:SETCRE, 

   ========================================================
   ```

4. Set the Lcso to Operational state by running the command below:

   ```console
   foo@bar:~$ ./bin/trustm_metadata -w 0xe0e1 -O
   ========================================================
   Device Public Key           [0xE0E1] 

   	20 03 C0 01 07 	
   	LcsO:0x07, 
   Write Success.
   ========================================================
   ```

   The metadata of the target OID is shown as below:

   ```console
   foo@bar:~$ ./bin/trustm_metadata -r 0xe0e1 
   ========================================================
   Device Public Key           [0xE0E1] 
   [Size 0043] : 
   	20 29 C0 01 01 C1 02 00 00 C4 02 06 C0 C5 02 00 
   	40 D0 03 E1 FC 07 D1 01 00 D3 01 00 D8 07 21 E0 
   	E8 FD 20 F1 D4 E8 01 12 F0 01 01 
   	LcsO:0x07, Version:0000, Max Size:1728, Used Size:64, Change:LcsO<0x07, Read:ALW, Execute:ALW, MUD:Int-0xE0E8&&Conf-0xF1D4, Data Type:DEVCERT, Reset Type:SETCRE, 
   ========================================================
   ```

5. Change LcsO to Termination State to remove the device(Permanent decommissioning )

6. Run the command to get the correct manifest and fragment 

   1. Go to  "**\linux-optiga-trust-m\ex_protected_update_data_set/Linux**" and open command prompt

   2. Run this example command:

      ```shell
      foo@bar:~/linux-optiga-trust-m/ex_protected_update_data_set/Linux $ ./bin/trustm_protected_update_set payload_version=3 trust_anchor_oid=E0E8 target_oid=E0E1 sign_algo=ES_256 priv_key=../samples/integrity/sample_ec_256_priv.pem payload_type=metadata metadata=../samples/payload/metadata/metadata.txt content_reset=0 secret=../samples/confidentiality/secret.txt label="test" enc_algo="AES-CCM-16-64-128" secret_oid=F1D4
      ```

      Note:

      1. There are some options to configure in this command. For more details, please go to https://github.com/Infineon/optiga-trust-m/tree/master/examples/tools/protected_update_data_set
      2. The example metadata.txt used here as sample is: 200BC00101D10100D003E1FC07
      3. The private key for sample_ec_256_cert.pem and metadata.txt must be available in the corresponding folder

7. Convert the manifest and fragment to manifest.dat and fragment.dat file

8. Use the manifest and fragment as input for trustm_protected_update as stated in "**permanent_decommissioning_step2.sh **"under "**linux-optiga-trust-m/scripts/UC8/permanent_decommissioning/**"

   If the protected update is successful, Lcso of this data object will be changed back to creation state and the certificate inside the target data object will be flushed.

   ```console
   ========================================================
   Device Public Key           [0xE0E1] 
   [Size 0043] : 
   	20 29 C0 01 01 C1 02 00 00 C4 02 06 C0 C5 02 00 
   	40 D0 03 E1 FC 07 D1 01 00 D3 01 00 D8 07 21 E0 
   	E8 FD 20 F1 D4 E8 01 12 F0 01 01 
   	LcsO:0x01, Version:0003, Max Size:1728, Used Size:0, Change:LcsO<0x07, Read:ALW, Execute:ALW, MUD:Int-0xE0E8&&Conf-0xF1D4, Data Type:DEVCERT, Reset Type:SETCRE/FLUSH, 
   ========================================================
   ```

Note: For detailed use case, please refer to the sample test scripts inside  "**linux-optiga-trust-m/scripts/UC8/permanent_decommissioning**/"

