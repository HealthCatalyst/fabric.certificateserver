docker stop fabric.certificateserver
docker rm fabric.certificateserver
docker build -t healthcatalyst/fabric.certificateserver . 
docker volume create fabriccertificatestore
docker run -P --rm --mount src=fabriccertificatestore,dst=/opt/certs/ -e CERT_HOSTNAME=IamaHost -e CERT_PASSWORD=mypassword --name fabric.certificateserver -t healthcatalyst/fabric.certificateserver