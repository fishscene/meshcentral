#!/bin/bash
version=2021.11.09
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

printf "\n Starting mongod\n"
mongod --fork --dbpath /var/lib/mongo --logpath /var/log/mongodb/mongod.log &
mongoPid="$!"
printf "\n mongod started, PID: $mongoPid\n"
wait "$mongoPid"

##MeshCentral setup.
if [ ! -f /meshcentral-data/firstrun.txt ]; then
  printf "\n\n First run detected. Performing first run configuration.\n\n"
   screen -dm -S firstrun && screen -S firstrun -X stuff "node ./node_modules/meshcentral --cert $URL\n" && sleep 20 && killall -9 node && pkill screen

  touch /meshcentral-data/firstrun.txt
fi

printf "\nCustomizing /meshcentral-data/config.json\n"
if [ ! /meshcentral-data ]; then
  printf "\n/meshcentral-data Does not exist! Unable to proceed.\n"}
else
  printf "\n/meshcentral-data found. Proceeding with configuration...\n"
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
fi

printf "\n Starting MeshCentral\n"
printf "\n\n\nConfigure your reverse proxy to point to https://\$yourServerIP:\$yourWebsitePort\nThen Connect to the website at: https://$URL\n\n\n"
node ./node_modules/meshcentral &
pid="$!"
printf "\n MeshCentral started, PID: $pid\n"
wait "$pid"
