#!/bin/bash

set -eu

echo "running docker-entrypoint.sh"

echo "contents of /opt/healthcatalyst/client/"
echo "-------"
ls /opt/healthcatalyst/client/
echo "-------"

if [ ! -f "/opt/healthcatalyst/client/cert.pem" ]
then
	echo "no certificates found so regenerating them"

	# make sure CertHostName and CertPassword are set
	if [ -z "${CERT_HOSTNAME:-}" ]; then
		echo "CERT_HOSTNAME must be set"
    	exit 1
	fi
	if [ -z "${CERT_PASSWORD:-}" ]; then
		echo "CERT_PASSWORD must be set"
    	exit 1
	fi

	/bin/bash /opt/healthcatalyst/setupca.sh \
		&& /bin/bash /opt/healthcatalyst/generateservercert.sh \
		&& /bin/bash /opt/healthcatalyst/generateclientcert.sh \
		&& mkdir -p /app/public/client/ \
		&& cp /opt/healthcatalyst/client/fabric_client_cert.p12 /app/public/client/ \
		&& cp /opt/healthcatalyst/client/fabric_ca_cert.p12 /app/public/client/
else
	echo "certificates already exist so we're not regenerating them"
fi

MyHostName="${CERT_HOSTNAME:-$(hostname)}"

echo "you can download the client certificate from this url"
echo "http://$MyHostName:8081/client/fabric_client_cert.p12"

echo "if you want, you can download the CA (Certificate Authority) cert from this url"
echo "http://$MyHostName:8081/client/fabric_ca_cert.p12"


echo "starting web server"

exec "$@"
