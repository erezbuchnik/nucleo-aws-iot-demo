#!/bin/bash

workdir=`pwd`

aws_region=`cat ${workdir}/share/sys_config.json | jq -r '.geo.aws_region'`
api_url=`cat ${workdir}/share/sys_config.json | jq -r '.api.api_url'`
iot_endpoint=`cat ${workdir}/share/sys_config.json | jq -r '.identity.iot_endpoint'`
cognito_identity_pool=`cat ${workdir}/share/sys_config.json | jq -r '.identity.cognito_identity_pool'`

cd ./dashboard

cp ./src/config.dist.js ./src/config.js
sed -i "s/awsRegion: '.*'/awsRegion: '${aws_region}'/" -- ./src/config.js
sed -i "s/apiUrl: '.*'/apiUrl: '${api_rul}'/" -- ./src/config.js
sed -i "s/iotEndpoint: '.*'/iotEndpoint: '${iot_endpoint}'/" -- ./src/config.js
sed -i "s/cognitoIdentityPool: '.*'/cognitoIdentityPool: '${cognito_identity_pool}'/" -- ./src/config.js
echo 
echo "CONFIG:"
cat ./src/config.js
echo 
npm run build
mkdir ${workdir}/share/dashboard_dist
cp ./dist/* ${workdir}/share/dashboard_dist

#aws s3 sync dist/ s3://<your.bucket.name>/

cd -

