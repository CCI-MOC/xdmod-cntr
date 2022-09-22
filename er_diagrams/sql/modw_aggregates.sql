-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: mariadb    Database: modw_aggregates
-- ------------------------------------------------------
-- Server version	10.3.34-MariaDB-1:10.3.34+maria~focal

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `jobfact_by_day`
--

DROP TABLE IF EXISTS `jobfact_by_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobfact_by_day` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `day_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.days.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the day',
  `day` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The day of the year.',
  `record_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource on which the request was made',
  `task_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource on which the jobs ran',
  `resource_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the resource that the jobs ran on.',
  `resourcetype_id` int(11) NOT NULL COMMENT 'DIMENSION: The type of the resource on which the jobs ran. References resourcetype.id',
  `systemaccount_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the resource system account (local username) under which the job ran. References systemaccount.id',
  `submission_venue_id` int(11) NOT NULL COMMENT 'DIMENSION: The method used to submit this job: cli, gateway, ...',
  `job_record_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Task type or event.',
  `job_task_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Type of job: hpc, cloud, hpc-reservation, ....',
  `queue` char(255) NOT NULL COMMENT 'DIMENSION: The queue of the resource on which the jobs ran.',
  `allocation_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of allocation these jobs used to run',
  `account_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the account record from which one can get charge number',
  `requesting_person_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the person that requested the resources (e.g., made the reservation or submitted the job.',
  `person_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the person that ran the jobs.',
  `person_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the person that ran the jobs.',
  `person_nsfstatuscode_id` int(11) NOT NULL COMMENT 'DIMENSION: The NSF status code of the person that ran the jobs. References person.nsfstatuscode_id',
  `fos_id` int(11) NOT NULL COMMENT 'DIMENSION: The field of science of the project to which the jobs belong.',
  `principalinvestigator_person_id` int(11) NOT NULL COMMENT 'DIMENSION: The PI that owns the allocations that these jobs ran under. References principalinvestigator.person_id',
  `piperson_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the PI that owns the project that funds these jobs. References piperson.organization_id',
  `job_time_bucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Job time is bucketing of wall time based on prechosen intervals in the modw.job_times table.',
  `job_wait_time_bucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Job wait time is bucketing of wait time based on prechosen intervals in the modw.job_wait_times table.',
  `node_count` int(11) NOT NULL COMMENT 'DIMENSION: Number of nodes each of the jobs used.',
  `processor_count` int(11) NOT NULL COMMENT 'DIMENSION: Number of processors each of the jobs used.',
  `processorbucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined processor bucket sizes. References processor_buckets.id',
  `gpu_count` int(11) NOT NULL COMMENT 'FACT: Number of GPUs each of the jobs used.',
  `gpubucket_id` int(11) NOT NULL COMMENT 'DIMENSION: Pre-determined GPU bucket sizes. References gpu_buckets.id',
  `qos_id` int(11) NOT NULL COMMENT 'DIMENSION: Quality of service. References qos.id',
  `submitted_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that started during this day.',
  `ended_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that ended during this day.',
  `started_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that started during this day.',
  `running_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that were running during this day.',
  `wallduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The wallduration of the jobs that were running during this period. This will only count the walltime of the jobs that fell during this day. If a job started in the previous day(s) the wall time for that day will be added to that day. Same logic is true if a job ends not in this day, but upcoming days.',
  `sum_wallduration_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of wallduration of the jobs that were running during this period. This will only count the walltime of the jobs that fell during this day. If a job started in the previous day(s) the wall time for that day will be added to that day. Same logic is true if a job ends not in this day, but upcoming days.',
  `waitduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of time jobs waited to execute during this day.',
  `sum_waitduration_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of time jobs waited to execute during this day.',
  `local_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `local_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `local_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `sum_local_charge_xdsu_squared` double DEFAULT NULL COMMENT 'FACT: The sum of the square of local_charge of jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `cpu_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the cpu time (processor_count * wallduration) of the jobs pertaining to this day. If a job took more than one day, its cpu_time is distributed linearly across the days it used.',
  `sum_cpu_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of the cpu_time of the jobs pertaining to this day. If a job took more than one day, its cpu_time is distributed linearly across the days it used.',
  `gpu_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the gpu time (gpu_count * wallduration) of the jobs pertaining to this day. If a job took more than one day, its gpu_time is distributed linearly across the days it used.',
  `sum_gpu_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds^2) The sum of the square of the amount of the gpu_time of the jobs pertaining to this day. If a job took more than one day, its gpu_time is distributed linearly across the days it used.',
  `node_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the node time (nodes * wallduration) of the jobs pertaining to this day. If a job took more than one day, its node_time is distributed linearly across the days it used.',
  `sum_node_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of the node_time of the jobs pertaining to this day. If a job took more than one day, its node_time is distributed linearly across the days it used.',
  `sum_weighted_expansion_factor` decimal(18,0) DEFAULT NULL COMMENT 'FACT: This is the sum of expansion factor per job multiplied by node_count and the [adjusted] duration of jobs that ran in this days.',
  `sum_job_weights` decimal(18,0) DEFAULT NULL COMMENT 'FACT: this is the sum of (node_count multipled by the [adjusted] duration) for jobs that ran in this days.',
  `job_id_list` mediumtext NOT NULL COMMENT 'METADATA: the ids in the fact table for the rows that went into this row',
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_account` (`account_id`),
  KEY `index_allocation` (`allocation_id`),
  KEY `index_fos` (`fos_id`),
  KEY `index_job_time_bucket_id` (`job_time_bucket_id`),
  KEY `index_job_wait_time_bucket_id` (`job_wait_time_bucket_id`),
  KEY `index_node_count` (`node_count`),
  KEY `index_resource_organization` (`resource_organization_id`),
  KEY `index_person` (`person_id`),
  KEY `index_person_nsf_status_code` (`person_nsfstatuscode_id`),
  KEY `index_last_modified` (`last_modified`),
  KEY `index_person_organization` (`person_organization_id`),
  KEY `index_pi_organization` (`piperson_organization_id`),
  KEY `index_pi_person` (`principalinvestigator_person_id`),
  KEY `index_processor_count` (`processor_count`),
  KEY `index_queue` (`queue`),
  KEY `index_resource_type` (`resourcetype_id`),
  KEY `index_resource` (`record_resource_id`),
  KEY `index_system_account` (`systemaccount_id`),
  KEY `index_period_value` (`day`),
  KEY `index_period` (`day_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Jobfacts aggregated by ${AGGREGATION_UNIT}.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobfact_by_day_joblist`
--

DROP TABLE IF EXISTS `jobfact_by_day_joblist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobfact_by_day_joblist` (
  `agg_id` int(11) NOT NULL,
  `jobid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`agg_id`,`jobid`) USING BTREE,
  UNIQUE KEY `job_lookup_key` (`jobid`,`agg_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobfact_by_month`
--

DROP TABLE IF EXISTS `jobfact_by_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobfact_by_month` (
  `month_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.months.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the month',
  `month` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The month of the year.',
  `record_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource on which the request was made',
  `task_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource on which the jobs ran',
  `resource_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the resource that the jobs ran on.',
  `resourcetype_id` int(11) NOT NULL COMMENT 'DIMENSION: The type of the resource on which the jobs ran. References resourcetype.id',
  `systemaccount_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the resource system account (local username) under which the job ran. References systemaccount.id',
  `submission_venue_id` int(11) NOT NULL COMMENT 'DIMENSION: The method used to submit this job: cli, gateway, ...',
  `job_record_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Task type or event.',
  `job_task_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Type of job: hpc, cloud, hpc-reservation, ....',
  `queue` char(255) NOT NULL COMMENT 'DIMENSION: The queue of the resource on which the jobs ran.',
  `allocation_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of allocation these jobs used to run',
  `account_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the account record from which one can get charge number',
  `requesting_person_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the person that requested the resources (e.g., made the reservation or submitted the job.',
  `person_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the person that ran the jobs.',
  `person_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the person that ran the jobs.',
  `person_nsfstatuscode_id` int(11) NOT NULL COMMENT 'DIMENSION: The NSF status code of the person that ran the jobs. References person.nsfstatuscode_id',
  `fos_id` int(11) NOT NULL COMMENT 'DIMENSION: The field of science of the project to which the jobs belong.',
  `principalinvestigator_person_id` int(11) NOT NULL COMMENT 'DIMENSION: The PI that owns the allocations that these jobs ran under. References principalinvestigator.person_id',
  `piperson_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the PI that owns the project that funds these jobs. References piperson.organization_id',
  `job_time_bucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Job time is bucketing of wall time based on prechosen intervals in the modw.job_times table.',
  `job_wait_time_bucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Job wait time is bucketing of wait time based on prechosen intervals in the modw.job_wait_times table.',
  `node_count` int(11) NOT NULL COMMENT 'DIMENSION: Number of nodes each of the jobs used.',
  `processor_count` int(11) NOT NULL COMMENT 'DIMENSION: Number of processors each of the jobs used.',
  `processorbucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined processor bucket sizes. References processor_buckets.id',
  `gpu_count` int(11) NOT NULL COMMENT 'FACT: Number of GPUs each of the jobs used.',
  `gpubucket_id` int(11) NOT NULL COMMENT 'DIMENSION: Pre-determined GPU bucket sizes. References gpu_buckets.id',
  `qos_id` int(11) NOT NULL COMMENT 'DIMENSION: Quality of service. References qos.id',
  `submitted_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that started during this day.',
  `ended_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that ended during this day.',
  `started_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that started during this day.',
  `running_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that were running during this day.',
  `wallduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The wallduration of the jobs that were running during this period. This will only count the walltime of the jobs that fell during this day. If a job started in the previous day(s) the wall time for that day will be added to that day. Same logic is true if a job ends not in this day, but upcoming days.',
  `sum_wallduration_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of wallduration of the jobs that were running during this period. This will only count the walltime of the jobs that fell during this day. If a job started in the previous day(s) the wall time for that day will be added to that day. Same logic is true if a job ends not in this day, but upcoming days.',
  `waitduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of time jobs waited to execute during this day.',
  `sum_waitduration_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of time jobs waited to execute during this day.',
  `local_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `local_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `local_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `sum_local_charge_xdsu_squared` double DEFAULT NULL COMMENT 'FACT: The sum of the square of local_charge of jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `cpu_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the cpu time (processor_count * wallduration) of the jobs pertaining to this day. If a job took more than one day, its cpu_time is distributed linearly across the days it used.',
  `sum_cpu_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of the cpu_time of the jobs pertaining to this day. If a job took more than one day, its cpu_time is distributed linearly across the days it used.',
  `gpu_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the gpu time (gpu_count * wallduration) of the jobs pertaining to this day. If a job took more than one day, its gpu_time is distributed linearly across the days it used.',
  `sum_gpu_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds^2) The sum of the square of the amount of the gpu_time of the jobs pertaining to this day. If a job took more than one day, its gpu_time is distributed linearly across the days it used.',
  `node_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the node time (nodes * wallduration) of the jobs pertaining to this day. If a job took more than one day, its node_time is distributed linearly across the days it used.',
  `sum_node_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of the node_time of the jobs pertaining to this day. If a job took more than one day, its node_time is distributed linearly across the days it used.',
  `sum_weighted_expansion_factor` decimal(18,0) DEFAULT NULL COMMENT 'FACT: This is the sum of expansion factor per job multiplied by node_count and the [adjusted] duration of jobs that ran in this days.',
  `sum_job_weights` decimal(18,0) DEFAULT NULL COMMENT 'FACT: this is the sum of (node_count multipled by the [adjusted] duration) for jobs that ran in this days.',
  KEY `index_account` (`account_id`),
  KEY `index_allocation` (`allocation_id`),
  KEY `index_fos` (`fos_id`),
  KEY `index_job_time_bucket_id` (`job_time_bucket_id`),
  KEY `index_job_wait_time_bucket_id` (`job_wait_time_bucket_id`),
  KEY `index_node_count` (`node_count`),
  KEY `index_resource_organization` (`resource_organization_id`),
  KEY `index_person` (`person_id`),
  KEY `index_person_nsf_status_code` (`person_nsfstatuscode_id`),
  KEY `index_person_organization` (`person_organization_id`),
  KEY `index_pi_organization` (`piperson_organization_id`),
  KEY `index_pi_person` (`principalinvestigator_person_id`),
  KEY `index_processor_count` (`processor_count`),
  KEY `index_queue` (`queue`),
  KEY `index_resource_type` (`resourcetype_id`),
  KEY `index_resource` (`record_resource_id`),
  KEY `index_system_account` (`systemaccount_id`),
  KEY `index_period_value` (`month`),
  KEY `index_period` (`month_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Jobfacts aggregated by ${AGGREGATION_UNIT}.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobfact_by_quarter`
--

DROP TABLE IF EXISTS `jobfact_by_quarter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobfact_by_quarter` (
  `quarter_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.quarters.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the quarter',
  `quarter` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The quarter of the year.',
  `record_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource on which the request was made',
  `task_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource on which the jobs ran',
  `resource_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the resource that the jobs ran on.',
  `resourcetype_id` int(11) NOT NULL COMMENT 'DIMENSION: The type of the resource on which the jobs ran. References resourcetype.id',
  `systemaccount_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the resource system account (local username) under which the job ran. References systemaccount.id',
  `submission_venue_id` int(11) NOT NULL COMMENT 'DIMENSION: The method used to submit this job: cli, gateway, ...',
  `job_record_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Task type or event.',
  `job_task_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Type of job: hpc, cloud, hpc-reservation, ....',
  `queue` char(255) NOT NULL COMMENT 'DIMENSION: The queue of the resource on which the jobs ran.',
  `allocation_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of allocation these jobs used to run',
  `account_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the account record from which one can get charge number',
  `requesting_person_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the person that requested the resources (e.g., made the reservation or submitted the job.',
  `person_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the person that ran the jobs.',
  `person_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the person that ran the jobs.',
  `person_nsfstatuscode_id` int(11) NOT NULL COMMENT 'DIMENSION: The NSF status code of the person that ran the jobs. References person.nsfstatuscode_id',
  `fos_id` int(11) NOT NULL COMMENT 'DIMENSION: The field of science of the project to which the jobs belong.',
  `principalinvestigator_person_id` int(11) NOT NULL COMMENT 'DIMENSION: The PI that owns the allocations that these jobs ran under. References principalinvestigator.person_id',
  `piperson_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the PI that owns the project that funds these jobs. References piperson.organization_id',
  `job_time_bucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Job time is bucketing of wall time based on prechosen intervals in the modw.job_times table.',
  `job_wait_time_bucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Job wait time is bucketing of wait time based on prechosen intervals in the modw.job_wait_times table.',
  `node_count` int(11) NOT NULL COMMENT 'DIMENSION: Number of nodes each of the jobs used.',
  `processor_count` int(11) NOT NULL COMMENT 'DIMENSION: Number of processors each of the jobs used.',
  `processorbucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined processor bucket sizes. References processor_buckets.id',
  `gpu_count` int(11) NOT NULL COMMENT 'FACT: Number of GPUs each of the jobs used.',
  `gpubucket_id` int(11) NOT NULL COMMENT 'DIMENSION: Pre-determined GPU bucket sizes. References gpu_buckets.id',
  `qos_id` int(11) NOT NULL COMMENT 'DIMENSION: Quality of service. References qos.id',
  `submitted_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that started during this day.',
  `ended_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that ended during this day.',
  `started_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that started during this day.',
  `running_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that were running during this day.',
  `wallduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The wallduration of the jobs that were running during this period. This will only count the walltime of the jobs that fell during this day. If a job started in the previous day(s) the wall time for that day will be added to that day. Same logic is true if a job ends not in this day, but upcoming days.',
  `sum_wallduration_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of wallduration of the jobs that were running during this period. This will only count the walltime of the jobs that fell during this day. If a job started in the previous day(s) the wall time for that day will be added to that day. Same logic is true if a job ends not in this day, but upcoming days.',
  `waitduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of time jobs waited to execute during this day.',
  `sum_waitduration_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of time jobs waited to execute during this day.',
  `local_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `local_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `local_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `sum_local_charge_xdsu_squared` double DEFAULT NULL COMMENT 'FACT: The sum of the square of local_charge of jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `cpu_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the cpu time (processor_count * wallduration) of the jobs pertaining to this day. If a job took more than one day, its cpu_time is distributed linearly across the days it used.',
  `sum_cpu_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of the cpu_time of the jobs pertaining to this day. If a job took more than one day, its cpu_time is distributed linearly across the days it used.',
  `gpu_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the gpu time (gpu_count * wallduration) of the jobs pertaining to this day. If a job took more than one day, its gpu_time is distributed linearly across the days it used.',
  `sum_gpu_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds^2) The sum of the square of the amount of the gpu_time of the jobs pertaining to this day. If a job took more than one day, its gpu_time is distributed linearly across the days it used.',
  `node_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the node time (nodes * wallduration) of the jobs pertaining to this day. If a job took more than one day, its node_time is distributed linearly across the days it used.',
  `sum_node_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of the node_time of the jobs pertaining to this day. If a job took more than one day, its node_time is distributed linearly across the days it used.',
  `sum_weighted_expansion_factor` decimal(18,0) DEFAULT NULL COMMENT 'FACT: This is the sum of expansion factor per job multiplied by node_count and the [adjusted] duration of jobs that ran in this days.',
  `sum_job_weights` decimal(18,0) DEFAULT NULL COMMENT 'FACT: this is the sum of (node_count multipled by the [adjusted] duration) for jobs that ran in this days.',
  KEY `index_account` (`account_id`),
  KEY `index_allocation` (`allocation_id`),
  KEY `index_fos` (`fos_id`),
  KEY `index_job_time_bucket_id` (`job_time_bucket_id`),
  KEY `index_job_wait_time_bucket_id` (`job_wait_time_bucket_id`),
  KEY `index_node_count` (`node_count`),
  KEY `index_resource_organization` (`resource_organization_id`),
  KEY `index_person` (`person_id`),
  KEY `index_person_nsf_status_code` (`person_nsfstatuscode_id`),
  KEY `index_person_organization` (`person_organization_id`),
  KEY `index_pi_organization` (`piperson_organization_id`),
  KEY `index_pi_person` (`principalinvestigator_person_id`),
  KEY `index_processor_count` (`processor_count`),
  KEY `index_queue` (`queue`),
  KEY `index_resource_type` (`resourcetype_id`),
  KEY `index_resource` (`record_resource_id`),
  KEY `index_system_account` (`systemaccount_id`),
  KEY `index_period_value` (`quarter`),
  KEY `index_period` (`quarter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Jobfacts aggregated by ${AGGREGATION_UNIT}.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobfact_by_year`
--

DROP TABLE IF EXISTS `jobfact_by_year`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobfact_by_year` (
  `year_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.years.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the year.',
  `record_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource on which the request was made',
  `task_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource on which the jobs ran',
  `resource_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the resource that the jobs ran on.',
  `resourcetype_id` int(11) NOT NULL COMMENT 'DIMENSION: The type of the resource on which the jobs ran. References resourcetype.id',
  `systemaccount_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the resource system account (local username) under which the job ran. References systemaccount.id',
  `submission_venue_id` int(11) NOT NULL COMMENT 'DIMENSION: The method used to submit this job: cli, gateway, ...',
  `job_record_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Task type or event.',
  `job_task_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Type of job: hpc, cloud, hpc-reservation, ....',
  `queue` char(255) NOT NULL COMMENT 'DIMENSION: The queue of the resource on which the jobs ran.',
  `allocation_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of allocation these jobs used to run',
  `account_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the account record from which one can get charge number',
  `requesting_person_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the person that requested the resources (e.g., made the reservation or submitted the job.',
  `person_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the person that ran the jobs.',
  `person_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the person that ran the jobs.',
  `person_nsfstatuscode_id` int(11) NOT NULL COMMENT 'DIMENSION: The NSF status code of the person that ran the jobs. References person.nsfstatuscode_id',
  `fos_id` int(11) NOT NULL COMMENT 'DIMENSION: The field of science of the project to which the jobs belong.',
  `principalinvestigator_person_id` int(11) NOT NULL COMMENT 'DIMENSION: The PI that owns the allocations that these jobs ran under. References principalinvestigator.person_id',
  `piperson_organization_id` int(11) NOT NULL COMMENT 'DIMENSION: The organization of the PI that owns the project that funds these jobs. References piperson.organization_id',
  `job_time_bucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Job time is bucketing of wall time based on prechosen intervals in the modw.job_times table.',
  `job_wait_time_bucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Job wait time is bucketing of wait time based on prechosen intervals in the modw.job_wait_times table.',
  `node_count` int(11) NOT NULL COMMENT 'DIMENSION: Number of nodes each of the jobs used.',
  `processor_count` int(11) NOT NULL COMMENT 'DIMENSION: Number of processors each of the jobs used.',
  `processorbucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined processor bucket sizes. References processor_buckets.id',
  `gpu_count` int(11) NOT NULL COMMENT 'FACT: Number of GPUs each of the jobs used.',
  `gpubucket_id` int(11) NOT NULL COMMENT 'DIMENSION: Pre-determined GPU bucket sizes. References gpu_buckets.id',
  `qos_id` int(11) NOT NULL COMMENT 'DIMENSION: Quality of service. References qos.id',
  `submitted_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that started during this day.',
  `ended_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that ended during this day.',
  `started_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that started during this day.',
  `running_job_count` int(11) DEFAULT NULL COMMENT 'FACT: The number of jobs that were running during this day.',
  `wallduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The wallduration of the jobs that were running during this period. This will only count the walltime of the jobs that fell during this day. If a job started in the previous day(s) the wall time for that day will be added to that day. Same logic is true if a job ends not in this day, but upcoming days.',
  `sum_wallduration_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of wallduration of the jobs that were running during this period. This will only count the walltime of the jobs that fell during this day. If a job started in the previous day(s) the wall time for that day will be added to that day. Same logic is true if a job ends not in this day, but upcoming days.',
  `waitduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of time jobs waited to execute during this day.',
  `sum_waitduration_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of time jobs waited to execute during this day.',
  `local_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `local_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `local_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `adjusted_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_local_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_su` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of local SUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_xdsu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of XDSUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `task_adjusted_charge_nu` decimal(18,0) DEFAULT NULL COMMENT 'FACT: The amount of NUs charged to jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `sum_local_charge_xdsu_squared` double DEFAULT NULL COMMENT 'FACT: The sum of the square of local_charge of jobs pertaining to this day. If a job took more than one day, its local_charge is distributed linearly across the days it used.',
  `cpu_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the cpu time (processor_count * wallduration) of the jobs pertaining to this day. If a job took more than one day, its cpu_time is distributed linearly across the days it used.',
  `sum_cpu_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of the cpu_time of the jobs pertaining to this day. If a job took more than one day, its cpu_time is distributed linearly across the days it used.',
  `gpu_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the gpu time (gpu_count * wallduration) of the jobs pertaining to this day. If a job took more than one day, its gpu_time is distributed linearly across the days it used.',
  `sum_gpu_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds^2) The sum of the square of the amount of the gpu_time of the jobs pertaining to this day. If a job took more than one day, its gpu_time is distributed linearly across the days it used.',
  `node_time` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The amount of the node time (nodes * wallduration) of the jobs pertaining to this day. If a job took more than one day, its node_time is distributed linearly across the days it used.',
  `sum_node_time_squared` double DEFAULT NULL COMMENT 'FACT: (seconds) The sum of the square of the amount of the node_time of the jobs pertaining to this day. If a job took more than one day, its node_time is distributed linearly across the days it used.',
  `sum_weighted_expansion_factor` decimal(18,0) DEFAULT NULL COMMENT 'FACT: This is the sum of expansion factor per job multiplied by node_count and the [adjusted] duration of jobs that ran in this days.',
  `sum_job_weights` decimal(18,0) DEFAULT NULL COMMENT 'FACT: this is the sum of (node_count multipled by the [adjusted] duration) for jobs that ran in this days.',
  KEY `index_account` (`account_id`),
  KEY `index_allocation` (`allocation_id`),
  KEY `index_fos` (`fos_id`),
  KEY `index_job_time_bucket_id` (`job_time_bucket_id`),
  KEY `index_job_wait_time_bucket_id` (`job_wait_time_bucket_id`),
  KEY `index_node_count` (`node_count`),
  KEY `index_resource_organization` (`resource_organization_id`),
  KEY `index_person` (`person_id`),
  KEY `index_person_nsf_status_code` (`person_nsfstatuscode_id`),
  KEY `index_person_organization` (`person_organization_id`),
  KEY `index_pi_organization` (`piperson_organization_id`),
  KEY `index_pi_person` (`principalinvestigator_person_id`),
  KEY `index_processor_count` (`processor_count`),
  KEY `index_queue` (`queue`),
  KEY `index_resource_type` (`resourcetype_id`),
  KEY `index_resource` (`record_resource_id`),
  KEY `index_system_account` (`systemaccount_id`),
  KEY `index_period_value` (`year`),
  KEY `index_period` (`year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Jobfacts aggregated by ${AGGREGATION_UNIT}.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resourcespecsfact_by_day`
--

DROP TABLE IF EXISTS `resourcespecsfact_by_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resourcespecsfact_by_day` (
  `day_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.days.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the day',
  `day` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The day of the year.',
  `resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource id of the host of a VM where sessions ran.',
  `core_time_available` bigint(42) NOT NULL COMMENT 'DIMENSION: Amount of core time in seconds available for a time period',
  KEY `index_resource` (`resource_id`),
  KEY `index_period_value` (`day`),
  KEY `index_period` (`day_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Record type: accounting, administrative, derived, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resourcespecsfact_by_month`
--

DROP TABLE IF EXISTS `resourcespecsfact_by_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resourcespecsfact_by_month` (
  `month_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.months.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the month',
  `month` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The month of the year.',
  `resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource id of the host of a VM where sessions ran.',
  `core_time_available` bigint(42) NOT NULL COMMENT 'DIMENSION: Amount of core time in seconds available for a time period',
  KEY `index_resource` (`resource_id`),
  KEY `index_period_value` (`month`),
  KEY `index_period` (`month_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Record type: accounting, administrative, derived, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resourcespecsfact_by_quarter`
--

DROP TABLE IF EXISTS `resourcespecsfact_by_quarter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resourcespecsfact_by_quarter` (
  `quarter_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.quarters.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the quarter',
  `quarter` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The quarter of the year.',
  `resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource id of the host of a VM where sessions ran.',
  `core_time_available` bigint(42) NOT NULL COMMENT 'DIMENSION: Amount of core time in seconds available for a time period',
  KEY `index_resource` (`resource_id`),
  KEY `index_period_value` (`quarter`),
  KEY `index_period` (`quarter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Record type: accounting, administrative, derived, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resourcespecsfact_by_year`
--

DROP TABLE IF EXISTS `resourcespecsfact_by_year`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resourcespecsfact_by_year` (
  `year_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.years.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the year.',
  `resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource id of the host of a VM where sessions ran.',
  `core_time_available` bigint(42) NOT NULL COMMENT 'DIMENSION: Amount of core time in seconds available for a time period',
  KEY `index_resource` (`resource_id`),
  KEY `index_period_value` (`year`),
  KEY `index_period` (`year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Record type: accounting, administrative, derived, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-09-14 21:37:56
