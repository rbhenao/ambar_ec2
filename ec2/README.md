# Ambar for EC2

Steps for setting up Ambar on an EC2 instance

### Still in progress...

## Creating the EC2 instance

### Server System Requirements
- Operating System: 64-bit Unix system (CentOS recommended)
- CPU: 2xCPU (high-performance CPU recommended for OCR-intensive tasks)
- RAM: 8GB (minimum required to prevent low memory exceptions)
- HDD: Only SSD; slow disk drives reduce performance (index will take up to 30% of raw document size)
- 10GB minimum storage for the root volume to function, however a larger number such as 20GB or more is ideal as the volume can quickly reach up to 95% of a 10GB allocation in only a few days. 

### EC2 Launch Steps
- In the ec2 console, launch a new instance using the latest CentOS-Stream-ec2 AMI as the base image. (*Under AMI selection click more AMIS and search under the AWS Marketplace*)
- Select an instance type that meets the minimum requirements
- Create a new ssh key pair
- Check allow ssh traffic, allow http traffic, and allow https traffic
- Configure the storage amount for the root volume
- Launch

### Set up ssh keys and verify login

## Set up an Elastic IP

## Setting up HTTPS and SSL with Cloudfront
 - Route 53 -> domain registration, buy a new domain
 - Cloudfront
 - Origin domain use the ec2 domain
 - Choose Https only 
 - CNAMES add domain and www.subdomain and click request certificate
 - Check the certificate under certificate manager -> certificates
 - Click create records in route 53
 - Refresh can take up to a few minutes for status to show validated
 - Once validated go back and refresh to select
 - Choose default cache
 - Hit Create
 - Wait for DNS to update then ping your website.com

## System Requirements

### Client Requirements
- Browser: Any modern web browser (Chrome or Firefox)

Follow the AWS console steps to allocate and associate an Elastic IP with your EC2 instance.

## Installing Docker, Docker Compose, and Git

- Install Docker: [Docker Installation for CentOS](https://docs.docker.com/engine/install/centos/)
- Post-installation steps for Docker: [Linux Post-installation for Docker](https://docs.docker.com/engine/install/linux-postinstall/)
- Install Git:

  ###
  ambarHostIpAdcurl http://169.254.169.254/latest/meta-data/public-hostname
$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
  
