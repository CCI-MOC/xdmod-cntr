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

    4) Configure xdmod to use mariadb

    
----------------  I am currently here ------------------    
    
    
    5) Load supremeMM and configure it to use mongodb

    6) load the OpenStack tooling in and configure to hit openstack
    
