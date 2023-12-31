#!/bin/bash

# Create an ec2 .env file in the root directory for docker-compose to use

read -p "Are you using your own domain name? (y/n): " answer

if [[ $answer == [Yy] ]]; then
    read -p "Enter your domain name (i.e. example.com): " answer
    ambarHostAddress=${answer}
    
    read -p "Enter api subdomain (i.e. api.example.com): " answer
    ambarApiAddress=${answer}
    
    defaultProtocol="https"
    ambarApiFullAddress="${defaultProtocol}://${ambarApiAddress}"

elif [[ $answer == [Nn] ]]; then
    ambarHostAddress=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
    ambarApiAddress=${ambarHostAddress}
    
    defaultProtocol="http"
    ambarApiFullAddress="${defaultProtocol}://${ambarApiAddress}:8080"
    
    # use default ec2-domain
    echo -e "\n  Using default ec2 public domain: ${ambarHostAddress}"
else
    # Invalid input
    echo "Invalid input. Expecting (y/n). Exiting now."
    exit 0
fi

envpath="../.env"

if [ -f "${envpath}" ]; then
    echo -e "\nMaking a backup of .env to .env.bk"
    mv "${envpath}" "${envpath}.bk"
fi

# Set each key-value pair
echo "dataPath=/opt/ambar/data" >> ${envpath}
echo "langAnalyzer=ambar_en" >> ${envpath}
echo "ambarApiFullAddress=$ambarApiFullAddress" >> ${envpath}
echo "pathToCrawl=/opt/ambar/intake" >> ${envpath}
echo "crawlerName=crawler0" >> ${envpath}
echo "localAddress=0.0.0.0" >> ${envpath}
echo "ambarHostAddress=$ambarHostAddress" >> ${envpath}
echo "defaultProtocol=${defaultProtocol}" >> ${envpath}

fullenvpath=$(readlink -f "$envpath")
echo -e "New .env file created: ${fullenvpath} \n"
cat ${envpath}