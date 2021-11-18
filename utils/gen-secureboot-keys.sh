#!/bin/sh
# SPDX-License-Identifier: LGPL-3.0-or-later

set -euo pipefail

#
# This script allows for the generation of a complete set of UEFI keys and
# signature list. You should be able to enroll the outputs in whatever UEFI
# firmware you are using and then sign your own UEFI binaries.
#

if [ ! $# -eq 1 ]; then
	printf "Usage: $0 <DIRECTORY>\n\n"
	printf "Generates a new UEFI set of keys (PK+KEK+DB).\n\n"
	printf "<DIRECTORY>: Directory to create the keys in\n"
	exit 1
fi

mkdir -p $1
cd $1

#
# OpenSSL options for the generation of the keys/certificates. These default
# settings should work pretty well but you can tweak them if you want longer
# keys (4096 bits) or smaller expiration.
#
OPENSSL_OPTS="-days 9125 -nodes -sha256 -newkey rsa:2048"

#
# We try to protect the keys and certificates by setting a restrictive umask.
#
umask 077

uuid=$(uuidgen | tee uuid)

keys="PK KEK db"
for key in ${keys}; do
	openssl req -new -x509 		\
		-subj "/CN=${key}/"		\
		-keyout "${key}.key"	\
		-out "${key}.crt"		\
		${OPENSSL_OPTS}

	openssl x509 -outform DER -in "${key}.crt" -out "${key}.cer"
	cert-to-efi-sig-list -g "${uuid}" "${key}.crt" "${key}.esl"
done

sign-efi-sig-list -c PK.crt -k PK.key PK PK.esl PK.esl.auth
sign-efi-sig-list -c PK.crt -k PK.key KEK KEK.esl KEK.esl.auth
sign-efi-sig-list -c KEK.crt -k KEK.key db db.esl db.esl.auth
