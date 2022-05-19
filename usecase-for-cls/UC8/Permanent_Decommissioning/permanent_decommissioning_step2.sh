#!/bin/bash
source config.sh

#### Configurable Variables Start

## Target OID for Permanent Decommissioning
# Target OID
TARGET_OID=e0e1

#### Configurable Variables End

for i in $(seq 1 1); do
echo "test $i"

echo "Change 0x$TARGET_OID Lcs0 to Operational mode"
$EXEPATH/trustm_metadata -w  0x$TARGET_OID -O
echo "read out metadata for 0x$TARGET_OID"
$EXEPATH/trustm_metadata -r  0x$TARGET_OID 


sleep 1
done
