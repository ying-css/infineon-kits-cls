#!/bin/bash
source config.sh

#### Configurable Variables Start

## Target OID for metadata protected update, manifest and final fragment
# Target OID
TARGET_OID=e0e1
# Manifest used for metadata protected update (To OP)
MANIFEST="8443A10126A10442E0E3583B8601F6F684210D03820000828220582582182958209B43E0BA334EAB8F4DE144555CBFF79851413F70D129B9596D81DB98293D2123F6824042E0E15840C5D19237E8421DCA8494C89081B42F7CF8D7E02497D68461A3C220FBFDB6CB94BD69051A8F4370975916E4BE2A1779A978489E8C4CB50456D922C10CB42F860F"
# Final fragment used for metadata protected update (To OP)
FINAL_FRAGMENT="200BC00107D10100D003E1FC07"


#### Configurable Variables End

# Perform multiple sequential read
echo "Prepare binary shared secret."
echo $MANIFEST | xxd -r -p > manifest.dat
#~ xxd manifest.dat
echo "Prepare binary data to be init."
echo $FINAL_FRAGMENT | xxd -r -p > final_fragment.dat
#~ xxd final_fragment.dat

for i in $(seq 1 1); do
echo "test $i"


echo "Metadata protected update for 0x$TARGET_OID"
$EXEPATH/trustm_protected_update -k 0x$TARGET_OID -m manifest.dat -f final_fragment.dat
echo "read out metadata for 0x$TARGET_OID"
$EXEPATH/trustm_metadata -r  0x$TARGET_OID -X



sleep 1
done
