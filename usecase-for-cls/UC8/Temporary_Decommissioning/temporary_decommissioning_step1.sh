#!/bin/bash
source config.sh

# Perform multiple sequential read

#### Configurable Variables Start

## Trust Anchor OID and Metadata settings for integrity protect
# Trust Anchor OID
TRUST_ANCHOR_OID=e0e8
# Trust Anchor metadata setting
TRUST_ANCHOR_META="2011C00101D003E1FC07D10100D30100E80111"

## PROTECTED UPDATE OID and Metadata settings for confidentiality protect
# Protected Update OID
PROTECTED_UPDATE_SECRET_OID=f1d4
# Shared Secret Data, must match with the host C codes
PROTECTED_UPDATE_SECRET="49C9F492A992F6D4C54F5B12C57EDB27CED224048F25482AA149C9F492A992F649C9F492A992F6D4C54F5B12C57EDB27CED224048F25482AA149C9F492A992F6"
# Protected Update metadata setting
PROTECTED_UPDATE_SECRET_META="200BD103E1FC07D30100E80123"

# Certificate OID
CERTIFICATE_OID=e0e1
# Certificate metadata setting for Temporary Decommissioning 
CERTIFICATE_TEM_META="2011C1020000D003E1FC07F00101D80321$TRUST_ANCHOR_OID"
# Certificate metadata setting for Permanent Decommissioning 
CERTIFICATE_PER_META="200CC1020000F00111D80321$TRUST_ANCHOR_OID"

# Private Key OID
PRIVATE_KEY_OID=e0f1
# Private Key metadata setting
PRIVATE_KEY_TEM_META="200CC1020000F00101D80321$TRUST_ANCHOR_OID"
# Certificate metadata setting for Permanent Decommissioning 
PRIVATE_KEY_PER_META="200CC1020000F00111D80321$TRUST_ANCHOR_OID"

#### Configurable Variables End

echo "Prepare binary protected update secret."
echo $PROTECTED_UPDATE_SECRET | xxd -r -p > protected_update_secret.dat
#~ xxd protected_update_secret.dat
echo "Prepare binary shared secret."
echo $SHARED_SECRET | xxd -r -p > shared_secret.dat
#~ xxd shared_secret.dat
echo "Prepare binary data to be init."
echo $DATA_OBJECT | xxd -r -p > data.dat

set -e
for i in $(seq 1 1); do
echo "test $i"
echo "Step1: Provisioning initial Trust Anchor, metadata for Trust Anchor"
echo "Write Test Trust Anchor into 0x$TRUST_ANCHOR_OID"
$EXEPATH/trustm_cert -w 0x$TRUST_ANCHOR_OID -i $CERT_PATH/Test_Trust_Anchor.pem
echo "Set device type to TA for 0x$TRUST_ANCHOR_OID "
echo $TRUST_ANCHOR_META | xxd -r -p > trust_anchor_metadata.bin
echo "Printout trust_anchor_metadata.bin"
xxd trust_anchor_metadata.bin
echo "write trust_anchor_metadata.bin as metadata of 0x$TRUST_ANCHOR_OID"
$EXEPATH/trustm_metadata -w 0x$TRUST_ANCHOR_OID -F trust_anchor_metadata.bin
echo "Read out metadata for 0x$TRUST_ANCHOR_OID"
$EXEPATH/trustm_metadata -r  0x$TRUST_ANCHOR_OID

#~ echo "Set 0x$TRUST_ANCHOR_OID to OP"
#~ $EXEPATH/trustm_metadata -w 0x$TRUST_ANCHOR_OID -O

echo "Step1: Provisioning Protected Update OID, metadata for Protected Update OID"
echo "Write Protected Update Secret into 0x$PROTECTED_UPDATE_SECRET_OID"
$EXEPATH/trustm_data -e -w 0x$PROTECTED_UPDATE_SECRET_OID -i protected_update_secret.dat
echo "Set device type to UPDATSEC for 0x$PROTECTED_UPDATE_SECRET_OID "
echo $PROTECTED_UPDATE_SECRET_META | xxd -r -p > protected_update_secret_metadata.bin
echo "Printout trust_anchor_metadata.bin"
xxd protected_update_secret_metadata.bin
echo "write protected_update_secret_metadata.bin as metadata of 0x$PROTECTED_UPDATE_SECRET_OID"
$EXEPATH/trustm_metadata -w 0x$PROTECTED_UPDATE_SECRET_OID -F protected_update_secret_metadata.bin
echo "Read out metadata for 0x$PROTECTED_UPDATE_SECRET_OID"
$EXEPATH/trustm_metadata -r  0x$PROTECTED_UPDATE_SECRET_OID

#~ echo "Set 0x$PROTECTED_UPDATE_SECRET_OID to OP"
#~ $EXEPATH/trustm_metadata -w 0x$PROTECTED_UPDATE_SECRET_OID -O

echo "Step1: Provisioning metadata for 0x$CERTIFICATE_OID"
echo "set protected update for 0x$CERTIFICATE_OID (Provision for Temporary Decommissioning)"
echo $CERTIFICATE_TEM_META | xxd -r -p > cert_temp_metadata.bin
echo "Printout cert_temp_metadata.bin"
xxd cert_temp_metadata.bin
echo "write cert_temp_metadata.bin as metadata of 0x$CERTIFICATE_OID"
$EXEPATH/trustm_metadata -w 0x$CERTIFICATE_OID -F cert_temp_metadata.bin

echo "Step1: Provisioning metadata for 0x$PRIVATE_KEY_OID"
echo "set protected update for 0x$PRIVATE_KEY_OID (Provision for Temporary Decommissioning)"
echo $PRIVATE_KEY_TEM_META | xxd -r -p > private_key_temp_metadata.bin
echo "Printout private_key_temp_metadata.bin"
xxd private_key_temp_metadata.bin
echo "write private_key_temp_metadata.bin as metadata of 0x$PRIVATE_KEY_OID"
$EXEPATH/trustm_metadata -w 0x$PRIVATE_KEY_OID -F private_key_temp_metadata.bin


sleep 1
done
