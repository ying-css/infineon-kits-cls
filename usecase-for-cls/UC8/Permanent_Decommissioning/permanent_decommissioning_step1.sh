#!/bin/bash
source config.sh

#### Configurable Variables Start

## Trust Anchor OID and Target OID for Temporary Decommissioning
# Trust Anchor OID
TRUST_ANCHOR_OID=e0e3
# Target OID
TARGET_OID=e0e1
# Target OID metadata setting for Temporary Decommissioning 
TARGET_OID_META_PER="200CC1020000F00111D80321$TRUST_ANCHOR_OID"

#### Configurable Variables End

for i in $(seq 1 1); do
echo "test $i"

echo "Step1: Provisioning metadata for 0x$TARGET_OID"
echo "Set protected update for 0x$TARGET_OID (Provision for Permanent Decommissioning)"
echo $TARGET_OID_META_PER | xxd -r -p > targetOID_metadata_permanent.bin
echo "Printout targetOID_metadata_permanent.bin"
xxd targetOID_metadata_permanent.bin
echo "Write targetOID_metadata_permanent.bin as metadata of 0x$TARGET_OID"
$EXEPATH/trustm_metadata -w 0x$TARGET_OID -F targetOID_metadata_permanent.bin
echo "Read out metadata for 0x$TARGET_OID"
$EXEPATH/trustm_metadata -r  0x$TARGET_OID 


sleep 1
done
