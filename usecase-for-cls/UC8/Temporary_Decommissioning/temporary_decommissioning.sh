#!/bin/bash
source config.sh

#### Configurable Variables Start

## Trust Anchor OID and Target OID for Temporary Decommissioning
# Trust Anchor OID
TRUST_ANCHOR_OID=e0e8
# Target OID
TARGET_OID=e0e1
# Target OID metadata setting for Temporary Decommissioning 
TARGET_OID_META="2011C1020000D003E1FC07F00101D80321$TRUST_ANCHOR_OID"

#### Configurable Variables End

for i in $(seq 1 1); do
echo "test $i"

echo "Step1: Provisioning metadata for 0x$TARGET_OID"
echo "Set protected update for 0x$TARGET_OID (Provision for Temporary Decommissioning)"
echo $TARGET_OID_META | xxd -r -p > targetOID_metadata.bin
echo "Printout targetOID_metadata.bin"
xxd targetOID_metadata.bin
echo "Write targetOID_metadata.bin as metadata of 0x$TARGET_OID"
$EXEPATH/trustm_metadata -w 0x$TARGET_OID -F targetOID_metadata.bin
echo "Read out metadata for 0x$TARGET_OID"
$EXEPATH/trustm_metadata -r  0x$TARGET_OID 


sleep 1
done
