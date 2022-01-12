# xdmod-cntr
A project to prototype the use of XDMOD with OpenStack and OpenShift on the MOC
# Introduction

XDMod is located here: (https://open.xdmod.org/9.5/index.html)
XDMod framework's github: (https://github.com/ubccr/xdmod)
XDMod OpenStack Connector is here (https://github.com/ubccr/xdmod-openstack-scripts)
a tutorial that build the current version of XDMod in a container is located here (https://github.com/ubccr/hpc-toolset-tutorial)

The easiest way that I have found to get an XDMod instance running on my mac is to the use the container found in the tutorial.  So I would consider basing our project off of the tutorial to be the quikest way to do initial development.

# Suggested development path

In working through the tutorial, it installs a minimal installation of several HPC tools including a simulated HPC environment to connect with.

So to transform the tutorial to something that we can use for both development and for production:

    1) Refactor the tutorial to run only XDMod
        a) remove god accounts, unneccessary tooling
        b) add in the neccessary tooling
    2) install the tooling needed for the OpenStack Connector
    3) modify the OpenStack Connector
        a) Remove the deprecated parts of it (celiometer/panko)
        b) We replaced celiometer and panko with our monitoring tool (zabbix) and then hit zabbix for reporting
           Not sure if we should go directly to libvirt (what zabbix was doing) or if there is a more appropriate monitoring solution that the NERC already uses
 
I'm currently planning to use docker containers/docker compose for local development, Use OpenShift for stagining and Production.  In reviwing the source code there are multiple langauges (PHP, python, java?) and multiple databases (mariadb and mongo).  