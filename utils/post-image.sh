#!/bin/bash

BOARD_DIR="$(dirname $0)"
GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

rm -rf "${GENIMAGE_TMP}"

SECUREBOOT_DIR="${BINARIES_DIR}/secureboot"

${BOARD_DIR}/gen-secureboot-keys.sh "${SECUREBOOT_DIR}"

#
# Files that need to be signed.
#
read -r -d '' SIGNED_FILES <<'FILES'
efi-part/EFI/BOOT/bootx64.efi
bzImage
FILES

for file in ${SIGNED_FILES}; do
       sbsign --key ${SECUREBOOT_DIR}/db.key --cert ${SECUREBOOT_DIR}/db.crt ${BINARIES_DIR}/${file} --output ${BINARIES_DIR}/${file}.signed
done

cat >${BINARIES_DIR}/efi-part/startup.nsh <<__EOF__
bootx64.efi
__EOF__

cat >${BINARIES_DIR}/efi-part/loader/loader.conf <<__EOF__
default buildroot
timeout 30
auto-enroll yes
__EOF__

cat >${BINARIES_DIR}/efi-part/loader/entries/buildroot.conf <<__EOF__
title   Buildroot
version 1
linux   /bzImage
options net.ifnames=0 console=ttyS0 root="/dev/vda2"
__EOF__

genimage                              \
       --rootpath "${TARGET_DIR}"     \
       --tmppath "${GENIMAGE_TMP}"    \
       --inputpath "${BINARIES_DIR}"  \
       --outputpath "${BINARIES_DIR}" \
       --config "${GENIMAGE_CFG}"

exit $?
