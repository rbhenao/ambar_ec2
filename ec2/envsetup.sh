#!/bin/bash

# Create an ec2 .env file in the root directory for docker-compose to use

envpath="../.env"

echo "Making a backup of .env to .env.bk"
mv ${envpath} ${envpath}.bk

# Curl the AWS metadata address to find the public ip of this ec2 instance
ambarHostIpAddress=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Set each key-value pair
echo "dataPath=/opt/ambar/data" >> ${envpath}
echo "langAnalyzer=ambar_en" >> ${envpath}
echo "ambarHostIpAddress=$ambarHostIpAddress" >> ${envpath}
echo "pathToCrawl=/opt/ambar/intake" >> ${envpath}
echo "crawlerName=crawler0" >> ${envpath}
echo "localAddress=0.0.0.0" >> ${envpath}
echo "webApiOrigin=$ambarHostIpAddress" >> ${envpath}


echo -e "New .env file created\n"
cat ${envpath}
