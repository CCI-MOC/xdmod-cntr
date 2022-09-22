-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: mariadb    Database: modw
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
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The id of the account record.',
  `account_origin_id` int(11) NOT NULL DEFAULT -1,
  `parent_id` int(11) DEFAULT NULL COMMENT 'The id of the parent account record, if any.',
  `charge_number` varchar(200) NOT NULL COMMENT 'The charge number associated with the allocation.',
  `creator_organization_id` int(11) DEFAULT NULL COMMENT 'The id of the organization who created this account.',
  `granttype_id` int(11) NOT NULL,
  `long_name` varchar(500) DEFAULT NULL,
  `short_name` varchar(500) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `federation_instance_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uniq` (`account_origin_id`,`federation_instance_id`) USING BTREE,
  KEY `index_charge` (`charge_number`,`id`) USING BTREE,
  KEY `fk_account_account1_idx` (`parent_id`) USING BTREE,
  KEY `fk_account_granttype1_idx` (`granttype_id`) USING BTREE,
  KEY `fk_account_organization1_idx` (`creator_organization_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table has records for all the accounts/projects.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `allocation`
--

DROP TABLE IF EXISTS `allocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allocation` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The id of the allocation record.',
  `allocation_origin_id` int(10) unsigned NOT NULL,
  `resource_id` int(11) NOT NULL COMMENT 'This is the resource that the allocation sus where assigned in relativity to. It doesnt mean that the allocation can be used to run on this resource. To use this allocation, there must be resources assigned to this allocation in the allocationonresource t',
  `account_id` int(11) NOT NULL COMMENT 'This is the id of the accoun that owns this allocation, usually belongs to the PI of the project.',
  `request_id` int(11) NOT NULL COMMENT 'The id of the request that resulted in this allocation.',
  `principalinvestigator_person_id` int(11) NOT NULL COMMENT 'The person id of the pi who owns this allocation.',
  `fos_id` int(11) NOT NULL,
  `boardtype_id` int(11) NOT NULL,
  `initial_allocation` decimal(15,2) NOT NULL COMMENT 'The initial amount of the allocation in SUs.',
  `initial_start_date` date NOT NULL COMMENT 'The initial start date of the allocation.',
  `initial_start_date_ts` int(14) NOT NULL,
  `initial_end_date` date NOT NULL COMMENT 'The initial assumed end of the allocation.',
  `base_allocation` decimal(15,2) NOT NULL COMMENT 'The current amount of the allocation, which is the initial modified by any amounts since it was initiated. Allocations can be modified by transfers or not, supplements awarded.',
  `remaining_allocation` decimal(18,4) NOT NULL COMMENT 'This is the remaning amount of the allocation. Negative values mean they’ve consumed more SUs than they’ve been allocated. This may happen for a number of reasons, the most common being the project submits final job(s) when they are still “in the black” b',
  `end_date` date NOT NULL COMMENT 'This is the actual date the allocation was actually ended. ',
  `end_date_ts` int(14) NOT NULL,
  `allocation_type_id` int(11) DEFAULT NULL COMMENT 'The type of the allocation (extension, supplement, transfer, new, renewal, advance, adjustment)',
  `charge_number` varchar(200) DEFAULT NULL,
  `conversion_factor` decimal(10,4) NOT NULL DEFAULT 1.0000,
  `xd_su_per_hour` decimal(15,2) NOT NULL DEFAULT 0.00,
  `long_name` varchar(500) DEFAULT NULL,
  `short_name` varchar(500) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uniq` (`resource_id`,`allocation_origin_id`) USING BTREE,
  KEY `allocation_charge_number` (`charge_number`) USING BTREE,
  KEY `aggregation_index` (`account_id`,`id`,`initial_start_date_ts`,`end_date_ts`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Holds allocation records.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `allocationbreakdown`
--

DROP TABLE IF EXISTS `allocationbreakdown`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allocationbreakdown` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The id of the record.',
  `allocation_breakdown_origin_id` int(10) NOT NULL,
  `person_id` int(11) NOT NULL COMMENT 'The id of the person who gets a part of the allocation.',
  `allocation_id` int(11) NOT NULL COMMENT 'The id of the allocation the person can use.',
  `percentage` decimal(5,2) DEFAULT NULL COMMENT 'The percentage [0-100] of the allocation that the person can use. ',
  `alloc_limit` decimal(18,4) DEFAULT NULL COMMENT 'Usually set to the base_allocation of the allocation.',
  `used_allocation` decimal(18,4) DEFAULT NULL COMMENT 'How much the user has used in Sus.',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `alloc_pid` (`allocation_id`,`person_id`) USING BTREE,
  KEY `fk_allocationbreakdown_allocation1_idx` (`allocation_id`) USING BTREE,
  KEY `fk_allocationbreakdown_person1_idx` (`person_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Assigns people to a part of an allocation.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `allocationonresource`
--

DROP TABLE IF EXISTS `allocationonresource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allocationonresource` (
  `allocation_id` int(11) NOT NULL COMMENT 'The id of the allocation record.',
  `resource_id` int(11) NOT NULL COMMENT 'The id of the resource that is allowed to use the allocation. In other words the allocation listed can be used by running jobs on this resource, depending on the allocation_state_id.',
  `allocation_state_id` int(11) NOT NULL COMMENT 'The state of the allocation.',
  PRIMARY KEY (`resource_id`,`allocation_id`) USING BTREE,
  KEY `fk_allocation_on_resource_allocation1_idx` (`allocation_id`) USING BTREE,
  KEY `fk_allocation_on_resource_allocation_state1_idx` (`allocation_state_id`) USING BTREE,
  KEY `fk_allocation_on_resource_resourcefact1_idx` (`resource_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='state of alloc wrt resources.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `countable_type`
--

DROP TABLE IF EXISTS `countable_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `countable_type` (
  `countable_type_id` int(11) NOT NULL,
  `unit_id` int(11) DEFAULT NULL COMMENT 'Optional unit for this countable',
  `countable_type` varchar(64) NOT NULL COMMENT 'Short version or abbrev',
  `display` varchar(256) NOT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`countable_type_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Types of things that are countable. Accelerators, databases, storage, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `days`
--

DROP TABLE IF EXISTS `days`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `days` (
  `id` int(10) unsigned NOT NULL COMMENT 'The id of the day record.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'The year.',
  `day` smallint(5) unsigned NOT NULL COMMENT 'The day of year starting at 1.',
  `day_start` datetime NOT NULL COMMENT 'The datetime of the start of this day down to the second.',
  `day_end` datetime NOT NULL COMMENT 'the end datetime of this day down to the second.',
  `hours` tinyint(3) unsigned NOT NULL COMMENT 'The number of hours in this day. Could be less than 24 in case the last job record fell in the middle of this day.',
  `seconds` mediumint(8) unsigned NOT NULL COMMENT 'number of seconds n the day',
  `day_start_ts` int(10) unsigned NOT NULL COMMENT 'The start in epochs.',
  `day_end_ts` int(10) unsigned NOT NULL COMMENT 'The end in epochs.',
  `day_middle_ts` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `days_pk2` (`day_start`,`day_end`,`day`,`year`) USING BTREE,
  UNIQUE KEY `days_yd` (`year`,`day`) USING BTREE,
  KEY `days_index` (`id`,`seconds`,`day_start_ts`,`day_end_ts`) USING BTREE,
  KEY `days_index2` (`id`,`day_start_ts`,`day_middle_ts`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='autogen - one rec for each day of TG.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `error_descriptions`
--

DROP TABLE IF EXISTS `error_descriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `error_descriptions` (
  `id` int(11) NOT NULL,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `federation_instances`
--

DROP TABLE IF EXISTS `federation_instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `federation_instances` (
  `federation_instance_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `prefix` varchar(191) DEFAULT NULL COMMENT 'generally fqdn with . replaced by - 191 limit due to utf8mb4',
  `timezone` varchar(191) DEFAULT NULL COMMENT 'Timezone of the instance - 191 limit due to utf8mb4',
  `extra` text DEFAULT NULL COMMENT 'any extra information to be stored about the instance, ie. contact information',
  PRIMARY KEY (`federation_instance_id`) USING BTREE,
  UNIQUE KEY `prefix` (`prefix`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fieldofscience`
--

DROP TABLE IF EXISTS `fieldofscience`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fieldofscience` (
  `id` int(11) NOT NULL COMMENT 'The id of the record.',
  `parent_id` int(11) DEFAULT NULL COMMENT 'The parent of this field of science, if NULL this is an NSF Directorate.',
  `description` varchar(200) DEFAULT NULL COMMENT 'The description of this field of science.',
  `fos_nsf_id` int(11) DEFAULT NULL COMMENT 'The nsf id for this field of science.',
  `fos_nsf_abbrev` varchar(100) DEFAULT NULL COMMENT 'The nsf abbreviation.',
  `directorate_fos_id` int(11) DEFAULT NULL COMMENT 'The id of the NSF directorate of this field of science.',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `fk_science_science1_idx` (`parent_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='The various fields of science.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fieldofscience_hierarchy`
--

DROP TABLE IF EXISTS `fieldofscience_hierarchy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fieldofscience_hierarchy` (
  `id` int(11) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `description2` varchar(200) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_description` varchar(200) DEFAULT NULL,
  `directorate_id` int(11) DEFAULT NULL,
  `directorate_description` varchar(200) DEFAULT NULL,
  `directorate_abbrev` varchar(100) DEFAULT NULL,
  `division_id` int(11) DEFAULT NULL,
  `division_description` varchar(200) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `fos_h_directorate_id` (`directorate_id`) USING BTREE,
  KEY `fos_h_parent_id` (`parent_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gpu_buckets`
--

DROP TABLE IF EXISTS `gpu_buckets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gpu_buckets` (
  `id` int(11) NOT NULL,
  `min_gpus` int(11) NOT NULL,
  `max_gpus` int(11) NOT NULL,
  `description` char(16) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_min_max` (`min_gpus`,`max_gpus`),
  UNIQUE KEY `uk_description` (`description`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hosts`
--

DROP TABLE IF EXISTS `hosts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hosts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_origin_id` int(11) DEFAULT NULL,
  `resource_id` int(11) NOT NULL,
  `hostname` varchar(255) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `resource_id` (`resource_id`,`hostname`) USING BTREE,
  KEY `host_origin_id_idx` (`host_origin_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_record_type`
--

DROP TABLE IF EXISTS `job_record_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_record_type` (
  `job_record_type_id` int(11) NOT NULL,
  `job_record_type` varchar(64) NOT NULL COMMENT 'Short version or abbrev',
  `display` varchar(256) NOT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`job_record_type_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='hpc, cloud, reservation, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_records`
--

DROP TABLE IF EXISTS `job_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_records` (
  `job_record_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `job_record_origin_id` bigint(20) unsigned NOT NULL,
  `resource_id` int(11) NOT NULL COMMENT 'Resource where the job was initiated',
  `resourcetype_id` int(11) NOT NULL COMMENT 'The type of the resource on which the jobs ran. References the resourcetype.id',
  `resource_state_id` int(11) NOT NULL COMMENT 'The state where the resource resides',
  `resource_country_id` int(11) NOT NULL COMMENT 'The country where the resource resides',
  `resource_organization_id` int(11) NOT NULL COMMENT 'The organization where the resource resides',
  `resource_organization_type_id` int(11) NOT NULL COMMENT 'The type of organization where the resource resides',
  `allocation_resource_id` int(11) NOT NULL COMMENT 'Resource associated with the allocation. May be a grid resource.',
  `person_id` int(11) NOT NULL COMMENT 'Person requesting resources',
  `person_organization_id` int(11) NOT NULL COMMENT 'The organization of the person requesting resources',
  `person_nsfstatuscode_id` int(11) NOT NULL COMMENT 'The NSF status code of the person requesting resources. References person.nsfstatuscode_id',
  `account_id` int(11) NOT NULL COMMENT 'Account the job will be charged to',
  `allocation_id` int(11) NOT NULL COMMENT 'Allocation (resource, account) that will be charged for this job',
  `request_id` int(11) NOT NULL COMMENT 'Request record for this allocation (used for primary field of science)',
  `fos_id` int(11) NOT NULL COMMENT 'The field of science of the project to which the jobs belong',
  `principalinvestigator_person_id` int(11) NOT NULL COMMENT 'The PI that owns the allocation. XDMoD adds this on ingest, otherwise it is linked to a request in XDCDB. References principalinvestigator.person_id',
  `piperson_organization_id` int(11) NOT NULL COMMENT 'The organization of the PI that owns the allocation. References piperson.organization_id',
  `job_record_type_id` int(11) NOT NULL COMMENT 'Type of job: hpc, cloud, hpc-reservation, ...',
  `submission_venue_id` int(11) NOT NULL COMMENT 'Method used to submit this job: cli, gateway, ...',
  `qos_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Job quality of service',
  `queue` varchar(255) DEFAULT NULL COMMENT 'Resource queue where the job ran',
  `submit_time_ts` int(11) DEFAULT NULL COMMENT 'Job submission time in seconds since epoch (UTC)',
  `start_time_ts` int(11) NOT NULL COMMENT 'Job start time in seconds since epoch (UTC)',
  `end_time_ts` int(11) DEFAULT NULL COMMENT 'Job completion time in seconds since epoch (UTC), may be unknown',
  `start_day_id` int(10) unsigned NOT NULL COMMENT 'Day id of the job start time in format YYYY00DDD, e.g. 201600143. This is the day in the timezone of the LOCAL database and NOT UTC!',
  `end_day_id` int(10) unsigned NOT NULL COMMENT 'Day id of the job end time in format YYYY00DDD, e.g. 201600143. This is the day in the timezone of the LOCAL database and NOT UTC!',
  `local_charge_su` decimal(18,3) NOT NULL DEFAULT 0.000 COMMENT 'Local resource SUs charged',
  `adjusted_charge_su` decimal(18,3) NOT NULL DEFAULT 0.000 COMMENT 'Local resource SUs charged after SP adjustments',
  `local_charge_xdsu` decimal(18,3) DEFAULT NULL COMMENT 'XDSUs charged. Uses current resource conv factor',
  `adjusted_charge_xdsu` decimal(18,3) DEFAULT NULL COMMENT 'XDSUs charged after SP adjustments',
  `local_charge_nu` decimal(18,3) DEFAULT NULL COMMENT 'NUs charged. XDSU * 21.576',
  `adjusted_charge_nu` decimal(18,3) DEFAULT NULL COMMENT 'NUs charged after SP adjustments. XDSU * 21.576',
  `conversion_factor` double DEFAULT NULL COMMENT 'Factor used to normalize local SU to TG Roaming (XDSU)',
  `completed` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Boolean flag 1 = job complete',
  `federation_instance_id` int(11) NOT NULL DEFAULT 0,
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Boolean flag 1 = job has been deleted',
  PRIMARY KEY (`job_record_id`,`job_record_origin_id`,`federation_instance_id`) USING BTREE,
  UNIQUE KEY `uniq` (`job_record_origin_id`,`federation_instance_id`) USING BTREE,
  KEY `completed` (`completed`) USING BTREE,
  KEY `fk_account` (`account_id`) USING BTREE,
  KEY `fk_allocation` (`allocation_id`) USING BTREE,
  KEY `fk_request` (`request_id`) USING BTREE,
  KEY `fk_job_record_type` (`job_record_type_id`) USING BTREE,
  KEY `fk_person` (`person_id`) USING BTREE,
  KEY `fk_resource` (`resource_id`) USING BTREE,
  KEY `fk_submission_venue` (`submission_venue_id`) USING BTREE,
  KEY `deleted` (`is_deleted`) USING BTREE,
  KEY `aggregation_index` (`start_day_id`,`end_day_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Request for resources by a user';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_request_info`
--

DROP TABLE IF EXISTS `job_request_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_request_info` (
  `job_record_id` bigint(20) unsigned NOT NULL,
  `requested_nodes` int(11) DEFAULT NULL,
  `requested_cores` int(11) DEFAULT NULL,
  `requested_seconds` int(11) DEFAULT NULL,
  PRIMARY KEY (`job_record_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Requested job resources, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_task_countable`
--

DROP TABLE IF EXISTS `job_task_countable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_task_countable` (
  `job_record_id` bigint(20) unsigned NOT NULL,
  `creation_time` datetime NOT NULL,
  `countable_type_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Item that we are counting',
  `value` decimal(18,3) NOT NULL DEFAULT 0.000 COMMENT 'Countable value',
  PRIMARY KEY (`job_record_id`,`creation_time`) USING BTREE,
  KEY `fk_countable` (`countable_type_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Countable values. e.g., Num databases, num gpus allocated, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_task_type`
--

DROP TABLE IF EXISTS `job_task_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_task_type` (
  `job_task_type_id` int(11) NOT NULL,
  `job_record_type_id` int(11) DEFAULT NULL COMMENT 'Reference to record type for type-specific task events',
  `job_task_type` varchar(64) NOT NULL COMMENT 'Short version or abbrev',
  `display` varchar(256) NOT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`job_task_type_id`) USING BTREE,
  KEY `fk_job_record_type` (`job_record_type_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='hpc, provisioning, boot, suspend, resume, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_tasks`
--

DROP TABLE IF EXISTS `job_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_tasks` (
  `job_record_id` bigint(20) unsigned NOT NULL COMMENT 'Job record this task falls under',
  `job_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique job_id',
  `job_id_origin_id` bigint(20) unsigned NOT NULL COMMENT 'Job_id from Origin',
  `creation_time` datetime NOT NULL COMMENT 'Time that the data was originally recorded at the source',
  `local_jobid` int(11) NOT NULL COMMENT 'Job or vm instance identifier from resource manager',
  `local_job_array_index` int(11) NOT NULL DEFAULT -1 COMMENT 'Job Array index id',
  `local_job_id_raw` int(11) DEFAULT NULL COMMENT 'Resource where the task executed',
  `resource_id` int(11) NOT NULL COMMENT 'Resource where the task executed',
  `systemaccount_id` int(11) NOT NULL COMMENT 'DIMENSION: The id of the resource system account (local username) under which the job ran. References systemaccount.id',
  `person_id` int(11) NOT NULL COMMENT 'Person executing this task',
  `person_organization_id` int(11) NOT NULL COMMENT 'The organization of the person who ran the task',
  `person_nsfstatuscode_id` int(11) NOT NULL COMMENT 'The NSF status code of the person who ran the task',
  `job_task_type_id` int(11) NOT NULL COMMENT 'Task type or event',
  `name` varchar(256) DEFAULT NULL COMMENT 'User-specified job name',
  `submit_time_ts` int(11) NOT NULL COMMENT 'Task submission time in seconds since epoch (UTC)',
  `start_time_ts` int(11) NOT NULL COMMENT 'Task start time in seconds since epoch (UTC)',
  `end_time_ts` int(11) NOT NULL COMMENT 'Task completion time in seconds since epoch (UTC)',
  `eligible_time_ts` int(11) DEFAULT NULL COMMENT 'The eligible time in Unix time.',
  `start_day_id` int(10) unsigned NOT NULL COMMENT 'Day id of the job start time in format YYYY00DDD, e.g. 201600143. This is the day in the timezone of the LOCAL database and NOT UTC!',
  `end_day_id` int(10) unsigned NOT NULL COMMENT 'Day id of the job end time in format YYYY00DDD, e.g. 201600143. This is the day in the timezone of the LOCAL database and NOT UTC!',
  `eligible_day_id` int(10) unsigned NOT NULL COMMENT 'Day id of the job eligible time in format YYYY00DDD, e.g. 201600143. This is the day in the timezone of the LOCAL database and NOT UTC!',
  `node_count` int(11) NOT NULL DEFAULT -1 COMMENT 'Number of nodes consumed',
  `processor_count` int(11) NOT NULL DEFAULT -1 COMMENT 'Number of processor cores consumed',
  `gpu_count` int(11) NOT NULL DEFAULT 0 COMMENT 'Number of GPUs consumed',
  `memory_kb` int(11) NOT NULL DEFAULT -1 COMMENT 'Memory consumed',
  `wallduration` int(11) NOT NULL COMMENT 'Overall job duration in seconds',
  `waitduration` int(11) NOT NULL COMMENT 'Time the job waited in the queue',
  `cpu_time` decimal(18,0) NOT NULL COMMENT 'The amount of the cpu time (processor_count * wallduration)',
  `gpu_time` decimal(18,0) NOT NULL COMMENT 'The amount of the GPU time (gpu_count * wallduration)',
  `local_charge_su` decimal(18,3) NOT NULL DEFAULT 0.000 COMMENT 'Local resource SUs charged',
  `adjusted_charge_su` decimal(18,3) NOT NULL DEFAULT 0.000 COMMENT 'Local resource SUs charged after SP adjustments',
  `local_charge_xdsu` decimal(18,3) DEFAULT NULL COMMENT 'XDSUs charged. Uses current resource conv factor',
  `adjusted_charge_xdsu` decimal(18,3) DEFAULT NULL COMMENT 'XDSUs charged after SP adjustments',
  `local_charge_nu` decimal(18,3) DEFAULT NULL COMMENT 'NUs charged. XDSU * 21.576',
  `adjusted_charge_nu` decimal(18,3) DEFAULT NULL COMMENT 'NUs charged after SP adjustments. XDSU & 21.576',
  `group_name` varchar(255) DEFAULT NULL COMMENT 'The name of the group that ran the job.',
  `gid_number` int(10) unsigned DEFAULT NULL COMMENT 'The GID of the group that ran the job.',
  `uid_number` int(10) unsigned DEFAULT NULL COMMENT 'The UID of the user that ran the job.',
  `exit_code` varchar(32) DEFAULT NULL COMMENT 'The code that the job exited with.',
  `exit_state` varchar(32) DEFAULT NULL COMMENT 'The state of the job when it completed.',
  `cpu_req` int(10) unsigned DEFAULT NULL COMMENT 'The number of CPUs required by the job.',
  `mem_req` varchar(32) DEFAULT NULL COMMENT 'The amount of memory required by the job.',
  `timelimit` int(10) unsigned DEFAULT NULL COMMENT 'The time limit of the job in seconds.',
  `conversion_factor` double DEFAULT NULL COMMENT 'Factor used to normalize local SU to TG Roaming (XDSU)',
  `completed` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Boolean flag 1 = job complete',
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Boolean flag 1 = job has been deleted',
  PRIMARY KEY (`job_id`,`creation_time`) USING BTREE,
  UNIQUE KEY `uniq` (`local_job_id_raw`,`job_id_origin_id`,`job_record_id`) USING BTREE,
  KEY `jobid` (`job_id`) USING BTREE,
  KEY `localjobid` (`local_jobid`,`local_job_array_index`,`resource_id`) USING BTREE,
  KEY `completed` (`completed`) USING BTREE,
  KEY `fk_job_task_type` (`job_task_type_id`) USING BTREE,
  KEY `fk_person` (`person_id`) USING BTREE,
  KEY `fk_resource` (`resource_id`) USING BTREE,
  KEY `index_supremm_lookup` (`local_job_id_raw`,`resource_id`) USING BTREE,
  KEY `index_start_time_resource_id` (`start_time_ts`,`resource_id`) USING BTREE,
  KEY `aggregation_index` (`start_day_id`,`end_day_id`) USING BTREE,
  KEY `deleted` (`is_deleted`,`end_day_id`,`start_day_id`) USING BTREE,
  KEY `job_id_origin_id_idx` (`job_id_origin_id`) USING BTREE,
  KEY `index_last_modified` (`last_modified`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Consumption of resources';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_times`
--

DROP TABLE IF EXISTS `job_times`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_times` (
  `id` int(4) NOT NULL,
  `min_duration` int(11) DEFAULT NULL,
  `max_duration` int(11) DEFAULT NULL,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `times` (`min_duration`,`max_duration`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_wait_times`
--

DROP TABLE IF EXISTS `job_wait_times`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_wait_times` (
  `id` int(4) NOT NULL,
  `min_duration` int(11) DEFAULT NULL,
  `max_duration` int(11) DEFAULT NULL,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `times` (`min_duration`,`max_duration`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobhosts`
--

DROP TABLE IF EXISTS `jobhosts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobhosts` (
  `job_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  PRIMARY KEY (`job_id`,`host_id`) USING BTREE,
  KEY `job_id_idx` (`job_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_job`
--

DROP TABLE IF EXISTS `meta_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_job` (
  `meta_job_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `meta_job_name` varchar(128) NOT NULL,
  `person_id` int(11) unsigned NOT NULL COMMENT 'Meta job owner',
  PRIMARY KEY (`meta_job_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Grouping of individual job records';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_job_record`
--

DROP TABLE IF EXISTS `meta_job_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_job_record` (
  `meta_job_id` int(11) unsigned NOT NULL,
  `job_record_id` bigint(20) unsigned NOT NULL,
  KEY `fk_job_record` (`job_record_id`) USING BTREE,
  KEY `fk_meta_job` (`meta_job_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Grouping of jobs that are related, such as a cluster in a cloud';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `months`
--

DROP TABLE IF EXISTS `months`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `months` (
  `id` int(10) unsigned NOT NULL COMMENT 'The id of the month record.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'The year of the month.',
  `month` tinyint(3) unsigned NOT NULL COMMENT 'The month of the year. Starts at 1.',
  `month_start` datetime NOT NULL COMMENT 'The datetime start of the month down to the second.',
  `month_end` datetime NOT NULL COMMENT 'The month end datetime down to the second.',
  `hours` smallint(5) unsigned NOT NULL COMMENT 'The number of hours in this month. This is variable based on duration of the month. Also in case the last job record fell in the middle of this month it will be somewhere between 1 and 31.',
  `seconds` int(10) unsigned NOT NULL COMMENT 'The number of seconds in this month. The last month might be partial.',
  `month_start_ts` int(10) unsigned NOT NULL COMMENT 'The start timestamp of this month in epochs.',
  `month_end_ts` int(10) unsigned NOT NULL COMMENT 'The end of this month in epochs. May be less than expected if the end of the last job fell during this month. ',
  `month_middle_ts` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `months_pk2` (`year`,`month`,`month_start`,`month_end`) USING BTREE,
  UNIQUE KEY `month_ym` (`year`,`month`) USING BTREE,
  KEY `month_index` (`id`,`seconds`,`month_start_ts`,`month_end_ts`) USING BTREE,
  KEY `month_index2` (`id`,`month_start_ts`,`month_middle_ts`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='autogen - one rec for each month of TG operation.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mountpoint`
--

DROP TABLE IF EXISTS `mountpoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mountpoint` (
  `mountpoint_id` int(11) NOT NULL AUTO_INCREMENT,
  `path` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`mountpoint_id`),
  UNIQUE KEY `uk_path` (`path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Storage file system mountpoints';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nodecount`
--

DROP TABLE IF EXISTS `nodecount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nodecount` (
  `id` int(11) NOT NULL,
  `nodes` varchar(100) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `nodes_unique` (`nodes`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organization`
--

DROP TABLE IF EXISTS `organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organization` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The id of the record.',
  `organizationtype_id` int(11) DEFAULT NULL COMMENT 'The type of the organization.',
  `abbrev` varchar(100) DEFAULT NULL COMMENT 'Abbreviated name.',
  `name` varchar(300) DEFAULT NULL COMMENT 'Long name for this organization.',
  `url` varchar(500) DEFAULT NULL COMMENT 'The internet URL.',
  `phone` varchar(30) DEFAULT NULL COMMENT 'Phone number.',
  `nsf_org_code` varchar(45) DEFAULT NULL COMMENT 'NSF code for this organization.',
  `is_reconciled` tinyint(1) DEFAULT 0 COMMENT 'Whether this record is reconciled.',
  `amie_name` varchar(6) DEFAULT NULL COMMENT 'The amie name.',
  `country_id` int(11) DEFAULT NULL COMMENT 'The country this organization is in.',
  `state_id` int(11) DEFAULT NULL COMMENT 'The state this organization is in.',
  `latitude` decimal(13,10) DEFAULT NULL COMMENT 'The latitude of the organization.',
  `longitude` decimal(13,10) DEFAULT NULL COMMENT 'The longitude of the organization.',
  `short_name` varchar(300) DEFAULT NULL,
  `long_name` varchar(300) DEFAULT NULL,
  `federation_instance_id` int(11) unsigned NOT NULL DEFAULT 0,
  `organization_origin_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `amie_name_unique` (`amie_name`) USING BTREE,
  UNIQUE KEY `name_unique` (`name`) USING BTREE,
  UNIQUE KEY `nsf_org_code_unique` (`nsf_org_code`) USING BTREE,
  UNIQUE KEY `uniq` (`organization_origin_id`,`federation_instance_id`) USING BTREE,
  KEY `fk_organization_country1_idx` (`country_id`) USING BTREE,
  KEY `fk_organization_organizationtype1_idx` (`organizationtype_id`) USING BTREE,
  KEY `fk_organization_state1_idx` (`state_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COMMENT='The various organization.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `peopleunderpi`
--

DROP TABLE IF EXISTS `peopleunderpi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `peopleunderpi` (
  `principalinvestigator_person_id` int(11) NOT NULL,
  `person_id` varchar(45) NOT NULL,
  PRIMARY KEY (`principalinvestigator_person_id`,`person_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) NOT NULL,
  `nsfstatuscode_id` int(11) NOT NULL,
  `prefix` varchar(10) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `middle_name` varchar(60) DEFAULT NULL,
  `last_name` varchar(100) NOT NULL,
  `url` varchar(500) DEFAULT NULL,
  `birth_month` int(11) DEFAULT NULL,
  `birth_day` int(11) DEFAULT NULL,
  `department` varchar(300) DEFAULT NULL,
  `title` varchar(300) DEFAULT NULL,
  `is_reconciled` tinyint(1) DEFAULT 0,
  `citizenship_country_id` int(11) DEFAULT NULL,
  `email_address` varchar(200) DEFAULT NULL,
  `ts` datetime DEFAULT NULL,
  `ts_ts` int(11) DEFAULT NULL,
  `status` varchar(10) DEFAULT NULL COMMENT 'links to allocationstate',
  `long_name` varchar(700) DEFAULT NULL,
  `short_name` varchar(101) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `person_origin_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `organization_id` (`organization_id`,`person_origin_id`) USING BTREE,
  KEY `aggregation_index` (`status`,`id`,`ts_ts`) USING BTREE,
  KEY `person_last_name` (`last_name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=208 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `piperson`
--

DROP TABLE IF EXISTS `piperson`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `piperson` (
  `person_id` int(11) NOT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `long_name` varchar(400) DEFAULT NULL,
  `short_name` varchar(100) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`person_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `principalinvestigator`
--

DROP TABLE IF EXISTS `principalinvestigator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `principalinvestigator` (
  `person_id` int(11) NOT NULL COMMENT 'The id of the person of the PI.',
  `request_id` int(11) NOT NULL COMMENT 'The request id.',
  PRIMARY KEY (`person_id`,`request_id`) USING BTREE,
  KEY `fk_princialinvestigator_person1_idx` (`person_id`) USING BTREE,
  KEY `fk_princialinvestigator_request1_idx` (`request_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Only PIs are allowed to make requests.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `processor_buckets`
--

DROP TABLE IF EXISTS `processor_buckets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `processor_buckets` (
  `id` int(4) NOT NULL,
  `min_processors` int(11) DEFAULT NULL,
  `max_processors` int(11) DEFAULT NULL,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `proc` (`min_processors`,`max_processors`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qos`
--

DROP TABLE IF EXISTS `qos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qos` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL COMMENT 'The quality of service name.',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Quality of service.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quarters`
--

DROP TABLE IF EXISTS `quarters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quarters` (
  `id` int(10) unsigned NOT NULL COMMENT 'The id of the quarter record.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'The year of the record.',
  `quarter` tinyint(3) unsigned NOT NULL COMMENT 'The quarter of the year [1-4]',
  `quarter_start` datetime NOT NULL COMMENT 'The start datetime of the quarter.',
  `quarter_end` datetime NOT NULL COMMENT 'The end datetime of the quarter. ',
  `hours` smallint(5) unsigned NOT NULL COMMENT 'The number of hours in the quarter.',
  `seconds` int(10) unsigned NOT NULL COMMENT 'The number of seconds in the quarter.',
  `quarter_start_ts` int(10) unsigned NOT NULL COMMENT 'The start timestamp of the quarter in epochs.',
  `quarter_end_ts` int(10) unsigned NOT NULL COMMENT 'The end timestamp of the quarter in epochs. If the last job fell during this quarter, the end of the quarter will be abrupt. Hence a partial quarter. ',
  `quarter_middle_ts` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `quarters_pk2` (`year`,`quarter`,`quarter_start`,`quarter_end`) USING BTREE,
  UNIQUE KEY `quarter_yq` (`year`,`quarter`) USING BTREE,
  KEY `quarter_index` (`id`,`seconds`,`quarter_start_ts`,`quarter_end_ts`) USING BTREE,
  KEY `quarter_index2` (`id`,`quarter_start_ts`,`quarter_middle_ts`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='autogen - one rec for each quarter of TG operation.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `queue`
--

DROP TABLE IF EXISTS `queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `queue` (
  `id` char(255) NOT NULL DEFAULT '' COMMENT 'The name of the queue.',
  `resource_id` int(11) NOT NULL COMMENT 'The resource this queue belongs to.',
  `queue_origin_id` char(255) DEFAULT NULL,
  PRIMARY KEY (`id`,`resource_id`) USING BTREE,
  KEY `fk_queue_resource_idx` (`resource_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='The queue names of the different resources.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request`
--

DROP TABLE IF EXISTS `request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The id of the request record.',
  `request_origin_id` int(11) NOT NULL,
  `request_type_id` int(11) NOT NULL COMMENT 'The type of the request. Links to transactiontype table.',
  `primary_fos_id` int(11) NOT NULL COMMENT 'The field of science associated with  the project of this request.',
  `account_id` int(11) NOT NULL COMMENT 'The account pertaining to this request.',
  `proposal_title` varchar(1000) DEFAULT NULL COMMENT 'The title of the proposal for the allocation request.',
  `expedite` tinyint(1) DEFAULT NULL COMMENT 'The date this request expires.',
  `project_title` varchar(300) DEFAULT NULL COMMENT 'The project title related to this request.',
  `primary_reviewer` varchar(100) DEFAULT NULL COMMENT 'The name of the primary reviewer.',
  `proposal_number` varchar(20) DEFAULT NULL COMMENT 'The number of the proposal  of the project.',
  `grant_number` varchar(200) NOT NULL COMMENT 'The grant number.',
  `comments` varchar(2000) DEFAULT NULL COMMENT 'Any comments.',
  `start_date` date NOT NULL COMMENT 'The start date of the request.',
  `end_date` date NOT NULL COMMENT 'The end of the request.',
  `boardtype_id` int(11) DEFAULT NULL COMMENT 'The board type.',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `fk_request_account1_idx` (`account_id`) USING BTREE,
  KEY `fk_request_boardtype1_idx` (`boardtype_id`) USING BTREE,
  KEY `fk_request_fieldofscience1_idx` (`primary_fos_id`) USING BTREE,
  KEY `fk_request_transactiontype1_idx` (`request_type_id`) USING BTREE,
  KEY `index6` (`grant_number`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Requests by PIs for allocations on TG.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resource_allocated`
--

DROP TABLE IF EXISTS `resource_allocated`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_allocated` (
  `resource_id` int(11) NOT NULL,
  `start_date_ts` int(11) NOT NULL,
  `end_date_ts` int(11) DEFAULT NULL,
  `name` varchar(200) DEFAULT NULL,
  `percent` int(11) NOT NULL DEFAULT 100,
  PRIMARY KEY (`resource_id`,`start_date_ts`) USING BTREE,
  KEY `unq` (`name`,`start_date_ts`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resourcefact`
--

DROP TABLE IF EXISTS `resourcefact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resourcefact` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The id of the resource record',
  `resourcetype_id` int(11) DEFAULT 0 COMMENT 'The resource type id.',
  `organization_id` int(11) NOT NULL DEFAULT 1 COMMENT 'The organization of the resource.',
  `name` varchar(200) NOT NULL DEFAULT '' COMMENT 'The name of the resource.',
  `code` varchar(64) NOT NULL COMMENT 'The short name of the resource.',
  `description` varchar(1000) DEFAULT NULL COMMENT 'The description of the resource.',
  `start_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'The date the resource was put into commission.',
  `start_date_ts` int(14) NOT NULL DEFAULT 0,
  `end_date` datetime DEFAULT NULL COMMENT 'The end date of the resource.',
  `end_date_ts` int(14) DEFAULT NULL,
  `shared_jobs` int(1) NOT NULL DEFAULT 0,
  `timezone` varchar(30) NOT NULL DEFAULT 'UTC',
  `resource_origin_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uniq` (`organization_id`,`name`,`start_date`) USING BTREE,
  KEY `aggregation_index` (`resourcetype_id`,`id`) USING BTREE,
  KEY `fk_resource_organization1_idx` (`organization_id`) USING BTREE,
  KEY `fk_resource_resourcetype1_idx` (`resourcetype_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COMMENT='Information about resources.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resourcespecs`
--

DROP TABLE IF EXISTS `resourcespecs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resourcespecs` (
  `resource_id` int(11) NOT NULL,
  `start_date_ts` int(11) NOT NULL,
  `end_date_ts` int(11) DEFAULT NULL,
  `processors` int(11) DEFAULT NULL,
  `q_nodes` int(11) DEFAULT NULL,
  `q_ppn` int(11) DEFAULT NULL,
  `comments` varchar(500) DEFAULT NULL,
  `name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`resource_id`,`start_date_ts`) USING BTREE,
  KEY `unq` (`name`,`start_date_ts`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resourcetype`
--

DROP TABLE IF EXISTS `resourcetype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resourcetype` (
  `id` int(11) NOT NULL COMMENT 'The id of the record.',
  `description` char(50) NOT NULL COMMENT 'The description of the resource type.',
  `abbrev` char(10) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='The different types of resources.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `serviceprovider`
--

DROP TABLE IF EXISTS `serviceprovider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `serviceprovider` (
  `organization_id` int(11) NOT NULL,
  `long_name` varchar(400) DEFAULT NULL,
  `short_name` varchar(100) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`organization_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_jobhosts`
--

DROP TABLE IF EXISTS `staging_jobhosts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_jobhosts` (
  `job_id` int(11) NOT NULL,
  `hostname` varchar(248) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `order_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_resource_type`
--

DROP TABLE IF EXISTS `staging_resource_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_resource_type` (
  `resource_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_type_description` varchar(50) NOT NULL COMMENT 'Resource type description',
  `resource_type_abbrev` varchar(10) NOT NULL COMMENT 'Resource type abbreviation',
  PRIMARY KEY (`resource_type_abbrev`),
  UNIQUE KEY `uk_resource_type_id` (`resource_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Staging table for resource types';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `storagefact`
--

DROP TABLE IF EXISTS `storagefact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `storagefact` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Storage usage record ID',
  `resource_id` int(11) NOT NULL COMMENT 'Resource ID',
  `resourcetype_id` int(11) NOT NULL COMMENT 'Resource type ID',
  `mountpoint_id` int(11) NOT NULL COMMENT 'Mountpoint directory ID',
  `person_id` int(11) NOT NULL COMMENT 'Person ID',
  `principalinvestigator_person_id` int(11) NOT NULL COMMENT 'PI Person ID',
  `systemaccount_id` int(11) NOT NULL COMMENT 'System account ID',
  `fos_id` int(11) NOT NULL COMMENT 'Field of science ID',
  `dt` datetime NOT NULL COMMENT 'Date and time usage data was collected',
  `ts` int(10) unsigned NOT NULL COMMENT 'Timestamp when usage data was collected',
  `file_count` bigint(20) unsigned NOT NULL COMMENT 'File count',
  `logical_usage` bigint(20) unsigned NOT NULL COMMENT 'Logical storage usage in bytes',
  `physical_usage` bigint(20) unsigned DEFAULT NULL COMMENT 'Physical storage usage in bytes',
  `soft_threshold` bigint(20) unsigned NOT NULL COMMENT 'Soft threshold in bytes',
  `hard_threshold` bigint(20) unsigned NOT NULL COMMENT 'Hard threshold in bytes',
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dimensions` (`resource_id`,`resourcetype_id`,`mountpoint_id`,`person_id`,`principalinvestigator_person_id`,`systemaccount_id`,`fos_id`,`ts`),
  KEY `idx_resource_id` (`resource_id`),
  KEY `idx_resourcetype_id` (`resourcetype_id`),
  KEY `idx_mountpoint_id` (`mountpoint_id`),
  KEY `idx_person_id` (`person_id`),
  KEY `idx_principalinvestigator_person_id` (`principalinvestigator_person_id`),
  KEY `idx_systemaccount_id` (`systemaccount_id`),
  KEY `idx_fos_id` (`fos_id`),
  KEY `idx_ts` (`ts`),
  KEY `index_last_modified` (`last_modified`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Storage usage fact table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `submission_venue`
--

DROP TABLE IF EXISTS `submission_venue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `submission_venue` (
  `submission_venue_id` int(11) NOT NULL,
  `submission_venue` varchar(64) NOT NULL COMMENT 'Short version or abbrev',
  `display` varchar(256) NOT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  `order_id` int(5) unsigned NOT NULL,
  PRIMARY KEY (`submission_venue_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Submission mechanism: cli, gateway, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `systemaccount`
--

DROP TABLE IF EXISTS `systemaccount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `systemaccount` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'the id of the record',
  `system_account_origin_id` int(11) DEFAULT NULL,
  `person_id` int(11) NOT NULL COMMENT 'The person to whom this system account belongs',
  `resource_id` int(11) NOT NULL COMMENT 'The resource for which this is an account.',
  `username` varchar(255) NOT NULL COMMENT 'The username to log on to the resource.',
  `ts` datetime DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `system_account_origin_id` (`system_account_origin_id`,`resource_id`) USING BTREE,
  KEY `fk_systemaccount_person1_idx` (`person_id`) USING BTREE,
  KEY `fk_systemaccount_resourcefact1_idx` (`resource_id`) USING BTREE,
  KEY `index_resource_username_id` (`resource_id`,`username`,`id`) USING BTREE,
  KEY `systemaccount_username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=208 DEFAULT CHARSET=latin1 COMMENT='User''s accounts on various resources.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unit`
--

DROP TABLE IF EXISTS `unit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unit` (
  `unit_id` int(11) NOT NULL,
  `unit` varchar(64) NOT NULL COMMENT 'Short version or abbrev',
  `display` varchar(256) NOT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`unit_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Units of countable: GBs, SUs, databases, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `years`
--

DROP TABLE IF EXISTS `years`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `years` (
  `id` int(10) unsigned NOT NULL COMMENT 'The id of the year record.',
  `year` int(10) unsigned NOT NULL COMMENT 'The year of the record.',
  `year_start` datetime NOT NULL COMMENT 'The start datetime of the year',
  `year_end` datetime NOT NULL COMMENT 'The end datetime of the year',
  `hours` smallint(5) unsigned NOT NULL COMMENT 'The number of hours in the year.',
  `seconds` int(10) unsigned NOT NULL COMMENT 'The number of seconds in the year',
  `year_start_ts` int(10) unsigned NOT NULL COMMENT 'The start timestamp of the year in epochs.',
  `year_end_ts` int(10) unsigned NOT NULL COMMENT 'The end timestamp of the year in epochs. If the last job fell during this year the end of the year will be abrupt. Hence a partial year.',
  `year_middle_ts` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `year_pk2` (`year`,`year_start`,`year_end`) USING BTREE,
  UNIQUE KEY `year_yq` (`year`) USING BTREE,
  KEY `year_index` (`id`,`seconds`,`year_start_ts`,`year_end_ts`) USING BTREE,
  KEY `year_index2` (`id`,`year_start_ts`,`year_middle_ts`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='autogen - one rec for each year of TG operation.';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-09-14 21:37:39
