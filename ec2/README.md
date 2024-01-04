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
- In the AWS console verify that the instance state is running (may take up to a minute to boot up the instance)
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

**Note. Amazon regions can be tricky as some resources are region specific. If you create a new resource and later don't see it make sure you are in the same region it was created! Check the regions in the top right** 
 
 This setup uses route 53 and cloudfront for HTTPS and WAF (web application firewall) to restrict access to only your home ip.
 ### Step 1. Route 53
 - HTTPS connections require a certificate associated with a domain and you must be the owner of this domain. EC2 uses dynamic DNS names owned by AWS by default eg. (ec2-ip-address-here.us-west-1.compute.amazonaws.com)
 - To set up your own domain you can quickly do so with route 53
 - Go to Route 53 -> Register Domains -> Register -> Choose your domain name
 
 ### Step 2. Cloudfront
The next step is to set up cloudfront to handle https connections to the new domain. Cloud front will act as a reverse proxy, forcing all connections to the Ambar instance to go through it first and only allowing https. The setup will look like this: *user accesses domain -> cloudfront -> ec2 instance*

 **Front-end**
 - Steps: Go to Cloudfront -> Create Distribution -> Origin Domain -> (your ec2-instance elastic-ip in the DNS format) For example: `ec2-ip-address-here.us-west-1.compute.amazonaws.com`
 - Select HTTP port 80 **Note HTTP! communications from cloudfront to the ec2 instance will remain on http as they are within Amazons private network**
 - Enter a name such as ambar front-end distribution
 - Viewer protocol -> Redirect HTTP to HTTPS 
 - Allowed HTTP methods: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
 - CacheOptimized
 - Origin request policy -> *AllViewerAndCloudfrontHeaders* **Important! Without this cloudfront won't pass through url params and it won't be clear at first why the website is not working** 
 - WAF -> Do not enable (You will create your own WAF policy to associate with the cloudfront distribution after)
 - Alternate Domain (CNAMES) This is where you enter the domain you purchased with Route 53 -> `yourdomain.com` and `www.yourdomain.com`
 - Custom Certificate -> Request Certificate
   - Open a new tab to request the certificate
   - In the certificate enter your domain.com and `www.domain.com` -> then request
   - Open the certificate under certificate manager -> certificates
   - It should say pending validation. Click create records in Route 53 to add the certificate to your new domain.
 - Back in the cloudfront setup click the small refresh button next to the Choose certificate dropdown. Select your newly created certificate.
 - Create Distribution
   
**Api**
You will now need to repeat these steps for the api as the api and front-end run as separate services on separate ports. While it can all be done on one distribution, it is simpler to manage the api as a subdomain on a separate distribution. This will allow you to give the api its own SSL cert and access the api directly with https using api.yourdomain.com
- Create Distribution and use the same origin. For example: `ec2-ip-address-here.us-west-1.compute.amazonaws.com`
- Select HTTP Port 8080
- Follow the same steps until Custom Certificate
  - Open a new tab to request the certificate
  - But this time enter your api domain i.e, `api.yourdomain.com`
  - Same steps to complete as before
- Back in the cloudfront setup click the small refresh button next to the Choose certificate dropdown. Select your newly created api subdomain certificate.
- Create Distribution

### Step 3. Configure Route 53 to point to Cloudfront
You will now have your new domain direct requests to cloudfront which fetches the ec2 instance: *user accesses domain -> cloudfront -> ec2 instance*
- In Cloud front go to -> Distributions -> Your front-end distribution -> and copy distribution domain name
- In Route 53 go to -> Hosted zones -> `yourdomain.com` -> Create A record
- Leave record name blank for root domain, toggle the use alias button, and route traffic to cloudfront distribution.. should be something like `<front-end-random-string>.cloudfront.com`
- Click Create. Now make a second record but this time enter www for the name to make one for the www subdomain
- Return to Cloud front and go to -> Distributions -> Your api distribution -> and copy distribution domain name
- Return to Route 53 hosted zones and create a third A record.
- This time enter api for the name for the api subdomain. Route it to your api cloudfront domain name: `<api-random-string>.cloudfront.com`
- All done with Cloudfront and route 53 configs!

