#!/bin/bash

set -eu

echo "running docker-entrypoint.sh"

if [[ ! -d "/opt/certs" ]]; then
	echo "/opt/certs folder is not present.  Be sure to attach a volume."
	exit 1
fi

echo "contents of /opt/certs/server/"
mkdir -p /opt/certs/server/
mkdir -p /opt/certs/client
echo "-------"
ls /opt/certs/server/
echo "-------"

if [[ ! -f "/opt/certs/server/cert.pem" ]]
then
	echo "no certificates found so regenerating them"

	# make sure CertHostName and CertPassword are set
	if [[ ! -z "${CERT_HOSTNAME_FILE:-}" ]]
	then
		echo "CERT_HOSTNAME_FILE is set so reading from $CERT_HOSTNAME_FILE"
		CERT_HOSTNAME=$(cat $CERT_HOSTNAME_FILE)
	fi

	if [[ -z "${CERT_HOSTNAME:-}" ]]; then
		echo "CERT_HOSTNAME must be set"
    	exit 1
	fi

	if [[ ! -z "${CERT_PASSWORD_FILE:-}" ]]
	then
		echo "CERT_PASSWORD_FILE is set so reading from $CERT_PASSWORD_FILE"
		CERT_PASSWORD=$(cat $CERT_PASSWORD_FILE)
	fi

	if [[ -z "${CERT_PASSWORD:-}" ]]; then
		echo "CERT_PASSWORD must be set"
    	exit 1
	fi

	/bin/bash /opt/healthcatalyst/setupca.sh \
		&& /bin/bash /opt/healthcatalyst/generateservercert.sh \
		&& /bin/bash /opt/healthcatalyst/generateclientcert.sh fabricrabbitmquser \
		&& mkdir -p /opt/certs/testca \
		&& cp /opt/healthcatalyst/testca/cacert.pem /opt/certs/testca \
		&& mkdir -p /opt/certs/server \
		&& cp /opt/healthcatalyst/server/cert.pem /opt/certs/server/ \
		&& cp /opt/healthcatalyst/server/key.pem /opt/certs/server/ \
		&& mkdir -p /opt/certs/client \
		&& cp /opt/healthcatalyst/client/*.p12 /opt/certs/client/
		
else
	echo "certificates already exist so we're not regenerating them"
fi

MyHostName="${CERT_HOSTNAME:-$(hostname)}"

# copy only the client certs to the web server folder for download
mkdir -p /app/public/client/ \
	&& cp /opt/certs/client/*.p12 /app/public/client/

echo "you can download the client certificate from this url"
echo "http://$MyHostName:8081/client/fabricrabbitmquser_client_cert.p12"

echo "if you want, you can download the CA (Certificate Authority) cert from this url"
echo "http://$MyHostName:8081/client/fabric_ca_cert.p12"


echo "starting web server"

exec "$@"
