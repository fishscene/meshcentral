FROM ubuntu:20.04
ADD MeshCentral_Exec.sh /

##keeps package "tzdata" from throwing a prompt when upgrading, which prevents the running of the software. Be sure to set the environment variable "TZ=America/Los_Angeles" or it'll still prompt.
ARG DEBIAN_FRONTEND=noninteractive

run apt-get update -y && apt-get upgrade -y

run chmod +x /MeshCentral_Exec.sh
ENTRYPOINT ["/MeshCentral_Exec.sh"]