### Step 4. Disable direct access to the ec2 DNS
You should be able to access your Ambar instance from your domain name now. However, it can still be bypassed by accessing the ec2 instances domain directly i.e, by typing (`ec2-ip-address-here.us-west-1.compute.amazonaws.com` into the browser. You will need to disable this by allowing only cloudfront acccess to this domain
- In the EC2 dashboard select Network & Security -> Security Groups -> Create New security group
- Name it something like ambar front-end access
- Add an Inbound rule Type HTTP, Destination Custom and click the search bar. Scroll down to the prefix-list and `select com.amazonaws.global.cloudfront.origin-facing` This is a list of all cloudfront ips which you are giving access to.
- Click Create Security Group **Note you cannot put the front-end and api rules in one security group as the prefix list is large and it will give an error saying your group is too large. Trust me I tried!**
- Do the same steps again for your api. This time the inbound rule will be Custom TCP on 8080. Same prefix list selection
- Finally you will make a third security group for SSH access. Inbound rule will be SSH, Custom, my IP. Although you already did this in the beginning, you will be deleting the original security group attached to the ec2 instance so you need to recreate the SSH access group
- Now from the EC2 Dashboard go to -> Your Ambar Instance -> Actions (top right) -> Security -> Change security groups.
- Remove the original security group and add the front-end, api, and home ssh access
- All done!

### Redeploy Ambar
- SSH into your EC2 instance and run `docker-compose down` to stop the running containers
- Cd into the ec2 directory. You will need to update the .env file with your new domain name
- `./envsetup` When prompted enter yourdomain.com and api.yourdomain.com
- `./validateenv.sh` Make sure the .env file is correct
- Cd to the root level directory and run `docker-compose up --build`
- Wait until everything is running and then visit your `yourdomain.com`
- If you see your Ambar cloud running then you have successfully set up HTTPS. You should see the secure connection symbol in the browser.
- If you have any issues  go back and carefully make sure everything is properly configured.
- You can check your server logs by using commands  such as `docker-compose logs -f frontend` or `docker-compose logs -f webapi`
- If the site does load but with errors check the developer console with inspect element    
 

## Web Application Firewall 
The final stage in the process is setting up a firewall to block unwanted access. While your site is now fully secure using https it still can be accessed by anyone who visits the domain (yourdomain.com)
To prevent this, you will set up a firewall allowing only your ip to visit your production instance. Every other ip will see a 403 forbidden message 

### Step 1. 
 - Find your ip `curl -s https://ifconfig.me` or `https://whatismyipaddress.com/`
 - Create a new IP set on AWS go to the WAF dashboard -> IP Sets -> Create IP set
 - Name it something like home
 - Enter your IP in CIDR format <your-ip>/32
 - Create
 - Back in the WAF dashboard go to -> Create Web ACL
 - Add a name such as ambar_ec2_front-end_firewall
 - Associate it with your front-end
 - Add rules, name it allow_home
 - Under Ip set, select -> home
 - Source IP address
 - Action Allow
 - Then select block actions that don't match any rules
 - Next then hit create
 - Create a second firewall for your api

   After creating the firewalls you can select them and check under sampled requests. When you access from your ip it should show up there and ALLOW. Other IPs should say BLOCK. *A quick way to test other ips is to disable wifi on your phone and visit your website from your cell-network* 

Verify you can access yourdomain.com
## You are now done with the full EC2 Cloudfront and WAF setup!

### Common issues
- The front-end loads but can't make a request to the api due to a CORS issue (you will see a red error box on the ambar site pop up). Inspect the page -> Network and refresh. If any of the requests fail take a look at the headers and make sure it is requesting the right domain such as `ec2-ip-address-here.us-west-1.compute.amazonaws.com:8080` or `api.yourdomain.com` if you have done the full HTTPS setup. If not, re-run the docker-compose file with the correct env variables.
- yourdomain.com doesn't load anything but directly accessing the container does: `ec2-ip-address-here.us-west-1.compute.amazonaws.com` This means your ec2 instance is working but cloudfront is not configured properly. Make sure the distribution has the right origin, CNAMES and keys. Make sure route 53 has the A records pointing to cloudfront
  
