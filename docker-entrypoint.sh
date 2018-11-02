#!/bin/bash

set -eu

echo "running docker-entrypoint.sh"
echo "Version 2018.11.01.02"

if [[ ! -d "/opt/certs" ]]; then
	echo "/opt/certs folder is not present.  Be sure to attach a volume."
	exit 1
fi

echo "contents of /opt/certs/client/"
mkdir -p /opt/certs/client
echo "-------"
ls /opt/certs/client/
echo "-------"

# copy only the client certs to the web server folder for download
mkdir -p /app/public/client/ \
	&& mkdir -p /opt/certs/client \
	&& cp /opt/certs/client/*.p12 /app/public/client/


echo "starting web server"

exec "$@"
