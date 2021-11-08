# meshcentral
A self-contained MeshCentral, designed to run behind nginx-gui.


Installs latest updates, MongoDB, and MeshCentral on first deployment of the container.

--Quick Start--
    
    version: '3'

    volumes:
      meshcentral-data:
      meshcentral-files:
      meshcentral-database:
      meshcentral-database-log:

    services:
        meshcentral:
            restart: always
            container_name: meshcentral
            image: fishscene/meshcentral:latest
        ports:
            - 8170:800
            - 8171:4430 ## This is the website port
            - 8172:4433
        environment:
            - URL=test.mydomain.com    ## Externally-accessible hostname, no HTTP/HTTPS
            - mongodbUrl=127.0.0.1:27017/meshcentral
            - agentPong=300
            - port=4430
            - aliasPort=443
            - redirPort=800
            - TlsOffload=127.0.0.1 ## Doesn't actually do anything/Not implemented
        volumes:
            - meshcentral-data:/meshcentral-data        ## Data
            - meshcentral-files:/meshcentral-files      ## Files for use within meshcentral
            - meshcentral-database:/var/lib/mongo       ## Database
            - meshcentral-database-log:/var/log/mongodb ## Database log files

  --MeshCentral Docker Info--

  Environment Variables

    TZ=America/Los_Angeles
    URL=(domain url) ## URL must be in format "myname.domain.top-level-domain". For example: "meshcentral.mydomain.com". DO NOT INCLUDE HTTP/HTTPS, slashes or quotes.
    mongodbUrl=127.0.0.1:27017/meshcentral
    agentPong=300
    port=4430 ## The actual port MeshCentral runs on. 
    aliasPort=443 ## This tells client agents to use 443 (the nginx proxy) to connect instead of port 4430.
    redirPort=800
    TlsOffload=(whatever IP address you want) ## Can be ommitted as it is not currently implemented)

  Volumes

    meshcentral_data:/meshcentral-data
    meshcentral_files:/meshcentral-files

    meshscentral_db:/var/lib/mongo
    meshcentral_dblog:/var/log/mongodb

--NGINX-GUI--

  DETAILS

    Scheme: HTTPS
    Forward Hostname / IP: (IP address of docker host)
    Forward Port: 4430 (Be sure this matches the "port" environment variable. or the docker translated port xxxx:4430)
    Block Common Exploits: Enabled
    Websockets Support: Enabled

  SSL

    Force SSL: Enabled
    HTTP/2 Support: Enabled
