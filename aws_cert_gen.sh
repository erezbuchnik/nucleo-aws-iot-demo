#!/bin/bash

action=$1

workdir=`pwd`

mkdir ./share/aws_certs
cd ./share/aws_certs

function generate_csr {

	# Generate CSR:
	sudo apt -y update
	sudo apt -y install jq
	sudo apt -y install openssl
	sudo openssl ecparam -genkey -name prime256v1 -out nucleo.key.pem
	sudo openssl req -new -sha256 -key nucleo.key.pem -out nucleo.csr
}

function obtain_rootca_cert {

	# Obtain root CA and CRT:
	root_ca_path=`cat ./config.json | jq -r '.cert.root_ca_path'`
	cert_path=`cat ./config.json | jq -r '.cert.certificate_path'`
	
	cp "${root_ca_path}" ./rootCA.pem
	cp "${cert_path}" ./certificate.pem.crt
}


if [[ "${action}" == "csr" ]] ; then
	generate_csr
elif [[ "${action}" == "cert" ]] ; then
	obtain_rootca_cert
fi

ls -ltr ./

cd -

