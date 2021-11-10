FROM ubuntu:20.04

##Keeps package "tzdata" from throwing a prompt when upgrading, which prevents the running of the software. Be sure to set the environment variable "TZ=America/Los_Angeles" or it will still prompt.
ARG DEBIAN_FRONTEND=noninteractive  

run apt-get update
run apt-get install -y apt-utils
run apt-get install -y wget
run apt-get install -y gnupg
run apt-get install -y curl
run wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
run echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list
run apt-get update -y && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y

run apt-get install -y nodejs && apt-get autoremove -y && apt-get autoclean -y

run apt-get install -y mongodb-org mongodb-org-tools && rm -rf /var/log/mongodb/mongod.log && mkdir /var/lib/mongo && apt-get autoremove -y && apt-get autoclean -y

run apt-get install -y npm && apt-get autoremove -y && apt-get autoclean -y
run apt-get install -y screen && apt-get autoremove -y && apt-get autoclean -y

run npm install archiver@4.0.2
run npm install otplib@10.2.3
run npm install mongodb@4.1.0
run npm install meshcentral

ADD MeshCentral_Exec.sh /

run chmod +x /MeshCentral_Exec.sh
ENTRYPOINT ["/MeshCentral_Exec.sh"]
