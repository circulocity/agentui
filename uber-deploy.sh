#!/bin/bash

# make sure you have a trailing slash
SERVER=root@64.27.3.17:/opt/agentui/

set -e

pushd proxy
#  mvn clean install
popd 

set +e
rm -rf target/dist
mkdir -p target/dist/webapp
set-e

cp -r client/ target/dist/webapp/
cp -r proxy/src/main/webapp/ target/dist/webapp/
cp -r proxy/target/agentui-proxy-1.0-SNAPSHOT-jar-with-dependencies.jar target/dist/
cp -r proxy/run.sh target/dist/
rm -rf target/dist/webapp/WEB-INF/source-jsp
rm target/dist/{*.xml,*.hxml,*.txt}

#rsync --delete --compress --recursive --partial --progress --stats proxy/src/main/webapp/ ${SERVER}

