# meshcentral
A self-contained MeshCentral, designed to run behind nginx-gui.


Installs latest updates, MongoDB, and MeshCentral on first deployment of the container.

  --MeshCentral Docker--

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
