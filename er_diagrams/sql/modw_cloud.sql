-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: mariadb    Database: modw_cloud
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
  `resource_id` int(11) NOT NULL COMMENT 'Resource to which this account belongs',
  `account_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unknown = 1',
  `provider_account` varchar(64) NOT NULL COMMENT 'Account number from cloud provider',
  `display` varchar(256) DEFAULT NULL COMMENT 'What to show the user',
  `principalinvestigator_person_id` int(11) DEFAULT NULL,
  `fos_id` int(11) NOT NULL DEFAULT 1 COMMENT 'The field of science of the project to which the instance belongs to',
  PRIMARY KEY (`resource_id`,`provider_account`),
  UNIQUE KEY `autoincrement_key` (`account_id`),
  KEY `provider_account` (`provider_account`)
) ENGINE=InnoDB AUTO_INCREMENT=258 DEFAULT CHARSET=utf8 COMMENT='Cloud provider account';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `asset`
--

DROP TABLE IF EXISTS `asset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asset` (
  `resource_id` int(11) NOT NULL,
  `asset_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Auto-increment relative to resource_id. We do not have unknown assets.',
  `asset_type_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Unknown = -1 for global dimensions',
  `provider_identifier` varchar(64) NOT NULL DEFAULT '' COMMENT 'Asset identifier from the provider',
  `account_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Optional account the asset is associated with. Unknown = 1.',
  `create_time_ts` decimal(16,6) NOT NULL DEFAULT 0.000000 COMMENT 'The time that the asset was created as a unix timestamp to the microsecond.',
  `destroy_time_ts` decimal(16,6) DEFAULT NULL COMMENT 'The time that the asset was destroyed as a unix timestamp to the microsecond.',
  `size` int(11) NOT NULL DEFAULT -1 COMMENT 'Optional asset size',
  PRIMARY KEY (`resource_id`,`asset_type_id`,`provider_identifier`,`account_id`,`create_time_ts`,`size`),
  UNIQUE KEY `autoincrement_key` (`asset_id`),
  KEY `fk_asset_type` (`asset_type_id`),
  KEY `idx_provider_identifier` (`resource_id`,`provider_identifier`)
) ENGINE=InnoDB AUTO_INCREMENT=1025 DEFAULT CHARSET=utf8 COMMENT='Generic assets';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `asset_type`
--

