#Introduction

Xdmod is currently developed and used in the HPC community as a way to show
system usage for an HPC cluster back to uses.  They have build support for
OpenStack into it, but not OpenShift.

As it is currently being used for billing and showback on a HPC cluster
at Harvard, and it initally seemed to be a turnkey type system, we started
to set this it up on an openshift cluster.

Xdmod is currently designed to work on a stand alone
server.  The do use docker to develop and to test it. Although to distruite it,
they perfer to use RPMs and sources.  However there is an project
(https://github.com/rob-baron/hpc-toolset-tutorial) that uses docker compose
to run xdmod and assocated applications in separate docker contains in a
similar manner to how you would run them in kubernetes.  This project formed
a basis for the work to deploy xdmod on the nerc.

There are some common problems we have with our current environment

    1. The lack of performance for writes to our volumes
    2. Our environemnt doesn't have Read Write Many volumes

##Lack of Perforamnce for writes to the file system

The lack of performance for writes affects many of the database operations
For example,

    1. Processes occasionally fail due to a falure to get a lock
    2. Prcessess occasionally take excessive amounts of time
        - restoring the database took 12 hours to run create table
          and simple insert statements
    3. processing that took less than 5 minutes on ocp-staging runing
       within the moc, took 15-20 minutes.

This lack of performance for writing will impact a large number applications
It could be partially worked around if the database was cached in memory or
could be run from ephemeral storage.

From my perspective, this lack of performance on writes will make the cluster
unusable for a wider array of applications and will a distinct pain point for
early adopters.

##Some things to realize about xdmod's openstack integration
For starters, it is using an older unsuppported version of openstack.  They have
plans to up date this but so far they have not.  They used ceilometer to pull
the data from openstack.  As the current version of openstack does not include
ceilometer, this required rework.

Even though they handle many more

#Dockerfiles

Here are the dockerfiles to the project:
```
  1. Dockerfile.moc-xdmod
  2. Dcokerfile.moc-xdmod-dev
  3. Dockerfile.xdmod-openstack
  4. Dockerfile.docker-test
```

#Dockerfile.moc-xdmod
Initailly I copied over the docker files from the xdmod github repository as I
figured there was the distinct possiblity that some restructuring would be
necessary.  However, I also wanted to see if the original docker files could be used
as is, as this would potentally make upgrading easier as we would be using what
their process developed.

I had put some changes in to dockerfile to support xdmod-openstack and similar
changes were done to support xdmod-shift.  Along the way, in order to get PRs
approved, we decided that we needed to optimize the dockerfiles.

Subsequently, I have moved the changes that I made to the original dockerfile
to a different one based on python 3.11 dockerfile.  Likewise, the xdmod-openshift
changes could be isolated.

Currently, I am uncertain if the original dockerfile would still work for us, or if we
could drop in the xdmod team's dockerfile.  I had planned to do this after
moving xdmod-openshift into it's own dockerfile.

#Basic Processing

#xdmod-openstack-hypervisors
This script fetches the hypervisor information from openstack used in calculating
percent usage.

This was the simpliest script and required very few changes to work.

There was a bug in the command line section of this script that is present in the
upstream version, which we decided to fix with our version of the script.


#xdmod-openstack

#xdmod-openshift
This was mainn's constribution to this project.  Currently it runs within the container that
is built from the Docker.moc-xdmod docker file.

My current recommendations (also in the issues),

    1.  move this to a python 3.11 container as it is python only
    2.  fix the manifests, instead of having a ..._prod and a ..._staging manifest adopt the
        following structure:
            i. create a generic manifest within the main directory for xdmod-openshift
           ii. create specific overlays in each of the supported overlay directires

I have just started to work with the data that is processed here as it was not inserting any
CPU data into the jobs table.  This was due to the data coming from openshift often in
fractional amounts of CPU.  One simple solution to this is to store the data in milli CPU by
multiplying by 1000.  This was tested in the xdmod-staging project on the nerc-infra cluster
and seemed to work (ie, I got milli CPU in the jobs table).

I then tried to setup Supremm, and the process failed when running from xdmod-setup.

I did get the staging mariadb setup by restoring from a backup of production

#xdmod-hierarchy

What was implemented was a basic history table.  This was done in a simplistic way possible,
while being mindful of the non-perofromant file system.

I anticipate the need to recreate the hierarchy files some arbitary date.  This could be for
testing the system with real world data, replicating problems or auditing the system.

The structure is as follows:
```
```

In the begining, most of the records will need to be fetched, so the current code just
selects everything from the table processing everything as it comes, keeping only the
most recent hierarchy item for each combination of hierachy_id/timestamp.  As this
SQL statment doens't require a virtual table, it is just reading the table and sending
it out, we are never writing to the filesystem.

The obvious way to speed this up is to create a table that just has the most recent
active entires. With such a table, you don't need to do any processing after selecting
from it, and it is just a select, so this will be a fast operation giving our backend
filesystem.  Inserting/updating does become more complicated, but this is relatively
straightforward.

It was suggested that we use the ORM SQLAlchemy.  I considered this, and since it supports
multiple databases, I would assume that it crafts SQL differetnly baseed on which database
it is connecting to.  For example, to get good performance from OracleRDB (formerly dec's
relation database system), queries are written differently than for Oracle.  Although I
hope it supports a file system that reads qucikly, but doesn't write quickly, I can find
no guarentee of this, so I have created an issue to explore this in the future when we
have more actual data (and the backend supports reasonable writing speeds).

It was also suggested that I use a "limit by 1" since all I'm interested in just the most
recent entry.  Although, on the surface this seems reasonable, there are some problems
with it.  To pull of the most recent one will require a order implies creating and
writing a virtual table to perform the sort in and then to return the first record.
Furthermore, we would have to a query for each hierarchy_id in the hierarchy table.  I
rejected this as the best way to speed this up is to refactor the code to have an
aforemented table dedicated to the currently active items.

#Backup

I've manually done this process to create and restore a backup multiplie times.
Here are the manual steps that I planned on automating:

## Backup
'''
  1   tar -zcvf etc-xdmod.tgz /etc/xdmod
  2   tar -zcvf usr-share-xdmod.tgz /usr/share/xdmod
  3.0 mysqldump -h maraidb -u root -p --databases  file_share_db mod_hpcdb mod_logger mod_shredder moddb modw modw_aggregates modw_cloud modw_etl modw_filters modw_jobefficiency modw_supremm > xdmod-db-backup.sql
  3.1 gzip xdmod-db-backup.sql
  4 create a pod, mounting the volumes used by xdmod-openstack and xdmod-shift to back up the files created by the cronjobs
'''

## Restore:
 '''
  0. cd /
  1. tar -zxvf /root/xdmod_data/etc-xdmod.tgz
  2. tar -zxvf /root/xdmod_data/usr-share-xdmod.tgz
  3. mysql -h mariadb -u root -pass
     > source xdmod-db-backup.sql
  4. create a pod, mounting the volumes used by xdmod-openstack and xdmod-shift to back up the files created by the cronjobs
'''

In the future, there will be no need to backup the /usr/shar/xdmod as these are the sources and I expect these to be
immuntable.  However, there are several applicationstions that modify both the database and the config file, namely:
'''
xdmod-shredder
xdmod-ingestor
...
'''
Although acl-config will sync the config files with the database state, at this time I am not recommending that
limitations to acl-config be unintentionally found, and so the current recomendation would be to back up the
config directory at the same time as the database.

Interesting to note, to dump all of the data from mariadb, tends to be quick, Usually less than an hour.  When I did
this the last time, I kiecked off the mysqldump command and after creating the pod to pull the PV data, came back
to find the dump process had finished.  The bigger issue was copying the data off as and unexpected EOF occurred
several times later that evening.  In the morning, running the same command worked without issue.
