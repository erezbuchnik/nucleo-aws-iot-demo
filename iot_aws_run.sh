#!/bin/bash

workdir=`pwd`

iot_endpoint=`cat ${workdir}/share/sys_config.json | jq -r '.identity.iot_endpoint'`

cd ./aws

cp ./config.dist.js ./config.js
sed -i "s/iotEndpoint: '.*'/iotEndpoint: '${iot_endpoint}'/" -- ./config.js
echo
echo "CONFIG:"
cat ./config.js
echo
npm i && npm run build && npm run zip
mkdir ${workdir}/share/aws_dist
cp ./dist/*.js.zip ${workdir}/share/aws_dist/

cd -

