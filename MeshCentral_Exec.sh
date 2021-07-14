#!/bin/bash
version=2021.04.20
#set -x
pid=0
mongoPid=0

#### https://stackoverflow.com/questions/41451159/how-to-execute-a-script-when-i-terminate-a-docker-container
#### https://www.linuxjournal.com/content/bash-trap-command
#Define cleanup procedure
function cleanup()
{
    #printf "\n#####################################################################\n#####################################################################\n"
	printf "\nContainer stop signal received, closing down...\n"

  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
	printf "\n MeshCentral stopped successfully.\n"
	kill -SIGTERM "$mongoPid"
    wait "$mongoPid"
	printf "\n Database stopped successfully.\n"
	printf "\n Container stopped successfully.\n"
  fi
}

trap 'cleanup' EXIT
#trap 'cleanup' SIGHUP
#trap 'cleanup' SIGQUIT
#trap 'cleanup' SIGABRT
#trap 'cleanup' SIGKILL
#trap 'cleanup' SIGTERM
#trap 'cleanup' SIGUSR1
#trap 'cleanup' SIGUSR2
trap 'cleanup' SIGINT


##Mongodb setup.
#if [ ! -f /meshcentral-data/firstrun.txt ]; then
  printf "\n\n First run detected. Installing newest versions of dependencies.\n\n"
  apt-get update && apt-get upgrade -y
  apt-get install nodejs -y
  apt-get install npm -y
  apt-get install mongodb-org-tools
  
  rm -rf /var/log/mongodb/mongod.log ##Sometimes this exists on first startup?. If it does, it actively interferes with Mongo's ability to start the first time. 
  mkdir /var/lib/mongo ##Mongo DB directory.
  apt-get install mongodb -y && rm -rf /var/log/mongodb/mongod.log
#fi

printf "\n Starting mongod\n"
mongod --fork --dbpath /var/lib/mongo --logpath /var/log/mongodb/mongod.log &
mongoPid="$!"
printf "\n mongod started, PID: $mongoPid\n"
wait "$mongoPid"

##MeshCentral setup.
if [ ! -f /meshcentral-data/firstrun.txt ]; then
  printf "\n\n First run detected. Installing meshcentral and performing first run configuration.\n\n"
  npm install meshcentral
  apt-get install screen -y && screen -dm -S firstrun && screen -S firstrun -X stuff "node ./node_modules/meshcentral --cert $URL\n" && sleep 20 && killall -9 node && pkill screen && apt-get remove screen -y ## Install screen, run meshcentral once, close meshcentral, close screen, remove screen.
  
  touch /meshcentral-data/firstrun.txt
fi

printf "\n Customizing /meshcentral-data/config.json\n"
sed -i "s|\"_cert\": \"myserver.mydomain.com\",|&\n    \"AgentPong\": $agentPong,|g" /meshcentral-data/config.json
sed -i "s|\"_cert\": \"myserver.mydomain.com\",|&\n    \"_TlsOffload\": \"$TlsOffload\",|g" /meshcentral-data/config.json
sed -i "s|\"_cert\": \"myserver.mydomain.com\",|&\n    \"MongoDb\": \"mongodb://$mongodbUrl\",|g" /meshcentral-data/config.json
sed -i "s|\"_cert\": \"myserver.mydomain.com\",|\"Cert\": \"$URL\",|g" /meshcentral-data/config.json
sed -i 's|"_WANonly": true,|"WANonly": true,|g' /meshcentral-data/config.json
sed -i "s|\"_port\": 443,|\"port\": $port,|g" /meshcentral-data/config.json
sed -i "s|\"_aliasPort\": 443,|\"aliasPort\": $aliasPort,|g" /meshcentral-data/config.json
sed -i "s|\"_redirPort\": 80,|\"redirPort\": $redirPort,|g" /meshcentral-data/config.json
sed -i "s|\"_title2\": \"Servername\",|&\n      \"certUrl\": \"https://$URL:$aliasPort/\",|g" /meshcentral-data/config.json
printf "\n Customizations complete.\n"

printf "\n Starting MeshCentral\n"
node ./node_modules/meshcentral &
pid="$!"
printf "\n MeshCentral started, PID: $pid\n"
wait "$pid"
