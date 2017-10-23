docker stop fabric.certificateserver
docker rm fabric.certificateserver
docker build -t healthcatalyst/fabric.certificateserver . 
docker run -P --rm -e CERT_HOSTNAME=IamaHost -e CERT_PASSWORD=mypassword -e --name fabric.certificateserver -t healthcatalyst/fabric.certificateserver