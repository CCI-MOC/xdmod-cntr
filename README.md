# xdmod-cntr

A project to prototype the use of XDMOD with OpenStack and OpenShift on the MOC

# Introduction

XDMod is located here: (https://open.xdmod.org/9.5/index.html)
XDMod framework's github: (https://github.com/ubccr/xdmod)
XDMod OpenStack Connector is here (https://github.com/ubccr/xdmod-openstack-scripts)
a tutorial that build the current version of XDMod in a container is located here (https://github.com/ubccr/hpc-toolset-tutorial)

At the current time, the tutorial stopped working so to make modifications to the openstack to xdmod script I need a working 
instance of xdmod.  I intend to do this using docker compose

Here I am explaining parts of the docker compose files and the rationale.

    1) Building xdmod
       
        docker build -d Dockerfile.xdmod-base -t moc-xdmod-base .
        docker build -d Dockerfile -t moc-xdmod .

    The xdmod-base docker file is directly from the xdmod source code - will reference that on in the future.  The moc-xdmod container
    just installs xdmod from rpm as per their install instructions on their website.

    2) Bring up the database using docker compose:

        db:
          image: mariadb
          restart: always
          container_name: mariadb
          environment:
            MYSQL_ROOT_PASSWORD: pass
          networks:
            - compute
          volumes:
            - ./database:/docker-entrypoint-initdb.d
            - ./mysql.d:/etc/mysql/mariadb.conf.d
          ports:
            - "3306:3306"
          expose:
            - "3306" 

    The docker-entrypoint-initdb.d is just the mariadb initialization from the hpc tutorial, the mariadb.conf.d is mostly to set the
    address that is bound is 0.0.0.0, so that mariadb listens to all of the network interfaces.

    The network name and container_name have to be specified so that the container can easily address other containers on the same network. 

    mariadb can be accessed accessed using the following command line on the host:

        mysql -h localhost --protocol=tcp -u root -p

    and from the xdmod container that is started up on the compute networked:

        docker run -it --network=xdmod-cntr_compute moc-xdmod /bin/bash
        mysql -h mariadb --protocol=tcp -u root -p
    
    3) Bring up mongodb using docker compose:

        mongodb:
          image: mongo:3.6.18
          hostname: mongodb
          container_name: mongodb
          environment:
            - MONGO_INITDB_ROOT_USERNAME=admin
            - MONGO_INITDB_ROOT_PASSWORD=hBbeOfpFLfFT5ZO
          networks:
            - compute
          volumes:
            - ./mongodb:/docker-entrypoint-initdb.d 
          ports:
            - "27017:27017"
          expose:
            - "27017"

    This can be accessed from the command line on the host:

        mongosh "mongodb://localhost:27017"

    4) Configure xdmod 

        xdmod-setup doesn't change the php.ini file as the php.ini is read only.  This needed to be configured when the container
        is created.

        had to change the httpd.conf - to run php as a stop-gap measure 
        overwrite the ssl.conf - am not authenticaing users correctly, nor do I have ssl setup correctly 
        overwrite the php.ini  - this sets the database host (mariadb), user (xdmod) and pass (pass) for each of the database connections.

        this will bring up the interface with the following error indicating that the ingestion script needs to be run first

        Here is a chicken vs egg issue, supremeMM indicates that xdmod needs to be configured and running first before install, however
        to install for openstack, supremeMM needs to be in place to ingest the data from OpenStack.

    5) install and configure supremeMM

      a) setup mongodb

            - need to setup an administrative user correctly

            mongosh "mongodb://localhost:27017"

                use admin;

                db.createUser({
                  user: 'xdmod', 
                  pwd: 'pass', 
                  roles: [{role: 'readWrite', db: 'supremm'}]
                }); 
                db.createUser({
                  user: 'xdmod-ro', 
                  pwd: 'pass', 
                  roles: [{role: 'read', db: 'supremm'}]
                });

      b) installing of supremm in the docker file using instructions here:
           https://supremm.xdmod.org/9.5/supremm-install.html
           https://supremm.xdmod.org/9.5/supremm-processing-configuration.html

      c) configuring supremm see (supremmconfig.json)
       
      This requires some data and the RPM install doesn't provide the supremm-setup script as described in the install/configuration 

    6) install and configure xdmod-openstack script

        a) modified hypervisor_facts.py to use the currently supported keystone api.

        b) rewriting openstack_api_reporting.py
            
            i) modified to use the currently supported keystone api.

            ii) modifying to use the standard openstack API
    
----------------  I am currently here ------------------    
    
    
    5) Load supremeMM and configure it to use mongodb

    6) load the OpenStack tooling in and configure to hit openstack
    
