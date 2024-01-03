# Ambar for EC2

This guide will give you all of the steps needed to get ambar cloud running on your own ec2 instance.

## Ambar EC2 Setup Steps
### Step 1. Running ambar EC2 instance

### Server System Requirements
When selecting your AMI it must meet these minimum requirements as specified by the Ambar documentation
- Operating System: 64-bit Unix system (CentOS recommended)
- CPU: 2xCPU (high-performance CPU recommended for OCR-intensive tasks)
- RAM: 8GB (minimum required to prevent low memory exceptions)
- HDD: Only SSD; slow disk drives reduce performance (index will take up to 30% of raw document size)
- 10GB minimum storage for the root volume to function, however a larger number such as 20GB or more is ideal as the volume can quickly reach up to 95% of a 10GB allocation in only a few days. 

### Launch Instance
- In the ec2 console, click launch a new instance
- For the Amazon Machine Image, select the latest CentOS-Stream-ec2 version as the base. *Under AMI selection click more AMIS and search under the AWS Marketplace*
- Select an instance type that meets the minimum requirements listed above
- Create a new ssh key pair. **Once you click create keys, it will download the private key - check your downloads folder. Do not continue without verifying you have the key! If you lose your private key you will have to create a new instance** 
- Check allow ssh traffic and select from my ip, check allow http traffic, and allow https traffic
- Configure the storage amount for the root volume
- Click Launch Instance

### Logging into your instance
- In the AWS console verfiy that the insance state is running (may take up to a minute to boot up the instance)
- Once it is running configure ssh keys on your local machine
- ```
  mv /path/to/your_key.pem to ~/.ssh
  chmod 400 ~/.ssh/your_key.pem
  ```
 - Copy your instance public ip. EC2 Dashboard -> Instances -> Select Instance -> Public IPv4
 - Run `ssh -i "~/.ssh/your_key.pem" <your_public_ip>`
 - Verify you have successfully logged in to your instance!

### Step 2. Create an Elastic IP
 - By default ec2 instances have dynamic ips that change when you stop/start them. In order to be able to easily log in and out of the instance and set up HTTPS you will need to associate an elastic IP to it.
 - In the left side-bar go to Network & Security -> Elastic IPs -> Allocate Elastic IP Address
 - Now associate this elastic IP with your instance. Elastic IP list -> Associate Elastic IP Address -> Choose your instance -> Associate
 - Back in the EC2 Dashboard select your instance and verify that the public IP now matches your new elastic IP

### Step 3. Configure your security groups
  - When the instance was created the security groups allow http traffic to 80, https to 443 and ssh to 22. Ambar also uses 8080 for the api so this will need to be added
  - Go to EC2 Dashboard -> Instances -> Your instance -> Security -> Security Groups -> Edit inbound rules
  - Add a new rule. Select Custom TCP, Port Range 8080 and Source Anywhere
  - Save Rules

### Step 4. Cloning the ambar_ec2 repo
 - Log into your instance with your ssh key
 - Install Git
 - ```
   sudo yum update
   sudo yum install git
   git --version
   ```
 - Configure your git name and email
 - ```
   git config --global user.name "Your Username"
   git config --global user.email "your_email@example.com"
   ```
 - Create ssh-keys for accessing your github account
 - ```
   cd ~/.ssh
   ssh-keygen -t rsa -b 2048 -C "your_email@example.com"
   chmod 400 your_id_rsa
   chmod 644 your_id_rsa.pub
 - Copy your public key to your github account `cat your_id_rsa.pub`
 - On your github go to Settings -> SSH and GPG keys -> New SSH Key -> Paste your public key
 - Verify on the terminal your ec2 instance has ssh access `ssh -T git@github.com`
 - *If you get an error here it may be because your key has not been added to the ssh agent. Try:* `ssh-agent -s` and `ssh-add ~/.ssh/your_id_rsa`
 - Clone the repo `git clone git@github.com/username/repo.git`

 ### Step 5. Install Dependencies
 - [Install Docker on CentOs](https://docs.docker.com/engine/install/centos/)
 - Enable running Docker without sudo and add it to the system startup: [Docker Post-Install](https://docs.docker.com/engine/install/linux-postinstall/)
 - Install docker-compose
 - ```
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   docker-compose --version
   ```
  ### Step 6. Configure and Deploy
  - Configure the kernel settings recommended. Execute the `kernelsettings.sh` script that is in this directory or follow the [Ambar Documentation](https://web.archive.org/web/20211123093146/https://ambar.cloud/docs/installation)
  - Make the directories for ambar `./mkdirs.sh`
  - Configure your .env file `./envsetup.sh` When prompted about your domain and api hit no (n) as you're using the default ec2 domain.
  - Validate the the .env file was created and is correct `./validateenv.sh`
  - Cd into the top level directory of your git repo and run `docker-compose up --build`
  - Make sure all containers are running successfully
  - Copy your EC2 PublicIpv4 DNS and paste it into the browser. If you see the ambar dashboard you have successfully launched ambar on your instance!
  - Optional: Test file upload functionality. Click upload files. There is also a convenience script `testingest.sh` that will move sample Documents into the ambar/intake dir

<br /><br />

## Setting up HTTPS and Controlling Access
 Once you have ambar successfully running on your ec2 instance, follow these steps to make it secure. There are many ways to do this. These steps will cover the easiest way to secure your instance for testing in production, however for longer term work more robust setups are recommended such as using a load balancer and creating users with token validation on the backend. 

 This setup uses route 53 and cloudfront for HTTPS and WAF (web application firewall) to restrict access to only your home ip.
 ### Step 1. Route 53
 - HTTPS connections require a certificate associated with a domain and you must be the owner of this domain. EC2 uses dynamic DNS names owned by AWS by default eg. (ec2-ip-address-here.us-west-1.compute.amazonaws.com)
 - To set up your own domain you can quickly do so with route 53
 - Go to Route 53 -> Register Domains -> Register -> Choose your domain name
 
 ### Step 2. Cloudfront
 - The next step is to set up cloudfront to handle https connections to the new domain
 - Go to Cloudfront -> 
 - Choose Https only 
 - CNAMES add domain and www.subdomain and click request certificate
 - Check the certificate under certificate manager -> certificates
 - Click create records in route 53
 - Refresh can take up to a few minutes for status to show validated
 - Once validated go back and refresh to select
 - Choose default cache
 - Hit Create
 - Wait for DNS to update then ping your website.com
 
## WAF 
 - WAF -> IP Sets -> Create IP set
 - Find my ip curl -s `https://ifconfig.me`
 - Or https://whatismyipaddress.com/
 - WAF -> Create Web ACL
 - Create Name such as ambar_ec2_firewall
 - Add Rules, name it allow_home
 - Ip set -> home
 - Source IP address
 - Action Allow
 - Block actions that don't match any rules
 - Next Then hit create
 - Associate with your domain
 - Access from your ip and check under Sampled requests that you see it work
 - A quick way to test another ip is to disable wifi on your phone and try to connect from the cellular network which will use a different ip
 - Verify the ips in the WAF Sampled request logs
 - Security Groups
 - Done!

 ## Security Group

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
  
