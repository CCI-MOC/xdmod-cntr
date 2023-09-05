# Introduction

Xdmod is currently developed and used in the HPC community as a way to show
system usage for an HPC cluster back to users.  They have build support for
OpenStack into it, but not OpenShift.  It holds the promise of being a unified
platform for consoldating HPC and Cloud services.

As it is currently being used for billing and showback on a HPC cluster
at Harvard, and it initally seemed to be a turnkey type system, we started
to set this it on an OpenShift cluster.  Unfortunately, we have found that it
is not exactly a turn key system.

Xdmod is currently designed to work on a stand alone server.  They do use docker
to develop and to test it.  Although to distruite it, they perfer to use RPMs
and sources.  However there is a project
(https://github.com/rob-baron/hpc-toolset-tutorial) that uses docker compose
to run xdmod and assocated applications in separate docker contains in a
similar manner to how you would run them in kubernetes.  This project formed
a basis for the work to deploy xdmod on the nerc.

On the xdmod side, there is no support for OpenShift, and the OpenStack
support is for an old version of OpenStack.

Addtionally, the environment that we are deploying
to has some difficulties related to storage.
```
    1.  The lack of performance for writes to our volumes
    2.  Our environemnt doesn't have Read Write Many volumes
```
## Lack of Perforamnce for writes to the file system

The lack of performance for writes affects many of the database operations
For example,
```
    1.  Processes occasionally fail due to a falure to get a lock
    2.  Prcessess occasionally take excessive amounts of time
         - restoring the database took 12 hours to run create table
           and simple insert statements
    3.  processing that took less than 5 minutes on ocp-staging runing
        within the moc, took 15-20 minutes.
```
This lack of performance for writing will impact a large number applications
It could be partially worked around if the database was cached in memory or
could be run from ephemeral storage.

From my perspective, this lack of performance on writes will make the cluster
unusable for a wider array of applications and will be a distinct pain point for
early adopters.

## Lack of read write many volumes (RWX persistent volumes)
Although this wont be as painful as the non performant volumes, it is something
that I have had to work around.  For example:
```
  1.  running acl-config in a parallel container with the xdmod-ui container
  2.  running the data export script in parallel container with the xdmod-ui container
  3.  running xdmod-openshift script as an init container, and shredding
      in the main container.
```

## Some things to realize about xdmod's OpenStack integration

For starters, it is using an older unsuppported version of OpenStack.  They have
plans to up date this but so far they have not.  They used ceilometer to pull
the data from OpenStack.  As the current version of OpenStack does not include
ceilometer, this required rework.

Even though they handle many more events (like, creation, power on, power off, ... ),
their test data had a limited set of events.

# What does XDMoD get right

The overall structure of the data base and the processing is generally correct.
The cloud part seems to be more evolved and easier to deal with than the part that deals
with jobs.  Furthermore, the event model of the cloud is a great starting point for
a general transaction log.

It is able to import from muliple sources and process the data from muliple sources
It does this though a very rigorous validation of inputs.  The cloud part keeps
data for a long time while slowly increasing in size due to tracking events as opposed
to individule time slots as it does with the job side.

It has a simple to use interface that presents views of the data, as well as a
simple to use export.

Furthermore, they have a community of users, so there is a wider community that
we could interact with and have a positive impact.

Overall, it is a much better foundation to build off of than the other packages that
we have evaluated in the past (like cloud forms) and I have the impression that it
is auditable as they really don't delete any information needed to track data back to
the log files.  They are doing the hard stuff in an acceptable manner

# Advantages of setting up XDMoD on OpenShift

The advantages that I see for setting up XDMoD on OpenShift are that:

```
    1. It is a actual application that we can use to confirm that our OpenShift
       cluster is useable for database heavy applications

    2. The types of problems we encounter when containerizing XDMoD are going
       to be encountered by our users - and not just for database heavy
       applications.

    3. It has given insights as to how XDMoD could be improved to better suit
       both the monolithic and kubernets installations.  By implication it
       also gives insights how other applications can be modified to better
       suit running on kubernetes.
```

Argueably, setting up XDMoD on OpenShift has exposed:

```
    1. That NESSE is not suitable for database applications, or any application
       that writes to the disk.

    2. That read write many (RWX) volumes are not just syntatic sugar.  You
       either need to specifically code around them or assume that they
       are there.
```

As for point 1, I suspect that NESSE was optimized for accessing large datasets
and not for general use.  I cannot assert this to be the case as I am uncertain
as to the specific configuration options of Ceph.

As for point 2, I have had to find creative ways around this in deploying
XDMoD.  For example, there are cases where I would have liked to have deployed
a certain service as kubernets cron job, however, I had to deploy it as a
parallel container as it required access to same disk as another container.

For example, anything two processes that use the producer consumer pattern.
In XDMoD this is done between the UI and the process that generates the data
downloads, which the UI then consumes when the user downloads them.  I've
had to code around this in the past using a blob

# Database Structure

The database structure can be split into a logical structure and physical structure.
The logical design of the database is located in the .json files that are then used
to construct the physical structure.

For example this json file, etl_tables.d/cloud_OpenStack/raw_event.json, defines a
table in the modw_cloud database:
```
{
    "#": "Raw event information from the Open Stack log files.",
    "#": "Note that almost any field in the raw event logs can be NULL so most fields are nullable.",
    "#": "These will be stored here and filtered out later.  For example, several events with type",
    "table_definition": {
        "name": "OpenStack_raw_event",
        "engine": "InnoDB",
        "comment": "Raw events from Open Stack log events.",
        "columns": [{
                "name": "resource_id",
                "type": "int(11)",
                "nullable": false
            },
            {
                "name": "provider_instance_identifier",
                "type": "varchar(64)",
                "nullable": true,
                "default": null,
                "comment": "Optional instance event is associated with."
            },
            {
                "name": "event_time_utc",
                "type": "char(26)",
                "nullable": false,
                "default": "0000-00-00T00:00:00.000000",
                "comment": "The time of the event in UTC."
            },
            {
                "name": "create_time_utc",
                "type": "char(26)",
                "nullable": true,
                "default": "0000-00-00T00:00:00.000000",
                "comment": "The time of the event in UTC."
            },
            {
                "name": "event_type",
                "type": "varchar(64)",
                "nullable": false
            },
            {
                "name": "record_type",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            },
            {
                "name": "hostname",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            },
            {
                "#": "human readable name at the time the log is written",
                "name": "user_name",
                "type": "varchar(255)",
                "nullable": true,
                "default": null
            },
            {
                "#": "GUID for user",
                "name": "user_id",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            },
            {
                "name": "instance_type",
                "type": "varchar(64)",
                "nullable": true,
                "default": null,
                "comment": "Short version or abbrev"
            },
            {
                "name": "provider_account",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            },
            {
                "name": "project_name",
                "type": "varchar(256)",
                "nullable": true,
                "default": null
            },
            {
                "name": "project_id",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            },
            {
                "name": "request_id",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            },
            {
                "name": "event_data",
                "type": "varchar(256)",
                "nullable": true,
                "default": null,
                "comment": "Additional data specific to an event (e.g., volume, IP address, etc.)"
            },
            {
                "name": "OpenStack_resource_id",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            },
            {
                "name": "disk_gb",
                "type": "int(11)",
                "nullable": true,
                "default": null
            },
            {
                "name": "memory_mb",
                "type": "int(11)",
                "nullable": true,
                "default": null
            },
            {
                "name": "num_cores",
                "type": "int(11)",
                "nullable": true,
                "default": null
            },
            {
                "name": "size",
                "type": "bigint(16)",
                "nullable": true,
                "default": null
            },
            {
                "name": "volume_id",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            },
            {
                "name": "state",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            },
            {
                "name": "domain",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            },
            {
                "name": "service_provider",
                "type": "varchar(64)",
                "nullable": true,
                "default": null
            }
        "indexes": [{
            "name": "resource_id",
            "columns": [
                "resource_id"
            ],
            "is_unique": false
        }]
    }
}
```
the modw_cloud database is also formed from the tables defined in
cloud_common and in cloud_generic.  Each of these directories logical groupings
of tables when you consider the dataflow.  When data is shredded it is added to
either the cloud_OpenStack (in the case of opnstack formatted data), or
cloud_genderic (in the case of the "generic" format).  During ingestation the
data flows from cloud_OpenStack and/or cloud_generic into the cloud_common

The database field sizes are increased using the definitions within the json
files as opposed to using sql to alter the table definition.

There are a similar set of files that seem to define the ETL processes.

## Transaction logs

One thing that I have tried to find and been unsuccessful so far is to get
transaction logs.  The closest thing that I have found is the OpenShift
audit log, but OpenShift doesn't really enable this in any useful manner by default.
However for OpenStack, it might be found by processing the rabbit mq messages - not
entirely sure though.

This is important as it should have something like the following formt
```
Timestamp         | username          | project | Action
------------------+-------------------+---------+---------------------------------------------
01-AUG-2023 16:40 | <robbaron@bu.edu> | TEST II | ColdFront project created
02-AUG-2023 08:00 | <ColdFront>       | TEST II | auto created OpenStack project (uuid)
09-AUG-2023 11:18 | <robbaron@bu.edu> | TEST II | logged on to OpenStack project (uuid)
09-AUG-2023 11:19 | <robbaron@bu.edu> | TEST II | create cinder volume (vol id)
09-AUG-2023 11:20 | <robbaron@bu.edu> | TEST II | created VM (vm id) flavor (...) from volume (vol id)
09-AUG-2023 11:56 | <robbaron@bu.edu> | TEST II | logged off from kaizen (OpenStack) project: RbbTest (id)
...
20-AUG-2023 12:00 | <robbaron@bu.edu> | TEST II | <fritz> added to project TEST II
20-AUG-2023 12:30 | <robbaron@bu.edu> | TEST II | <fritz> set at PI
21-AUG-2023 08:00 | <fritz>           | TEST II | logged on to OpenStack Porject (uuid)
```
The transaction log should be simple for a human to read and understand.  Detailed enough to explain
how the system changed over time.  Generally it is ordered by timestamp and have the actions
of all users on the system.  When explaining things to customers who are paying money, it is
the easiest and fastest way to point out to the customer why a charge appeared on their invoice.

It is quite painful to explain things to customers without an easy to understand transaction
log.

I would highly recommend that such a log is developed.

## advantages to using xdmod
```
  1.  community of users
  2.  Is currently used by NSF to track utilization of HPC clusters
  3.  Seems to have a reeasonable database structure
  4.  does more of what we want to do than cloud forms did
  5.  could be a unified platform for collecting and storing metrics on OpenShfit, OpenStack
      and HPC clusters
  6.  It does the hard part - that is the data wharehousing, tracking history ...
```
## disavantages to using xdmod
```
  1.  Not turnkey for cloud services
  2.  No built in support for OpenShift
  3.  OpenStack support is for a version that is no longer maintained
  4.  The xdmod team does not seem responsive to their ticketing system
  5.  Xdmod is a very large package - it needs to be broken into smaller services
```

By keeping track of the history of a project it automatically takes care of
any of number of use cases.  For example, if a PI changes Instituition taking
the project with them, or a project changes PI or a project that was closed
get a new grant and is reopened or ... .

Like any legacy system, there are parts of xdmod that are done well and parts
that are not.  I have the impression that the xdmod team does not view cloud
support as a priority as they themselves don't deploy any current cloud
service.

It would not suprise me if we decide to drop xdmod only to develop
Furthermore, it would not suprise me if there was one application for OpenShift
and another for OpenStack

# Dockerfiles

Here are the dockerfiles to the project:
```
  1.  Dockerfile.moc-xdmod
  2.  Dcokerfile.moc-xdmod-dev
  3.  Dockerfile.xdmodopenstack
  4.  Dockerfile.docker-test
```

# Dockerfile.moc-xdmod

Initailly I copied over the docker files from the xdmod github repository as I
figured there was the distinct possiblity that some restructuring would be
necessary.  I also wanted to see if the original docker files could be used
as is, as this would potentally make upgrading easier as we would be using what
their process developed.

I had put some changes in to dockerfile to support xdmodopenstack and similar
changes were done to support xdmod-shift.  Along the way, in order to get PRs
approved, we decided that we needed to optimize the dockerfiles.  This substantially
changed the docker files.

Subsequently, I have moved the changes that I made to the original dockerfile
to a different one based on python 3.11 dockerfile.  Likewise, the xdmod-openshift
changes could be isolated.

Currently, I am uncertain if the original dockerfile would still work for us, or if we
could drop in the xdmod team's dockerfile.  I had planned to do this after
moving xdmod-openshift into it's own dockerfile.

# Basic setup

Installation and initial configuration is handled in the Dockerfile.moc-xdmod

## realms and resources

A realm is the main reporting area.  Here are the list of realms
```
    job     - handles basic OpenShift
    cloud   - handles OpenStack
    supremm - should give some performance metrics for OpenShift
```
A resource can be a part of the realms, as I haven't really started to work on the
storage resources (possibly part of a storage realm), I have confirmed this yet
by actually setting them up.

The list of resources are as follows:
```
    1.  xdmodtest          OpenStack test data that the xdmod team uses
    2.  OpenStack          OpenStack instance (CPU and Memory) in the nerc
    3.  openshift_staging  staging OpenShift (not used in production)
    4.  openshift_prod     production OpenShift (CPU and Memory)
    5.  cinder             Allocated cinder storage (not implemented)
    6.  S3                 Allocated S3 storage (not implemented)
    7.  glance             Allocated glance storage (not implemented)
    8.  snapshots          Allocated space for snapshots (not implemented)
```

The resource are configured usings the /etc/resources.json file which is as follows:
```
[
    {
        "resource": "xdmodtest",
        "resource_type": "Cloud",
        "name": "XDMod OpenStack Test Data"
    },
    {
        "resource": "OpenStack",
        "resource_type": "Cloud",
        "name": "OpenStack"
    },
    {
        "resource": "openshift_staging",
        "resource_type": "HPC",
        "name": "OpenShift Staging",
        "timezone": "US/Eastern",
        "shared_jobs": true
    },
    {
        "resource": "openshift_prod",
        "resource_type": "HPC",
        "name": "OpenShift Prod",
        "timezone": "US/Eastern",
        "shared_jobs": true
    }
]
```
The shared_jobs will tell xdmod that the HPC cluster is shared
amoung many jobs, and is used by Supremm to know which resources
need to be aggregated and included on the spremm realm.

# xdmod-setup

xdmod-setup is a tool used to configure/reconfiure parts of xdmod.  It is an
interactive tool that is used to setup the databases, parts of supremm and
to update configuration files.


# xdmod-init

In lieu of modifying xdmod-setup to add a non-interactive option, I went with
using pexpect script with the input being xdmod_init.json included as a
configmap to the project.

xdmod-init is expected to run as an initialization to the xdmod-ui everytime
as the xdmod_init.json is expected to be updated and this is the most consistent
way of updating xdmod by deleting the xdmod-ui pod.

Alernatively, xdmod-init or xdmod-setup can be run from the command line if
one uses rsh to gain access to the xdmod-ui container.  This often requires
the additional step of restarting the xdmod-ui pod as the many changes require
the web process to be retarted.

## xdmod-init processing

The setup of xdmod and supremm present their own challenges.  For one, xdmod a
The setup of xdmod and supremm present their own challenges.  For one, xdmod awwwi

# Basic Processing

The overall processing flow top to down is as follows
```
                  OpenStack                               OpenShift                 KeyCloak        ColdFront

      xdmodopenstack   xdmodopenstack-hypervisors     xdmod-openshift                  xdmod-hierarchy

      xdmod-shredder        xdmod-shredder              xdmod-shredder                   xdmod-import-csv


                                          xdmod-ingestor

                                         aggregate-supremm

                                            acl-config

                                            xdmod-ui

                                       batch_export_manager.php
```


# xdmodopenstack-hypervisors

This script fetches the hypervisor information from OpenStack used in calculating
percent usage.

This was the simpliest script and required very few changes to work.

There was a bug in the command line section of this script that is present in the
upstream version, which we decided to fix with our version of the script.  So our
version will be different and possibly incompatible with the upstream version.

This script produces a file specified on the command line that will need to be
shredded.

# acl-config

This is a small utility that rebuilds the consistency between the configuration files
and the database.  It is needed to be run as there are several processes that
modify one or the other but not both.  It is an example of a work-a-round that
became part of the processing.  From a conversation I had in a meeting with one of
the xdmod developers, it is expected to eventually be eliminated, however it is
currently low priority.

As the xdmod-ui requires the database and configration files to be consistent,
and we do not currently support RWX volumes, this needs to be run in parallel
to the UI.

Most of the time it runs within a couple of minutes, sometimes it takes longer
and will ocassionally fail due to a time out when it cannot lock certain tables.

The fix for this utility is to refactor xdmod to pickup it's configuration
solely from the database making acl-config

# xdmodopenstack

The script xdmodopenstack required to be rewritten as the one that was there
was using ceilometer.  Ceilometer collected metrics that could be used for
billing.  With ceilometer we could have had usage based billing.  Unfortunately,
ceilometer is no longer included in OpenStack.

In order to get the information about VMs, we went with the nova API.  Since the
Nova API only gives information on VMs that are not deleted, by collecting data
every 5 minutes, we expected to catch when VMs stopped running/were deleted.
over time we have had to relax the performance requirements as due to the
non-performant filesystem.  It is currently set to run every 20 minutes, but
even that is probably a bit optimistic.

In both the "OpenShift" and the "Generic" structure there is a way to
track mounted volumes to the VM.  From an initial glance, something like
this should be done to track volume useage, doing so here will not track
volumes that are allocated, but not mounted.

Additionally, there are no instnaces that mount volumes in the test data.

In the first iteration I was using the structure documented in the documentation,
however, after discussing it with the xdmod team it was recommended that I use
their "OpenStack" structure.  It is a bit different and it is the one that they
provide test data for.  I went with their recommendation and changed the code to
use the OpenStack structure.

Once I found their test data, I was able to use that to confirm my setup was working
for cloud data.  I was also able to use their test data to understand the details of
the format.

There seem to be 2 stages of verification.  The first is to confirm that the file has
the correct format.  Generally, the data fields should be strings.  The second stage
will unpack the data from the first stage and ensure that the second stage has
the correct format before it is inserted into the database.  There were several
fields that required an integer inside of a string.

Despite the xdmod team saying that it doesn't matter what a particular field is,
what they mean is that as long as it can pass validation, it may not be currently
used.  In any case, for all values I tried to make them as consistent as possible
to potentially avoid going to a new version and finding that a particular value
is causing issues.

A couple of notible examples being the audit_period and the flavor_id.

In the test data that is provided, an audit_period field is provided.  This could
be tied to a yearly audit of a grant, or it could be tied to a quarterly audit
period.  The xdmod team came back and stated it wasn't used.  Since it was filled
out in the sample data, I just filled it in with something that makes sense.

The flavor_id is actually tracked in xdmod, and is required to be an integer
within a string or it will not pass the validation.  The version of OpenStack
that they were using has it as an integer.  In the current version
the flavor id is a typcial OpenStack uuid.  In order to be able to go from
the xdmod id to the OpenStack id, I changed the flavor name to
"Unknown Flavor (flavor uuid)".

The error messages that xdmod generates via the package they use for validation
are confusing at best.  The error message will tell you that some type was expected
where a different type was found.  Generally, I created files with 1 record
per file and ran them until the error appeared.  Since I knew the type, I could
focus on values of that type and incrementally work though the 1 record that was
not working.  It was far easier getting though the first level validator than
the second.

## Some specific events that needed to be translated from current to past

Because xdmod suppored an older version of OpenStack, many of the events
have changed.

For example, "compute.instance.create" gets converted to either a
"compute.instance.error" or to 2 events - "compute.instance.start",
"compute.instance.end"

The code has more instances of this.  It isn't clear to me if this is due
to ceilometer collecting events from RabbitMQ or if it is collecting events
from Nova.  Ultimately, xdmod should be changed to hanle the event types
that currently supported versions of OpenStack use.

## envents handeled

Here are the the current events that are handled:
    volume.attach
    volume.detach
    volume.create
    volume.delete
    compute.instance.volume.attach
    compute.instance.volume.dettach
    compute.instance.resume
    compute.instance.suspend
    compute.instance.unshelve
    compute.instance.resize
    compute.instance.create
    compute.instance.delete
    compute.instance.live_migration
    compute.instance.power_off
    compute.instance.power_on
    compute.instance.shutdown

As mentioned elsewhere, the volume events are not completely meaningful
without knowing all of the unattached volumes.  So these probably
should not be included.

I suspect that live migration is not handled correctly by xdmod, so it
should probably be translated to a power_off and a power_on events.

I am also suspecting that we are not reporting on when the system was shutdown
as either Nova didn't send that information out on the API, or we are not
processing the right set of evens

In all of the code reviews, I don't recall any conversation over which events
need to be processed.  We did discuss why events get translated to different
events

## About volume events

I did spend time on handling the volume events and was in the middle of
debugging them, but never pulled the code out, as I initially thought that
this would track all of the disk usage, though I was confused by the data
structure.  After working through How volumes are actually tracked I
discovered that this was not going to provide anything that could be
used, though it might be important for showback.  It is for this reason
that I kept the code in place and didn't remove it.

I've added an issue to either remove or fix the volume evens.

The way that seems to be used by xdmod to account for volumes, is via
storage metrics.  With storage metrics, each storage class will have it's
own resource.  This is more general than just volumes as it could be
used to track any storage (glance, swift, S3, ... ) by giving it a
specific resource name.

# xdmod-openshift

This was mainn's constribution to this project.  Currently it runs within the container that
is built from the Docker.moc-xdmod docker file.  It should be refactored to run in the
python3.11 container like xdmodopenstack does.

What this script does is to make OpenShift look like a slurm cluster to xdmod.  The log
files can be shreadded and ingested in the same manner

My current recommendations (also in the issues),

    1.  move this to a python 3.11 container as it is python only
    2.  fix the manifests, instead of having a ..._prod and a ..._staging manifest adopt the
        following structure:
            i.  create a generic manifest within the main directory for xdmod-openshift
           ii.  create specific overlays in each of the supported overlay directires

It wasn't until we actually started looking at the data in May that we realized that
CPU was not appearning for jobs in the interface.  As this was something that I was very
focused on in getting data in on the OpenStack side and how I found the flavors that
were deleted, I was surprised that it wasn't noticed by anyone until we were gathering
data on the OpenShift(job) side.  So I started looking in to this.

With kim, we looked at the database structure and the data that was being pulled from
OpenShift.  The type coming from OpenShift is in fractions of a CPU which is a floating
point type, where as the database field that this is stored in is an iteger.  Addtionoally,
in the supremm database, this becomes a floating point.

I have just started to work with the data that is processed here as it was not inserting any
CPU data into the jobs table.  This was due to the data coming from OpenShift often in
fractional amounts of CPU.  One simple solution to this is to store the data in milli CPU by
multiplying by 1000.  This was tested in the xdmod-staging project on the nerc-infra cluster
and seemed to work (ie, I got milli CPU in the jobs table).

I then tried to setup Supremm on the staging project, and the process failed when running
from xdmod-setup.  I did get the staging mariadb setup by restoring from a backup of production
though something is wrong with the configuration of mongo.  I opened a ticket with xdmod
as xdmod-setup failed to configure supremm - seems to have some issue.

Although I opened tikets with the xdmod team about aggregate_supremm running to
completion without aggregating anything in considering the data, there is nothing to
aggregate, so while I was waiting for the xdmod team to get back in touch with me
I was working on providing data to aggregate.

# xdmod-hierarchy

In order to report to insititutions, departments and PIs; a system wide hierarchy can
be defined to aggreate statistics at the appropriate level.  This is done using
csv files that define each level - the xdmod documentation explaination can be
found in (https://open.xdmod.org/10.0/hierarchy.html,
https://open.xdmod.org/10.0/user-names.html, https://open.xdmod.org/10.0/cloud.html).
I will try to cosolidate and explain this a bit better.

Depending on if it is a HPC job or a cloud resource there are different levels to
the hierarchy.  This is due to jobs not having a project name associated with
them.  To side by side compare:
```
        Job(OpenShift)              cloud(OpenStack)             file
        -----------------------------------------------------------------------
        Unit                        Unit                         hierarchy.csv
          division                    division                   hierarchy.csv
             department                 department               hierarchy.csv
               PI                         PI                     group.csv
                 group name                 group name           names.csv
                                              project name       pi2project.csv
```
Since we have OpenShift implemented as an HPC resoource and OpenStack as a cloud
resource, we need to effectively remove a layer of the cloud hierarchy.  This was
done by mapping OpenStack projects to OpenStack projects in the pi2project.csv
file.

Defining the first 3 levels of the hierarchy is done via the hierarchy.json file
just as explained in the xdmod documentation.

Unfortunately, when developing this xdmod used different names to define the PI
layer.  They will use PI and group interchangably.  This is confusing and hopefully
they will fix this in a future release with a better hierarchy system.

We decided on the following hierarchy:
```
    Instititution
        field of science
            PI
                ColdFront Project
                    OpenStack/OpenShift project
```

What was implemented was a table to keep track of the history of the hierarchy.
This was done as simplistic as possible, while being mindful of the non-perofromant
file system.  Initially this set of tables will only have current records so
implementing a current table with the history table seems a bit complicated
especially given that the depth of the history table will be very minimal for
the first year or so.  Without knowing how this set of tables grows, it is
impossible to determine if the addtional complexity of a set of current hierarchy
tables is worth the cost of development.

I anticipate the need to recreate the hierarchy files at some arbitary date.  Although this feature
is not implmented, it can easily be implemented by selecting all of the records prior to an arbitary
date.  Use cases would be for testing the system with real world data, replicating problems or
auditing the system.

The structure is as follows:
```
hierarchy_rec
+--------------+--------------+------+-----+---------+-------+
| Field        | Type         | Null | Key | Default | Extra |
+--------------+--------------+------+-----+---------+-------+
| id           | bigint(20)   | NO   | PRI | NULL    |       |
| create_ts    | datetime(6)  | NO   | PRI | NULL    |       |
| type         | varchar(100) | NO   |     | NULL    |       |
| name         | varchar(500) | NO   |     | NULL    |       |
| status       | varchar(100) | YES  |     | NULL    |       |
| display_name | varchar(500) | YES  |     | NULL    |       |
| parent_id    | bigint(20)   | YES  |     | NULL    |       |
+--------------+--------------+------+-----+---------+-------+
```

In the begining, most of the records will need to be fetched, so the current code just
selects everything from the table processing everything as it comes, keeping only the
most recent hierarchy item for each combination of hierachy_id/timestamp.  As this
SQL statment doens't require a virtual table, it is just reading the table and sending
it out, we are never writing to the filesystem.

The obvious way to speed this up is to create a table that just has the most recent
active entires (the current hirearchy table set).  With such a table, you don't need
to do any processing after selecting from it, and it is just a select, so this will
be a fast operation given our backend filesystem.  Inserting/updating does become
more complicated, but is still relatively straightforward.  This tactic would work
well with SQL, or with an ORM.

It was suggested that we use the ORM SQLAlchemy.  I considered this, and since it supports
multiple databases, I would assume that it crafts SQL differetnly baseed on which database
it is connecting to.  For example, to get good performance from OracleRDB (formerly dec's
relation database system), queries are written differently than for Oracle.  Although I
hope it supports a file system that reads qucikly, but doesn't write quickly, I can find
no guarentee of this, so I have created an issue to explore this in the future when we
have more actual data (and the backend supports reasonable writing speeds).  To effectively
add this in the future would require performance testing to ensure that SQLAlchemy is
doing what we think it is doing.

It was also suggested that I use a "limit by 1" since all I'm interested in is just the most
recent entry.  Although, on the surface this seems reasonable, there are some problems
with it.  To pull from the most recent one will require a sorting (an order by) which creats
and writes a virtual table to perform the sort and then to return the first record.
Furthermore, we would have to query for each hierarchy_id in the hierarchy table.  I
rejected this as the best way to speed this up is to refactor the code to have an
aforemented table dedicated to the currently active items.

As output, the xdmod-hierarchy script will produce the following files:
```
    hierarchy.csv  - specifies the 3 level hierarcy of institution, field of study, PI
    group.csv      - has the mapping of nerc project to PIs
    names.csv      - has the mapping of OpenShift namespaces and OpenStack projects to
                     the nerc project
    pi2project.csv - maps the OpenStack project to the OpenStack project
```

## An example set of files
### hierarchy.csv
```
"1", "Boston University",
"2", "Harvard University",
"3", "Boston University - physical_sciences", "1"
"4", "Harvard University - physical_sciences", "2"
"5", "Rob Baron", "3"
```
### group.csv
```
"Rob's ColdFront Project","5"
```
### names.csv
```
"RobOpenStackProject-f123abc", "Rob's ColdFront Project"
"robs-pen-shift-project-f123abd", "Rob's ColdFront Project"
```
### pi2project.csv
```
"RobOpenStackProject-f123abc", "RobOpenStackProject-f123abc"
```

The format of the hierarchy file is as follows:
```
id, Name, parent_id
```
"Boston University" has an id of "1", and is at the root level.  On level 2
we have field of science which has to be a cartesean as field of science
has a many to many relationship with institution.  That is any given university
can have many fields of science and any given field of science can be associated
with many universities.  Finally, I used my name at the PI level in the hierarchy
file.

The group.csv file relates ColdFront project names to the id of the PI in the hierarchy
file.

The names.csv file relates the OpenStack or OpenShift project name to the
ColdFront project name found in the group.csv

And finally for OpenStack, we need to effectively squash a layer of the hierarchy
in order to match the jobs side, so pi2project just maps an OpenStack project
to an OpenStack project that is found in the names.csv.

The examples found in the xdmod documentation use abbreviations for unique keys.  This
doesn't suit an automated system as there are cases where there are multiple
colleges/universities with the same name.  For example, I went to westminster college,
at the time there were 5 westminster colleges.  Since, we really don't need a
human readable ID, I found using numbers to be more convienent.

After working through that example, it is obvious that many of the hierarchy items
need to have unique IDs.  Initially, I was under the impression that
RegApp/ColdFront/KeyCloak would also need to have unique ids for this data, however,
this was not the case.

It was suggested that we use a cryptological signiture to give unique ids as the possiblity
of a data collision is miniscule.  The advantage here would be that there would be no
database access to determine what the ID would be.  It turned out to be a bit more
complicated, as each item in the hierarchy needed its own unique ID.  It was simpler to create
a sequencer in the database and look up the keys when needed.  We needed a database
anyway since we need to track the history of the hierarcy for potential audits as
I am uncertain how long the information will be kept in ColdFront or keycloak when
users and projects are deleted.

And here are the commands that load the CSVs into the xdmod database:
```
    xdmod-import-csv -t hierarchy -i hierarchy.csv
    xdmod-import-csv -t group-to-hierarchy -i group.csv
    xdmod-import-csv -t names -i names.csv
    xdmod-import-csv -t cloud-project-to-pi -i pi2project.csv
    acl-config
```

In termas of testing what I was originally attempting to do was to create a test
container that was derived from the dockerfile that contained xdmod-hierarchy and
included mariadb with all of the pytest moducles.  This could eventually be
incorporated in to test sequence in github to run pytest each time the container
was built on github as part of our CI process.

This would also work with how I deploy xdmod on OpenShift using build
configurations to test before actual deployment.  Furthermore, it could be used
to test the production system in situ.

As I was having difficulty with getting this to work I simplifed it a great
deal, just to have the tests run inside a container.  In the process, found that
for stand-a-lone installs, mariadb was creating root accounts without a password
that had to be accessed from the root account on that system.  After trying
several ways suggested by the mariadb documentation and from stack exchange,
settled on using it the way it was designed.

Another option would be to use a service container to host mariadb, however,
this initially seemed a bit more complicated than just adding mariadb to the
python container and running the tests with the database as localhost.  In
retrospect, since google actions can run mariadb in a service container
adding the test code to the xdmod-openstack container would ahve been
better.

In considering this further, I was starting to plan to rename the python
files from how they are currently named to names that match how they
are deployed.  This way the test code could refer to the same files.

By deploying a test container that is built from the container with
the production code, the tests could be performed in the same
environment as production as well as performed by github actions.

# Backups

I've manually done this process to create and restore a backup multiplie times.
Here are the manual steps that I planned on automating:

## Backup

I had quickly implemented a backup process, but this process was deemed
not production ready as it used the database as an intermedeary stage
as opposed to writing directy to an S3 storage.  The S3 storage that
was initially to be used was recinded and it was decided that we couldn't
use the s3 storage that is associated with the MOC as it was going
away.  So automating the backups became a lower priority until an
appropriate backup location could be found.

Here is the manual backup process.

```
  1   tar -zcvf etc-xdmod.tgz /etc/xdmod
  2   tar -zcvf usr-share-xdmod.tgz /usr/share/xdmod
  3.0 mysqldump -h maraidb -u root -p --databases  file_share_db mod_hpcdb mod_logger mod_shredder moddb modw modw_aggregates modw_cloud modw_etl modw_filters modw_jobefficiency modw_supremm > xdmod-db-backup.sql
  3.1 gzip xdmod-db-backup.sql
  4 create a pod, mounting the volumes used by xdmodopenstack and xdmod-shift to back up the files created by the cronjobs
```

## Restore:
```
  0.  cd /
  1.  tar -zxvf /root/xdmod_data/etc-xdmod.tgz
  2.  tar -zxvf /root/xdmod_data/usr-share-xdmod.tgz
  3.  mysql -h mariadb -u root -pass > source xdmod-db-backup.sql
  4.  create a pod, mounting the volumes used by xdmodopenstack and xdmod-shift
     to back up the files created by the cronjobs
```

In the future, there will be no need to backup the /usr/shar/xdmod as these are
the sources and I expect these to be immuntable.  However, there are several
applicationstions that modify both the database and the config file, namely:
```
xdmod-shredder
xdmod-ingestor
xdmod-import-csv
...
```
Although acl-config will sync the config files with the database state, at this
time I am not recommending that limitations to acl-config be unintentionally
found, and so the current recomendation would be to back up the config directory
at the same time as the database.

Interesting to note, to dump all of the data from mariadb, tends to be quick,
Usually less than an hour.  When I did this the last time, I kiecked off the
mysqldump command and after creating the pod to pull the PV data, came back to
find the dump process had finished.  The bigger issue was copying the data off
as an unexpected EOF occurred several times later that evening.  In the
morning, running the same command worked without issue.

# Getting data out
For VM/pod level reporting, the data export should aggregate the sessions table
(for OpenStack) or the jobs table (for OpenShift).  In particular, the data
export section seems to be the least flexible/configurable of any other part
of xdmod.

At this time there is no facility to pull session level data from xdmod aside from
dumping specific tables that hold the session data.

For cloud sessions:
```
select * from modw_cloud.session_records;
```
For job sessions:
```
select * from mod_hpcdb.hpcdb_jobs;
```

However based on the new requirment for reporting on computation units.  In order to
do this we will need a custom report.
# storgae reporting

There is a section of xdmod used for reporting on storage.  It is covered here:
```
https://open.xdmod.org/10.0/storage.html
```
The file format is, at least in the documentation, simpler:

```
    [
        {
            "resource": "nfs",
            "mountpoint": "/home",
            "user": "jdoe",
            "pi": "pi_username",
            "dt": "2017-01-01T00:00:00Z",
            "soft_threshold": 1000000,
            "hard_threshold": 1200000,
            "file_count": 10000,
            "logical_usage": 100000,
            "physical_usage": 100000
        },

        ...
    ]
````

Each storage class will require it's own resource.  It is basically what you have used at the given time.

In order to tie it into the hierarchy, the "pi" field should probably be the NERC project name, with the "user" field being either the OpenStack or OpenShift project name.  The resource is probably the name of the specific resource in the resources.json file.

As these resources need to be different that OpenStack or OpenShift resources, they could be named, NercProdCinder, NercProdSwift, NercOcpPV, NercInfraPV ... .

No work was done on this as it was not needed for the MVP, however this will be required to achieve parity with the custom scripts that naved and kristi have written.