DROP TABLE IF EXISTS `asset_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asset_type` (
  `asset_type_id` int(11) NOT NULL COMMENT 'Unknown = -1 for global dimensions',
  `asset_type` varchar(64) NOT NULL COMMENT 'Short version or abbrev',
  `display` varchar(256) NOT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  `unit_id` int(11) DEFAULT NULL COMMENT 'Unknown = -1',
  PRIMARY KEY (`asset_type_id`),
  UNIQUE KEY `asset_type` (`asset_type`),
  KEY `fk_unit` (`unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Type of an asset';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cloud_resource_specs`
--

DROP TABLE IF EXISTS `cloud_resource_specs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cloud_resource_specs` (
  `host_id` int(11) NOT NULL,
  `resource_id` int(11) NOT NULL COMMENT 'Unknown = -1 for global dimensions',
  `memory_mb` int(11) NOT NULL COMMENT 'What to show the user',
  `vcpus` int(5) NOT NULL,
  `start_date_ts` int(12) unsigned NOT NULL,
  `end_date_ts` int(12) unsigned DEFAULT NULL,
  `start_day_id` int(11) unsigned NOT NULL,
  `end_day_id` int(11) unsigned DEFAULT NULL,
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`resource_id`,`host_id`,`start_day_id`),
  KEY `index_last_modified` (`last_modified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Contains the start and end time for a specific set of vcpus and memory for a cloud host';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cloudfact_by_day`
--

DROP TABLE IF EXISTS `cloudfact_by_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cloudfact_by_day` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `day_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.days.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the day',
  `day` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The day of the year.',
  `host_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource id of the host of a VM where sessions ran.',
  `account_id` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The account id associated with the VM.',
  `person_id` int(11) NOT NULL COMMENT 'DIMENSION: The person id associated with a VM instance.',
  `systemaccount_id` int(11) NOT NULL COMMENT 'DIMENSION: The system account id associated with a VM instance.',
  `processorbucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined processor bucket sizes. References processor_buckets.id',
  `memorybucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined memory bucket sizes. References memory_buckets.id',
  `instance_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Type of instance on which an event occurred.',
  `num_cores` int(11) NOT NULL COMMENT 'FACT: Number of cores on a VM.',
  `core_time` bigint(42) NOT NULL COMMENT 'FACT: Core hours reserved by a VM.',
  `memory_reserved` bigint(42) NOT NULL COMMENT 'FACT: Memory reserved by a VM.',
  `rv_storage_reserved` bigint(42) NOT NULL COMMENT 'FACT: Root volume storage space reserved by a VM.',
  `memory_mb` int(11) NOT NULL COMMENT 'FACT: Amount of memory in MB reserved by a VM.',
  `disk_gb` int(11) NOT NULL COMMENT 'FACT: Disk size in GB reserved by a VM.',
  `num_sessions_running` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions running in a given period.',
  `num_sessions_started` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions started over a given period.',
  `num_sessions_ended` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions ended over a given period.',
  `wallduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The wall duration of the sessions that were running during this period.',
  `submission_venue_id` int(11) DEFAULT NULL COMMENT 'DIMENSION: The venue that a job or virtual machine was initiated from.',
  `domain_id` int(11) DEFAULT NULL COMMENT 'DIMENSION: A domain is a high-level container for projects, users and groups.',
  `service_provider` int(11) DEFAULT NULL COMMENT 'DIMENSION: A service provider is an institution that hosts resources.',
  `principalinvestigator_person_id` int(11) NOT NULL DEFAULT -1 COMMENT 'DIMENSION: The PI that owns the allocations that these VM''s ran under. References principalinvestigator.person_id',
  `fos_id` int(11) NOT NULL DEFAULT 1 COMMENT 'DIMENSION: The field of science of the project to which the jobs belong',
  `session_id_list` mediumtext NOT NULL COMMENT 'METADATA: the ids in the fact table for the rows that went into this row',
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_account` (`account_id`),
  KEY `index_person` (`person_id`),
  KEY `index_resource` (`host_resource_id`),
  KEY `index_period_value` (`day`),
  KEY `index_period` (`day_id`),
  KEY `index_last_modified` (`last_modified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Cloud facts aggregated by ${AGGREGATION_UNIT}.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cloudfact_by_day_sessionlist`
--

DROP TABLE IF EXISTS `cloudfact_by_day_sessionlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cloudfact_by_day_sessionlist` (
  `agg_id` int(11) NOT NULL,
  `session_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`agg_id`,`session_id`) USING BTREE,
  UNIQUE KEY `session_lookup_key` (`session_id`,`agg_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cloudfact_by_month`
--

DROP TABLE IF EXISTS `cloudfact_by_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cloudfact_by_month` (
  `month_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.months.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the month',
  `month` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The month of the year.',
  `host_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource id of the host of a VM where sessions ran.',
  `account_id` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The account id associated with the VM.',
  `person_id` int(11) NOT NULL COMMENT 'DIMENSION: The person id associated with a VM instance.',
  `systemaccount_id` int(11) NOT NULL COMMENT 'DIMENSION: The system account id associated with a VM instance.',
  `processorbucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined processor bucket sizes. References processor_buckets.id',
  `memorybucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined memory bucket sizes. References memory_buckets.id',
  `instance_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Type of instance on which an event occurred.',
  `num_cores` int(11) NOT NULL COMMENT 'FACT: Number of cores on a VM.',
  `core_time` bigint(42) NOT NULL COMMENT 'FACT: Core hours reserved by a VM.',
  `memory_reserved` bigint(42) NOT NULL COMMENT 'FACT: Memory reserved by a VM.',
  `rv_storage_reserved` bigint(42) NOT NULL COMMENT 'FACT: Root volume storage space reserved by a VM.',
  `memory_mb` int(11) NOT NULL COMMENT 'FACT: Amount of memory in MB reserved by a VM.',
  `disk_gb` int(11) NOT NULL COMMENT 'FACT: Disk size in GB reserved by a VM.',
  `num_sessions_running` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions running in a given period.',
  `num_sessions_started` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions started over a given period.',
  `num_sessions_ended` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions ended over a given period.',
  `wallduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The wall duration of the sessions that were running during this period.',
  `submission_venue_id` int(11) DEFAULT NULL COMMENT 'DIMENSION: The venue that a job or virtual machine was initiated from.',
  `domain_id` int(11) DEFAULT NULL COMMENT 'DIMENSION: A domain is a high-level container for projects, users and groups.',
  `service_provider` int(11) DEFAULT NULL COMMENT 'DIMENSION: A service provider is an institution that hosts resources.',
  `principalinvestigator_person_id` int(11) NOT NULL DEFAULT -1 COMMENT 'DIMENSION: The PI that owns the allocations that these VM''s ran under. References principalinvestigator.person_id',
  `fos_id` int(11) NOT NULL DEFAULT 1 COMMENT 'DIMENSION: The field of science of the project to which the jobs belong',
  KEY `index_account` (`account_id`),
  KEY `index_person` (`person_id`),
  KEY `index_resource` (`host_resource_id`),
  KEY `index_period_value` (`month`),
  KEY `index_period` (`month_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Euca facts aggregated by ${AGGREGATION_UNIT}.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cloudfact_by_quarter`
--

DROP TABLE IF EXISTS `cloudfact_by_quarter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cloudfact_by_quarter` (
  `quarter_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.quarters.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the quarter',
  `quarter` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The quarter of the year.',
  `host_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource id of the host of a VM where sessions ran.',
  `account_id` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The account id associated with the VM.',
  `person_id` int(11) NOT NULL COMMENT 'DIMENSION: The person id associated with a VM instance.',
  `systemaccount_id` int(11) NOT NULL COMMENT 'DIMENSION: The system account id associated with a VM instance.',
  `processorbucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined processor bucket sizes. References processor_buckets.id',
  `memorybucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined memory bucket sizes. References memory_buckets.id',
  `instance_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Type of instance on which an event occurred.',
  `num_cores` int(11) NOT NULL COMMENT 'FACT: Number of cores on a VM.',
  `core_time` bigint(42) NOT NULL COMMENT 'FACT: Core hours reserved by a VM.',
  `memory_reserved` bigint(42) NOT NULL COMMENT 'FACT: Memory reserved by a VM.',
  `rv_storage_reserved` bigint(42) NOT NULL COMMENT 'FACT: Root volume storage space reserved by a VM.',
  `memory_mb` int(11) NOT NULL COMMENT 'FACT: Amount of memory in MB reserved by a VM.',
  `disk_gb` int(11) NOT NULL COMMENT 'FACT: Disk size in GB reserved by a VM.',
  `num_sessions_running` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions running in a given period.',
  `num_sessions_started` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions started over a given period.',
  `num_sessions_ended` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions ended over a given period.',
  `wallduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The wall duration of the sessions that were running during this period.',
  `submission_venue_id` int(11) DEFAULT NULL COMMENT 'DIMENSION: The venue that a job or virtual machine was initiated from.',
  `domain_id` int(11) DEFAULT NULL COMMENT 'DIMENSION: A domain is a high-level container for projects, users and groups.',
  `service_provider` int(11) DEFAULT NULL COMMENT 'DIMENSION: A service provider is an institution that hosts resources.',
  `principalinvestigator_person_id` int(11) NOT NULL DEFAULT -1 COMMENT 'DIMENSION: The PI that owns the allocations that these VM''s ran under. References principalinvestigator.person_id',
  `fos_id` int(11) NOT NULL DEFAULT 1 COMMENT 'DIMENSION: The field of science of the project to which the jobs belong',
  KEY `index_account` (`account_id`),
  KEY `index_person` (`person_id`),
  KEY `index_resource` (`host_resource_id`),
  KEY `index_period_value` (`quarter`),
  KEY `index_period` (`quarter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Euca facts aggregated by ${AGGREGATION_UNIT}.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cloudfact_by_year`
--

DROP TABLE IF EXISTS `cloudfact_by_year`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cloudfact_by_year` (
  `year_id` int(10) unsigned NOT NULL COMMENT 'DIMENSION: The id related to modw.years.',
  `year` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The year of the year.',
  `host_resource_id` int(11) NOT NULL COMMENT 'DIMENSION: The resource id of the host of a VM where sessions ran.',
  `account_id` smallint(5) unsigned NOT NULL COMMENT 'DIMENSION: The account id associated with the VM.',
  `person_id` int(11) NOT NULL COMMENT 'DIMENSION: The person id associated with a VM instance.',
  `systemaccount_id` int(11) NOT NULL COMMENT 'DIMENSION: The system account id associated with a VM instance.',
  `processorbucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined processor bucket sizes. References processor_buckets.id',
  `memorybucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined memory bucket sizes. References memory_buckets.id',
  `instance_type_id` int(11) NOT NULL COMMENT 'DIMENSION: Type of instance on which an event occurred.',
  `num_cores` int(11) NOT NULL COMMENT 'FACT: Number of cores on a VM.',
  `core_time` bigint(42) NOT NULL COMMENT 'FACT: Core hours reserved by a VM.',
  `memory_reserved` bigint(42) NOT NULL COMMENT 'FACT: Memory reserved by a VM.',
  `rv_storage_reserved` bigint(42) NOT NULL COMMENT 'FACT: Root volume storage space reserved by a VM.',
  `memory_mb` int(11) NOT NULL COMMENT 'FACT: Amount of memory in MB reserved by a VM.',
  `disk_gb` int(11) NOT NULL COMMENT 'FACT: Disk size in GB reserved by a VM.',
  `num_sessions_running` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions running in a given period.',
  `num_sessions_started` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions started over a given period.',
  `num_sessions_ended` int(11) DEFAULT NULL COMMENT 'FACT: Number of sessions ended over a given period.',
  `wallduration` decimal(18,0) DEFAULT NULL COMMENT 'FACT: (seconds) The wall duration of the sessions that were running during this period.',
  `submission_venue_id` int(11) DEFAULT NULL COMMENT 'DIMENSION: The venue that a job or virtual machine was initiated from.',
  `domain_id` int(11) DEFAULT NULL COMMENT 'DIMENSION: A domain is a high-level container for projects, users and groups.',
  `service_provider` int(11) DEFAULT NULL COMMENT 'DIMENSION: A service provider is an institution that hosts resources.',
  `principalinvestigator_person_id` int(11) NOT NULL DEFAULT -1 COMMENT 'DIMENSION: The PI that owns the allocations that these VM''s ran under. References principalinvestigator.person_id',
  `fos_id` int(11) NOT NULL DEFAULT 1 COMMENT 'DIMENSION: The field of science of the project to which the jobs belong',
  KEY `index_account` (`account_id`),
  KEY `index_person` (`person_id`),
  KEY `index_resource` (`host_resource_id`),
  KEY `index_period_value` (`year`),
  KEY `index_period` (`year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Euca facts aggregated by ${AGGREGATION_UNIT}.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `domain_submission_venues`
--

DROP TABLE IF EXISTS `domain_submission_venues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domain_submission_venues` (
  `domain_submission_venue_id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) NOT NULL COMMENT 'FK to domains.id',
  `submission_venue_id` int(11) NOT NULL COMMENT 'FK to submission_venue.submission_venue_id',
  PRIMARY KEY (`domain_submission_venue_id`),
  KEY `idx_fk_domain_id` (`domain_id`) USING BTREE,
  KEY `idx_fk_submission_venue_id` (`submission_venue_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Which domains are currently being tracked by the Cloud realm';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `domain_submission_venues_staging`
--

DROP TABLE IF EXISTS `domain_submission_venues_staging`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domain_submission_venues_staging` (
  `resource_code` varchar(64) NOT NULL COMMENT 'FK to modw.resourcefact.code',
  `domain_name` varchar(64) NOT NULL COMMENT 'FK to modw_cloud.domains.name',
  `submission_venue_name` varchar(64) NOT NULL COMMENT 'FK to modw_cloud.submission_venue.submission_venue'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Which domains are currently being tracked by the Cloud realm';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `domains`
--

DROP TABLE IF EXISTS `domains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Column that will uniquely identify each row',
  `resource_id` int(11) NOT NULL COMMENT 'Resource to which this domain belongs',
  `name` varchar(64) NOT NULL COMMENT 'The human readable internal name, as received from the resource.',
  PRIMARY KEY (`resource_id`,`name`),
  UNIQUE KEY `increment_key` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='Which domains are currently being tracked by the Cloud realm';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event` (
  `resource_id` int(11) NOT NULL,
  `event_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Generated during ingest, relative to the resource.',
  `instance_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Optional instance event is associated with. Unknown = 1',
  `event_time_ts` decimal(16,6) NOT NULL DEFAULT 0.000000,
  `person_id` int(11) NOT NULL DEFAULT -1,
  `systemaccount_id` int(11) NOT NULL DEFAULT -1,
  `event_type_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Unknown = -1 for global dimensions',
  `record_type_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Unknown = -1 for global dimensions',
  `host_id` int(11) NOT NULL COMMENT 'Host where the event occured. Unknown = 1',
  `submission_venue_id` int(5) NOT NULL DEFAULT -1,
  `domain_id` int(11) NOT NULL DEFAULT -1 COMMENT 'domain that the event is related to. Unknown = -1',
  `service_provider` int(11) NOT NULL DEFAULT -1 COMMENT 'Service provider that the event is related to. Unknown = -1',
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`resource_id`,`instance_id`,`event_time_ts`,`event_type_id`,`host_id`),
  UNIQUE KEY `increment_key` (`event_id`),
  KEY `fk_event_type` (`event_type_id`),
  KEY `fk_instance` (`instance_id`,`resource_id`),
  KEY `index_last_modified` (`last_modified`)
) ENGINE=InnoDB AUTO_INCREMENT=2049 DEFAULT CHARSET=utf8 COMMENT='Events on an instance';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event_asset`
--

DROP TABLE IF EXISTS `event_asset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_asset` (
  `resource_id` int(11) NOT NULL,
  `event_id` bigint(20) unsigned NOT NULL,
  `asset_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`resource_id`,`event_id`,`asset_id`),
  KEY `fk_event` (`resource_id`,`event_id`),
  KEY `fk_asset` (`resource_id`,`asset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Assets associated with an event';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event_reconstructed`
--

DROP TABLE IF EXISTS `event_reconstructed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_reconstructed` (
  `resource_id` int(11) NOT NULL,
  `instance_id` int(11) NOT NULL,
  `start_time_ts` decimal(16,6) NOT NULL,
  `start_event_id` int(11) NOT NULL,
  `end_time_ts` decimal(16,6) NOT NULL,
  `end_event_id` int(11) NOT NULL,
  KEY `event_instance_id` (`instance_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='The start and end times for cloud instances reconstructed from event data.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event_type`
--

DROP TABLE IF EXISTS `event_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_type` (
  `event_type_id` int(11) NOT NULL COMMENT 'Unknown = -1 for global dimensions',
  `event_type` varchar(64) NOT NULL COMMENT 'Short version or abbrev',
  `display` varchar(256) NOT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`event_type_id`),
  UNIQUE KEY `event_type` (`event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Event type: start, stop, attach, detach, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `generic_cloud_raw_event`
--

DROP TABLE IF EXISTS `generic_cloud_raw_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generic_cloud_raw_event` (
  `resource_id` int(11) NOT NULL,
  `provider_instance_identifier` varchar(64) DEFAULT NULL COMMENT 'Optional instance event is associated with.',
  `event_time_utc` char(26) NOT NULL DEFAULT '0000-00-00T00:00:00.000000' COMMENT 'String representation of timestamp directly from the logs.',
  `event_type` varchar(64) NOT NULL,
  `record_type` varchar(64) NOT NULL,
  `hostname` varchar(64) DEFAULT NULL,
  `instance_type` varchar(64) DEFAULT NULL COMMENT 'Short version or abbrev',
  `image` varchar(64) DEFAULT NULL,
  `provider_account` varchar(64) DEFAULT NULL,
  `event_data` varchar(256) DEFAULT NULL COMMENT 'Additional data specific to an event (e.g., volume, IP address, etc.)',
  `first_volume` varchar(256) DEFAULT NULL,
  `root_volume_type` varchar(64) DEFAULT NULL,
  `service_provider` varchar(64) DEFAULT NULL,
  KEY `resource_id` (`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Raw events from the log file.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `generic_cloud_raw_instance_type`
--

DROP TABLE IF EXISTS `generic_cloud_raw_instance_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generic_cloud_raw_instance_type` (
  `instance_type` varchar(64) DEFAULT NULL COMMENT 'Short version or abbrev',
  `resource_id` int(11) NOT NULL COMMENT 'Resource to which this type belongs',
  `display` varchar(256) DEFAULT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  `num_cores` int(11) DEFAULT 0,
  `memory_mb` int(11) DEFAULT 0,
  `disk_gb` int(11) DEFAULT 0 COMMENT 'Disk size configured in image',
  `start_time` char(26) DEFAULT '0000-00-00T00:00:00.000000' COMMENT 'First time this configuration was encountered as a unix timestamp to the microsecond, defaults to unknown.',
  KEY `resource_id` (`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Raw instance type data parsed from log files.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `generic_cloud_raw_volume`
--

DROP TABLE IF EXISTS `generic_cloud_raw_volume`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generic_cloud_raw_volume` (
  `resource_id` int(11) NOT NULL,
  `provider_instance_identifier` varchar(64) DEFAULT NULL COMMENT 'Provider instance id that this volume is associated with.',
  `provider_account_number` varchar(64) DEFAULT NULL COMMENT 'Account number that owns this volume.',
  `event_time_utc` char(26) NOT NULL DEFAULT '0000-00-00T00:00:00.000000' COMMENT 'The time of the event in UTC.',
  `attach_time_utc` char(26) NOT NULL DEFAULT '0000-00-00T00:00:00.000000' COMMENT 'The time of the event in UTC.',
  `create_time_utc` char(26) NOT NULL DEFAULT '0000-00-00T00:00:00.000000' COMMENT 'The time of the event in UTC.',
  `provider_volume_identifier` varchar(64) NOT NULL COMMENT 'Volumne id from the provider',
  `provider_account_name` varchar(64) DEFAULT NULL COMMENT 'Provider account name that owns this volume.',
  `provider_user` varchar(64) DEFAULT NULL COMMENT 'Provider username that owns the volume.',
  `disk_gb` int(11) NOT NULL DEFAULT 0 COMMENT 'Device size in GB.',
  `type` varchar(64) NOT NULL COMMENT 'Backing store type (instance, ebs).',
  UNIQUE KEY `uniqueness` (`resource_id`,`provider_volume_identifier`,`disk_gb`,`type`,`create_time_utc`),
  KEY `resource_id` (`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Raw block devices/volumes from the log file.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `generic_cloud_staging_event`
--

DROP TABLE IF EXISTS `generic_cloud_staging_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generic_cloud_staging_event` (
  `resource_id` int(11) NOT NULL,
  `instance_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Optional instance the event is associated with. Unknown = 1',
  `event_time_ts` decimal(16,6) NOT NULL DEFAULT 0.000000 COMMENT 'The time of the event as a unix timestamp to the microsecond..',
  `event_type_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Unknown = -1 for global dimensions',
  `user_name` varchar(32) DEFAULT NULL COMMENT 'Username associated with event',
  `person_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Person ID associated with event',
  `record_type_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Unknown = -1 for global dimensions',
  `account_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Optional account the event is associated with. Unknown = 1',
  `host_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Host where the event occured. Unknown = 1',
  `instance_type_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Instance type for the event. Unknown = 1',
  `image_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Image associated with the event. Unknown = 1',
  `event_data` varchar(256) DEFAULT NULL COMMENT 'Additional data specific to an event (e.g., volume, IP address, etc.)',
  `root_volume_type_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Asset type of the root volume as defined by the instance type. Unknown = -1',
  `service_provider` int(11) DEFAULT NULL COMMENT 'The service provider associated with the event',
  PRIMARY KEY (`resource_id`,`instance_id`,`event_time_ts`,`event_type_id`,`record_type_id`,`person_id`,`account_id`,`host_id`),
  KEY `event_data` (`event_data`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Staged events with some ids.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `host`
--

DROP TABLE IF EXISTS `host`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `host` (
  `resource_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Auto-increment relative to resource_id. Unknown = 1',
  `hostname` varchar(64) NOT NULL DEFAULT 'Unknown',
  PRIMARY KEY (`resource_id`,`hostname`),
  UNIQUE KEY `autoincrement_key` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='Hostnames for each resource';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image`
--

DROP TABLE IF EXISTS `image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image` (
  `resource_id` int(11) NOT NULL,
  `image_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Auto-increment relative to resource_id. Unknown = 1',
  `image` varchar(64) NOT NULL DEFAULT 'Unknown',
  PRIMARY KEY (`resource_id`,`image`),
  UNIQUE KEY `autoincrement_key` (`image_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Images used by cloud instances';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance`
--

DROP TABLE IF EXISTS `instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance` (
  `resource_id` int(11) NOT NULL,
  `instance_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Auto-increment relative to resource_id. Unknown = 1',
  `account_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Unknown = 1',
  `provider_identifier` varchar(256) NOT NULL COMMENT 'Instance identifier from cloud provider',
  `person_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Unknown = -1',
  `service_provider` int(11) NOT NULL DEFAULT 1 COMMENT 'Unknown = 1',
  PRIMARY KEY (`resource_id`,`provider_identifier`,`service_provider`),
  UNIQUE KEY `increment_key` (`instance_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='Cloud instances';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_data`
--

DROP TABLE IF EXISTS `instance_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_data` (
  `resource_id` int(11) NOT NULL,
  `event_id` bigint(20) unsigned NOT NULL,
  `instance_type_id` int(11) NOT NULL,
  `image_id` int(11) NOT NULL,
  `host_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`resource_id`,`event_id`) USING BTREE,
  KEY `fk_instance` (`instance_type_id`) USING BTREE,
  KEY `fk_image` (`image_id`) USING BTREE,
  KEY `fk_host` (`host_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Additional instance information';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_type`
--

DROP TABLE IF EXISTS `instance_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_type` (
  `resource_id` int(11) NOT NULL COMMENT 'Resource to which this type belongs',
  `instance_type_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Auto-increment relative to resource_id. Unknown = 1',
  `instance_type` varchar(64) NOT NULL COMMENT 'Short version or abbrev',
  `display` varchar(256) NOT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  `num_cores` int(11) NOT NULL DEFAULT 0,
  `memory_mb` int(11) NOT NULL DEFAULT 0,
  `disk_gb` int(11) NOT NULL DEFAULT 0 COMMENT 'Disk size configured in image',
  `start_time` decimal(16,6) NOT NULL DEFAULT 0.000000 COMMENT 'First time that this configuration was seen as a unix timestamp to the microsecond. defaults to unknown.',
  `end_time` decimal(16,6) DEFAULT NULL COMMENT 'End time for this configuration as a unix timestamp to the microsecond., NULL if it is still in effect.',
  PRIMARY KEY (`resource_id`,`instance_type`,`num_cores`,`memory_mb`,`disk_gb`),
  UNIQUE KEY `increment_key` (`instance_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Instance type configurations. Values for the same name may change over time.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `memory_buckets`
--

DROP TABLE IF EXISTS `memory_buckets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `memory_buckets` (
  `id` int(4) NOT NULL,
  `min_memory` int(11) DEFAULT NULL,
  `max_memory` int(11) DEFAULT NULL,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `proc` (`min_memory`,`max_memory`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `openstack_event_map`
--

DROP TABLE IF EXISTS `openstack_event_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openstack_event_map` (
  `openstack_event_type_id` int(11) NOT NULL COMMENT 'Unknown = -1 for global dimensions',
  `event_type_id` int(11) NOT NULL COMMENT 'Unknown = -1 for global dimensions',
  `openstack_event_type` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`openstack_event_type_id`),
  UNIQUE KEY `openstack_event_type` (`openstack_event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Maps Open Stack events to list of defined events in event_type table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `openstack_raw_event`
--

DROP TABLE IF EXISTS `openstack_raw_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openstack_raw_event` (
  `resource_id` int(11) NOT NULL,
  `provider_instance_identifier` varchar(64) DEFAULT NULL COMMENT 'Optional instance event is associated with.',
  `event_time_utc` char(26) NOT NULL DEFAULT '0000-00-00T00:00:00.000000' COMMENT 'The time of the event in UTC.',
  `create_time_utc` char(26) DEFAULT '0000-00-00T00:00:00.000000' COMMENT 'The time of the event in UTC.',
  `event_type` varchar(64) NOT NULL,
  `record_type` varchar(64) DEFAULT NULL,
  `hostname` varchar(64) DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `user_id` varchar(64) DEFAULT NULL,
  `instance_type` varchar(64) DEFAULT NULL COMMENT 'Short version or abbrev',
  `provider_account` varchar(64) DEFAULT NULL,
  `project_name` varchar(256) DEFAULT NULL,
  `project_id` varchar(64) DEFAULT NULL,
  `request_id` varchar(64) DEFAULT NULL,
  `event_data` varchar(256) DEFAULT NULL COMMENT 'Additional data specific to an event (e.g., volume, IP address, etc.)',
  `openstack_resource_id` varchar(64) DEFAULT NULL,
  `disk_gb` int(11) DEFAULT NULL,
  `memory_mb` int(11) DEFAULT NULL,
  `num_cores` int(11) DEFAULT NULL,
  `size` bigint(16) DEFAULT NULL,
  `volume_id` varchar(64) DEFAULT NULL,
  `state` varchar(64) DEFAULT NULL,
  `domain` varchar(64) DEFAULT NULL,
  `service_provider` varchar(64) DEFAULT NULL,
  KEY `resource_id` (`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Raw events from Open Stack log events.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `openstack_raw_instance_type`
--

DROP TABLE IF EXISTS `openstack_raw_instance_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openstack_raw_instance_type` (
  `instance_type` varchar(64) DEFAULT NULL COMMENT 'Short version or abbrev',
  `resource_id` int(11) NOT NULL COMMENT 'Resource to which this type belongs',
  `display` varchar(256) DEFAULT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  `num_cores` int(11) DEFAULT 0,
  `memory_mb` int(11) DEFAULT 0,
  `disk_gb` int(11) DEFAULT 0 COMMENT 'Disk size configured in image',
  `start_time` char(26) NOT NULL DEFAULT '0000-00-00T00:00:00.000000' COMMENT 'The time of the event in UTC.',
  KEY `resource_id` (`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Raw instance type data parsed from log files.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `openstack_raw_volume`
--

DROP TABLE IF EXISTS `openstack_raw_volume`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openstack_raw_volume` (
  `resource_id` int(11) NOT NULL,
  `provider_instance_identifier` varchar(64) DEFAULT NULL COMMENT 'Provider instance id that this volume is associated with.',
  `provider_account_number` varchar(64) DEFAULT NULL COMMENT 'Account number that owns this volume.',
  `event_time_ts` decimal(16,6) NOT NULL DEFAULT 0.000000 COMMENT 'A unix timestamp to the microsecond.',
  `attach_time_ts` decimal(16,6) NOT NULL DEFAULT 0.000000 COMMENT 'The time that the volume was attached to an instance as a unix timestamp to the microsecond.',
  `create_time_ts` decimal(16,6) NOT NULL DEFAULT 0.000000 COMMENT 'The time that the volume was created as a unix timestamp to the microsecond.',
  `provider_volume_identifier` varchar(64) NOT NULL COMMENT 'Volumne id from the provider',
  `provider_account_name` varchar(64) DEFAULT NULL COMMENT 'Provider account name that owns this volume.',
  `provider_user` varchar(64) DEFAULT NULL COMMENT 'Provider username that owns the volume.',
  `disk_gb` int(11) NOT NULL DEFAULT 0 COMMENT 'Device size in GB.',
  `type` varchar(64) NOT NULL COMMENT 'Backing store type (instance, ebs).',
  UNIQUE KEY `uniqueness` (`resource_id`,`provider_volume_identifier`,`disk_gb`,`type`,`create_time_ts`),
  KEY `resource_id` (`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Raw block devices/volumes from the log file.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `openstack_staging_event`
--

DROP TABLE IF EXISTS `openstack_staging_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openstack_staging_event` (
  `resource_id` int(11) NOT NULL,
  `instance_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Optional instance the event is associated with. Unknown = 1',
  `event_time_ts` decimal(16,6) NOT NULL DEFAULT 0.000000 COMMENT 'Unix timestamp to the microsecond.',
  `event_type_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Unknown = -1 for global dimensions',
  `user_name` varchar(32) DEFAULT NULL COMMENT 'Username associated with event',
  `person_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Person ID associated with event',
  `record_type_id` int(11) NOT NULL DEFAULT -1 COMMENT 'Unknown = -1 for global dimensions',
  `account_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Optional account the event is associated with. Unknown = 1',
  `host_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Host where the event occured. Unknown = 1',
  `instance_type_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Instance type for the event. Unknown = 1',
  `event_data` varchar(256) DEFAULT NULL COMMENT 'Additional data specific to an event (e.g., volume, IP address, etc.)',
  `root_volume_type_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Asset type of the root volume as defined by the instance type. Unknown = 1',
  `image_id` int(11) NOT NULL DEFAULT 1 COMMENT 'Image associated with the event. Unknown = 1',
  `volume_id` varchar(64) DEFAULT NULL COMMENT 'Volume associated with the event.',
  `domain_id` int(11) DEFAULT NULL COMMENT 'The domain associated with the event',
  `service_provider` int(11) DEFAULT NULL COMMENT 'The service provider associated with the event',
  PRIMARY KEY (`resource_id`,`instance_id`,`event_time_ts`,`event_type_id`,`record_type_id`,`person_id`,`account_id`,`host_id`),
  KEY `event_data` (`event_data`),
  KEY `volume_id` (`volume_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Staged events with some ids.';
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `raw_resource_specs`
--

DROP TABLE IF EXISTS `raw_resource_specs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `raw_resource_specs` (
  `hostname` varchar(225) NOT NULL,
  `resource_id` int(11) NOT NULL COMMENT 'Unknown = -1 for global dimensions',
  `memory_mb` int(11) NOT NULL COMMENT 'Amount of memory available on the associated node.',
  `vcpus` int(5) NOT NULL COMMENT 'Number of vcpus available on the associated node.',
  `fact_date` varchar(25) NOT NULL,
  PRIMARY KEY (`resource_id`,`hostname`,`memory_mb`,`vcpus`,`fact_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Record type: accounting, administrative, derived, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `record_type`
--

DROP TABLE IF EXISTS `record_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `record_type` (
  `record_type_id` int(11) NOT NULL COMMENT 'Unknown = -1 for global dimensions',
  `record_type` varchar(64) NOT NULL COMMENT 'Short version or abbrev',
  `display` varchar(256) NOT NULL COMMENT 'What to show the user',
  `description` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`record_type_id`),
  UNIQUE KEY `record_type` (`record_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Record type: accounting, administrative, derived, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `session_records`
--

DROP TABLE IF EXISTS `session_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session_records` (
  `session_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `instance_id` int(11) NOT NULL,
  `resource_id` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `start_event_type_id` int(11) NOT NULL,
  `end_time` datetime NOT NULL,
  `end_event_type_id` int(11) NOT NULL,
  `instance_type` varchar(64) NOT NULL,
  `instance_type_id` int(11) NOT NULL,
  `num_cores` int(11) NOT NULL,
  `memory_mb` int(11) NOT NULL,
  `processorbucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined processor bucket sizes. References processor_buckets.id',
  `memorybucket_id` int(4) NOT NULL COMMENT 'DIMENSION: Pre-determined memory bucket sizes. References memory_buckets.id',
  `disk_gb` int(11) NOT NULL,
  `start_time_ts` bigint(18) NOT NULL,
  `end_time_ts` bigint(18) NOT NULL,
  `start_day_id` int(11) DEFAULT NULL,
  `end_day_id` int(11) DEFAULT NULL,
  `wallduration` bigint(18) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `systemaccount_id` int(11) DEFAULT NULL,
  `submission_venue_id` int(5) DEFAULT NULL,
  `domain_id` int(11) DEFAULT NULL,
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `service_provider` int(11) NOT NULL,
  `account_id` int(11) DEFAULT NULL,
  `principalinvestigator_person_id` int(11) NOT NULL DEFAULT -1 COMMENT 'DIMENSION: The PI that owns the allocations that these VM''s ran under. References principalinvestigator.person_id',
  `fos_id` int(11) NOT NULL DEFAULT 1 COMMENT 'DIMENSION: The field of science of the project to which the jobs belong',
  `host_id` int(11) NOT NULL DEFAULT 1 COMMENT 'DIMENSION: The host the VM is located on',
  PRIMARY KEY (`resource_id`,`instance_id`,`start_time_ts`,`start_event_type_id`),
  UNIQUE KEY `increment_key` (`session_id`),
  KEY `index_last_modified` (`last_modified`),
  KEY `session_instance_id` (`instance_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='The start and end times for cloud instances reconstructed from event data.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_pi_to_project`
--

DROP TABLE IF EXISTS `staging_pi_to_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_pi_to_project` (
  `project_name` varchar(225) NOT NULL,
  `pi_name` varchar(225) NOT NULL,
  `resource_name` varchar(225) NOT NULL,
  PRIMARY KEY (`project_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Record type: accounting, administrative, derived, etc.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_resource_specifications`
--

DROP TABLE IF EXISTS `staging_resource_specifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_resource_specifications` (
  `host_id` int(11) NOT NULL,
  `resource_id` int(11) NOT NULL COMMENT 'Unknown = -1 for global dimensions',
  `memory_mb` int(11) NOT NULL COMMENT 'Amount of memory available on the associated node.',
  `vcpus` int(5) NOT NULL COMMENT 'Number of vcpus available on the associated node.',
  `fact_date` date NOT NULL,
  PRIMARY KEY (`resource_id`,`host_id`,`fact_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Contains a specific set of vcpus and memory size for a host for a day';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-09-14 21:38:15
