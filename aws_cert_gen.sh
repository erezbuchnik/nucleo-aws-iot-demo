#!/bin/bash

action=$1

mkdir ./auth/aws_certs
cd ./auth/aws_certs

function generate_csr {

	# Generate CSR:
	sudo apt -y update
	sudo apt -y install openssl
	sudo openssl ecparam -genkey -name prime256v1 -out nucleo.key.pem
	sudo openssl req -new -sha256 -key nucleo.key.pem -out nucleo.csr
}

function obtain_rootca_cert {

	# Obtain root CA and CRT:
	root_ca_path=$1
	cert_path=$2
	
	cp "${root_ca_path}" ./rootCA.pem
	cp "${cert_path}" ./certificate.pem.crt
}


if [[ "${action}" == "csr" ]] ; then
	generate_csr
elif [[ "${action}" == "cert" ]] ; then
	root_ca_path=$2
	cert_path=$3
	obtain_rootca_cert "${root_ca_path}" "${cert_path}"
fi

ls -ltr ./

cd -

