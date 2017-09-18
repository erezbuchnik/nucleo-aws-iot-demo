#!/bin/bash

workdir=`pwd`

iot_endpoint=`cat ${workdir}/share/sys_config.json | jq -r '.identity.iot_endpoint'`

cd ./aws

cp ./config.dist.js ./config.js
sed -i "s/iotEndpoint: '.*'/iotEndpoint: '${iot_endpoint}'/" -- ./config.js
npm i && npm run build && npm run zip

cd -
