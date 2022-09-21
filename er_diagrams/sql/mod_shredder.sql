-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: mariadb    Database: mod_shredder
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
-- Table structure for table `shredded_job`
--

DROP TABLE IF EXISTS `shredded_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shredded_job` (
  `shredded_job_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `source_format` enum('pbs','sge','slurm','lsf') NOT NULL,
  `date_key` date NOT NULL,
  `job_id` int(10) unsigned NOT NULL,
  `job_array_index` int(10) unsigned DEFAULT NULL,
  `job_id_raw` int(10) unsigned DEFAULT NULL,
  `job_name` varchar(255) DEFAULT NULL,
  `resource_name` varchar(255) NOT NULL,
  `queue_name` varchar(255) NOT NULL,
  `qos_name` varchar(255) DEFAULT NULL,
  `user_name` varchar(255) NOT NULL,
  `uid_number` int(10) unsigned DEFAULT NULL,
  `group_name` varchar(255) NOT NULL DEFAULT 'Unknown',
  `gid_number` int(10) unsigned DEFAULT NULL,
  `account_name` varchar(255) NOT NULL DEFAULT 'Unknown',
  `project_name` varchar(255) NOT NULL DEFAULT 'Unknown',
  `pi_name` varchar(255) NOT NULL DEFAULT 'Unknown',
  `start_time` int(10) unsigned NOT NULL,
  `end_time` int(10) unsigned NOT NULL,
  `submission_time` int(10) unsigned NOT NULL,
  `eligible_time` int(10) unsigned DEFAULT NULL,
  `wall_time` bigint(20) unsigned NOT NULL,
  `wait_time` bigint(20) unsigned NOT NULL,
  `exit_code` varchar(32) DEFAULT NULL,
  `exit_state` varchar(32) DEFAULT NULL,
  `node_count` int(10) unsigned NOT NULL,
  `cpu_count` int(10) unsigned NOT NULL,
  `gpu_count` int(10) unsigned NOT NULL DEFAULT 0,
  `cpu_req` int(10) unsigned DEFAULT NULL,
  `mem_req` varchar(32) DEFAULT NULL,
  `timelimit` int(10) unsigned DEFAULT NULL,
  `node_list` mediumtext DEFAULT NULL,
  PRIMARY KEY (`shredded_job_id`),
  KEY `source` (`source_format`,`resource_name`),
  KEY `date_key` (`date_key`,`resource_name`),
  KEY `end_time` (`end_time`,`resource_name`),
  KEY `resource_name` (`resource_name`),
  KEY `pi_name` (`pi_name`,`resource_name`),
  KEY `user_name` (`user_name`,`resource_name`,`pi_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shredded_job_lsf`
--

DROP TABLE IF EXISTS `shredded_job_lsf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shredded_job_lsf` (
  `shredded_job_lsf_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `job_id` int(10) unsigned NOT NULL,
  `idx` int(10) unsigned NOT NULL,
  `job_name` varchar(255) NOT NULL DEFAULT '',
  `resource_name` varchar(255) NOT NULL,
  `queue` varchar(255) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `project_name` varchar(255) NOT NULL DEFAULT '',
  `submit_time` int(10) unsigned NOT NULL,
  `start_time` int(10) unsigned NOT NULL,
  `event_time` int(10) unsigned NOT NULL,
  `num_processors` int(10) unsigned NOT NULL,
  `num_ex_hosts` int(10) unsigned NOT NULL,
  `exit_status` int(10) NOT NULL,
  `exit_info` int(10) NOT NULL,
  `node_list` mediumtext NOT NULL,
  PRIMARY KEY (`shredded_job_lsf_id`),
  UNIQUE KEY `job` (`resource_name`,`job_id`,`idx`,`submit_time`,`event_time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shredded_job_pbs`
--

DROP TABLE IF EXISTS `shredded_job_pbs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shredded_job_pbs` (
  `shredded_job_pbs_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `job_id` int(10) unsigned NOT NULL,
  `job_array_index` int(10) NOT NULL DEFAULT -1,
  `host` varchar(255) NOT NULL,
  `queue` varchar(255) NOT NULL,
  `user` varchar(255) NOT NULL,
  `groupname` varchar(255) NOT NULL,
  `ctime` int(11) NOT NULL,
  `qtime` int(11) NOT NULL,
  `start` int(11) NOT NULL,
  `end` int(11) NOT NULL,
  `etime` int(11) NOT NULL,
  `exit_status` int(11) DEFAULT NULL,
  `session` int(10) unsigned DEFAULT NULL,
  `requestor` varchar(255) DEFAULT NULL,
  `jobname` varchar(255) DEFAULT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `account` varchar(255) DEFAULT NULL,
  `session_id` int(11) DEFAULT NULL,
  `error_path` varchar(255) DEFAULT NULL,
  `output_path` varchar(255) DEFAULT NULL,
  `exec_host` text DEFAULT NULL,
  `resources_used_vmem` bigint(20) unsigned DEFAULT NULL,
  `resources_used_mem` bigint(20) unsigned DEFAULT NULL,
  `resources_used_walltime` bigint(20) unsigned DEFAULT NULL,
  `resources_used_nodes` int(10) unsigned DEFAULT NULL,
  `resources_used_cpus` int(10) unsigned DEFAULT NULL,
  `resources_used_cput` bigint(20) unsigned DEFAULT NULL,
  `resources_used_gpus` int(10) unsigned NOT NULL DEFAULT 0,
  `resource_list_nodes` text DEFAULT NULL,
  `resource_list_procs` text DEFAULT NULL,
  `resource_list_neednodes` text DEFAULT NULL,
  `resource_list_pcput` bigint(20) unsigned DEFAULT NULL,
  `resource_list_cput` bigint(20) unsigned DEFAULT NULL,
  `resource_list_walltime` bigint(20) unsigned DEFAULT NULL,
  `resource_list_ncpus` int(10) unsigned DEFAULT NULL,
  `resource_list_nodect` int(10) unsigned DEFAULT NULL,
  `resource_list_mem` bigint(20) unsigned DEFAULT NULL,
  `resource_list_pmem` bigint(20) unsigned DEFAULT NULL,
  `node_list` mediumtext NOT NULL,
  PRIMARY KEY (`shredded_job_pbs_id`),
  UNIQUE KEY `job` (`host`,`job_id`,`job_array_index`,`ctime`,`end`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shredded_job_sge`
--

DROP TABLE IF EXISTS `shredded_job_sge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shredded_job_sge` (
  `shredded_job_sge_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `clustername` varchar(255) DEFAULT NULL,
  `qname` varchar(255) DEFAULT NULL,
  `hostname` varchar(255) NOT NULL,
  `groupname` varchar(255) DEFAULT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `job_name` varchar(255) DEFAULT NULL,
  `job_number` int(10) unsigned NOT NULL,
  `account` varchar(255) DEFAULT NULL,
  `priority` tinyint(4) DEFAULT NULL,
  `submission_time` int(11) unsigned DEFAULT NULL,
  `start_time` int(11) unsigned DEFAULT NULL,
  `end_time` int(11) unsigned DEFAULT NULL,
  `failed` int(11) DEFAULT NULL,
  `exit_status` int(11) DEFAULT NULL,
  `ru_wallclock` int(11) DEFAULT NULL,
  `ru_utime` decimal(32,6) DEFAULT NULL,
  `ru_stime` decimal(32,6) DEFAULT NULL,
  `ru_maxrss` int(11) DEFAULT NULL,
  `ru_ixrss` int(11) DEFAULT NULL,
  `ru_ismrss` int(11) DEFAULT NULL,
  `ru_idrss` int(11) DEFAULT NULL,
  `ru_isrss` int(11) DEFAULT NULL,
  `ru_minflt` int(11) DEFAULT NULL,
  `ru_majflt` int(11) DEFAULT NULL,
  `ru_nswap` int(11) DEFAULT NULL,
  `ru_inblock` int(11) DEFAULT NULL,
  `ru_oublock` int(11) DEFAULT NULL,
  `ru_msgsnd` int(11) DEFAULT NULL,
  `ru_msgrcv` int(11) DEFAULT NULL,
  `ru_nsignals` int(11) DEFAULT NULL,
  `ru_nvcsw` int(11) DEFAULT NULL,
  `ru_nivcsw` int(11) DEFAULT NULL,
  `project` varchar(255) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  `granted_pe` varchar(255) DEFAULT NULL,
  `slots` int(11) DEFAULT NULL,
  `task_number` int(11) DEFAULT NULL,
  `cpu` decimal(32,6) DEFAULT NULL,
  `mem` decimal(32,6) DEFAULT NULL,
  `io` decimal(32,6) DEFAULT NULL,
  `category` text DEFAULT NULL,
  `iow` decimal(32,6) DEFAULT NULL,
  `pe_taskid` int(11) DEFAULT NULL,
  `maxvmem` bigint(20) DEFAULT NULL,
  `arid` int(11) DEFAULT NULL,
  `ar_submission_time` int(11) unsigned DEFAULT NULL,
  `resource_list_arch` varchar(255) DEFAULT NULL,
  `resource_list_qname` varchar(255) DEFAULT NULL,
  `resource_list_hostname` varchar(255) DEFAULT NULL,
  `resource_list_notify` int(11) DEFAULT NULL,
  `resource_list_calendar` varchar(255) DEFAULT NULL,
  `resource_list_min_cpu_interval` int(11) DEFAULT NULL,
  `resource_list_tmpdir` varchar(255) DEFAULT NULL,
  `resource_list_seq_no` int(11) DEFAULT NULL,
  `resource_list_s_rt` bigint(20) DEFAULT NULL,
  `resource_list_h_rt` bigint(20) DEFAULT NULL,
  `resource_list_s_cpu` bigint(20) DEFAULT NULL,
  `resource_list_h_cpu` bigint(20) DEFAULT NULL,
  `resource_list_s_data` bigint(20) DEFAULT NULL,
  `resource_list_h_data` bigint(20) DEFAULT NULL,
  `resource_list_s_stack` bigint(20) DEFAULT NULL,
  `resource_list_h_stack` bigint(20) DEFAULT NULL,
  `resource_list_s_core` bigint(20) DEFAULT NULL,
  `resource_list_h_core` bigint(20) DEFAULT NULL,
  `resource_list_s_rss` bigint(20) DEFAULT NULL,
  `resource_list_h_rss` bigint(20) DEFAULT NULL,
  `resource_list_slots` varchar(255) DEFAULT NULL,
  `resource_list_s_vmem` bigint(20) DEFAULT NULL,
  `resource_list_h_vmem` bigint(20) DEFAULT NULL,
  `resource_list_s_fsize` bigint(20) DEFAULT NULL,
  `resource_list_h_fsize` bigint(20) DEFAULT NULL,
  `resource_list_num_proc` int(11) DEFAULT NULL,
  `resource_list_mem_free` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`shredded_job_sge_id`),
  UNIQUE KEY `job` (`hostname`,`job_number`,`task_number`,`failed`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shredded_job_slurm`
--

DROP TABLE IF EXISTS `shredded_job_slurm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shredded_job_slurm` (
  `shredded_job_slurm_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `job_id` int(10) unsigned NOT NULL,
  `job_array_index` int(10) NOT NULL DEFAULT -1,
  `job_id_raw` int(10) unsigned DEFAULT NULL,
  `job_name` tinytext NOT NULL,
  `cluster_name` tinytext NOT NULL,
  `partition_name` tinytext NOT NULL,
  `qos_name` tinytext DEFAULT NULL,
  `user_name` tinytext NOT NULL,
  `uid_number` int(10) unsigned DEFAULT NULL,
  `group_name` tinytext NOT NULL,
  `gid_number` int(10) unsigned DEFAULT NULL,
  `account_name` tinytext NOT NULL,
  `submit_time` int(10) unsigned NOT NULL,
  `eligible_time` int(10) unsigned DEFAULT NULL,
  `start_time` int(10) unsigned NOT NULL,
  `end_time` int(10) unsigned NOT NULL,
  `elapsed` int(10) unsigned NOT NULL,
  `exit_code` varchar(32) NOT NULL,
  `state` varchar(32) DEFAULT NULL,
  `nnodes` int(10) unsigned NOT NULL,
  `ncpus` int(10) unsigned NOT NULL,
  `ngpus` int(10) unsigned NOT NULL DEFAULT 0,
  `req_cpus` int(10) unsigned DEFAULT NULL,
  `req_mem` varchar(32) DEFAULT NULL,
  `req_tres` text NOT NULL,
  `alloc_tres` text NOT NULL,
  `timelimit` int(10) unsigned DEFAULT NULL,
  `node_list` mediumtext NOT NULL,
  PRIMARY KEY (`shredded_job_slurm_id`),
  UNIQUE KEY `job` (`cluster_name`(20),`job_id`,`job_array_index`,`submit_time`,`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_job`
--

DROP TABLE IF EXISTS `staging_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(10) unsigned NOT NULL,
  `job_array_index` int(10) unsigned DEFAULT NULL,
  `job_id_raw` int(10) unsigned DEFAULT NULL,
  `job_name` varchar(255) DEFAULT NULL,
  `resource_name` varchar(255) NOT NULL,
  `queue_name` varchar(255) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `uid_number` int(10) unsigned DEFAULT NULL,
  `group_name` varchar(255) NOT NULL,
  `gid_number` int(10) unsigned DEFAULT NULL,
  `qos_name` varchar(255) DEFAULT NULL,
  `account_name` varchar(255) DEFAULT NULL,
  `project_name` varchar(255) DEFAULT NULL,
  `pi_name` varchar(255) NOT NULL,
  `start_time` int(10) unsigned NOT NULL,
  `end_time` int(10) unsigned NOT NULL,
  `submission_time` int(10) unsigned NOT NULL,
  `eligible_time` int(10) unsigned DEFAULT NULL,
  `wall_time` bigint(20) unsigned NOT NULL,
  `wait_time` bigint(20) unsigned NOT NULL,
  `exit_code` varchar(32) DEFAULT NULL,
  `exit_state` varchar(32) DEFAULT NULL,
  `node_count` int(10) unsigned NOT NULL,
  `cpu_count` int(10) unsigned NOT NULL,
  `gpu_count` int(10) unsigned NOT NULL DEFAULT 0,
  `cpu_req` int(10) unsigned DEFAULT NULL,
  `mem_req` varchar(32) DEFAULT NULL,
  `timelimit` int(10) unsigned DEFAULT NULL,
  `node_list` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_organization`
--

DROP TABLE IF EXISTS `staging_organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_organization` (
  `organization_id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_name` varchar(300) NOT NULL COMMENT 'Organization full name',
  `organization_abbrev` varchar(100) NOT NULL COMMENT 'Organization abbreviation',
  PRIMARY KEY (`organization_name`,`organization_abbrev`),
  UNIQUE KEY `uk_organization_id` (`organization_id`),
  UNIQUE KEY `uk_organization_name` (`organization_name`),
  UNIQUE KEY `uk_organization_abbrev` (`organization_abbrev`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COMMENT='Staging table for organizations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_pi`
--

DROP TABLE IF EXISTS `staging_pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_pi` (
  `pi_id` int(11) NOT NULL AUTO_INCREMENT,
  `pi_name` varchar(255) NOT NULL COMMENT 'PI username',
  PRIMARY KEY (`pi_name`),
  UNIQUE KEY `uk_pi_id` (`pi_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Staging table for PI usernames';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_pi_resource`
--

DROP TABLE IF EXISTS `staging_pi_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_pi_resource` (
  `pi_resource_id` int(11) NOT NULL AUTO_INCREMENT,
  `pi_name` varchar(255) NOT NULL COMMENT 'PI username',
  `resource_name` varchar(255) NOT NULL COMMENT 'Resource name',
  PRIMARY KEY (`pi_name`,`resource_name`),
  UNIQUE KEY `uk_pi_resource_id` (`pi_resource_id`),
  KEY `idx_resource_name` (`resource_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Staging table for all PI and resource combinations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_qos`
--

DROP TABLE IF EXISTS `staging_qos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_qos` (
  `qos_id` int(11) NOT NULL AUTO_INCREMENT,
  `qos_name` varchar(255) NOT NULL COMMENT 'QOS name',
  PRIMARY KEY (`qos_name`),
  UNIQUE KEY `uk_qos_id` (`qos_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Staging table for quality of service';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_resource`
--

DROP TABLE IF EXISTS `staging_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_resource` (
  `resource_id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_name` varchar(255) NOT NULL COMMENT 'Resource username',
  PRIMARY KEY (`resource_name`),
  UNIQUE KEY `uk_resource_id` (`resource_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1 COMMENT='Staging table for resources';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_resource_config`
--

DROP TABLE IF EXISTS `staging_resource_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_resource_config` (
  `resource_id` int(11) NOT NULL AUTO_INCREMENT,
  `resource` varchar(64) NOT NULL COMMENT 'Resource name or abbreviation',
  `name` varchar(200) NOT NULL COMMENT 'Formal name of the resource',
  `description` varchar(1000) DEFAULT NULL COMMENT 'Description of the resource',
  `shared_jobs` tinyint(1) DEFAULT NULL COMMENT 'True if jobs may share nodes on this resource',
  `timezone` varchar(30) DEFAULT NULL COMMENT 'Timezone where this resource is located',
  `type_abbrev` varchar(30) DEFAULT NULL COMMENT 'Resource type Abbreviation',
  PRIMARY KEY (`resource`),
  UNIQUE KEY `uk_resource_id` (`resource_id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COMMENT='Staging table for resource configurations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_resource_spec`
--

DROP TABLE IF EXISTS `staging_resource_spec`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_resource_spec` (
  `resource_spec_id` int(11) NOT NULL AUTO_INCREMENT,
  `resource` varchar(64) NOT NULL COMMENT 'Resource name/code',
  `start_date` date DEFAULT NULL COMMENT 'Resource specifications start date',
  `end_date` date DEFAULT NULL COMMENT 'Resource specifications end date',
  `nodes` int(10) unsigned NOT NULL COMMENT 'Number of nodes in resource',
  `processors` int(10) unsigned NOT NULL COMMENT 'Number of processors/cores in resource',
  `ppn` int(10) unsigned DEFAULT NULL COMMENT 'Number of processors per node in resource',
  `percent_allocated` int(10) unsigned DEFAULT NULL COMMENT 'Percentage of resource to include in utilization metric calculation',
  `comments` varchar(500) DEFAULT NULL COMMENT 'Comments explaining specifications',
  PRIMARY KEY (`resource_spec_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COMMENT='Staging table for resource specifications';
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1 COMMENT='Staging table for resource types';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_resource_type_realms`
--

DROP TABLE IF EXISTS `staging_resource_type_realms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_resource_type_realms` (
  `staging_resource_type_realm_id` int(11) NOT NULL AUTO_INCREMENT,
  `abbrev` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `realm` varchar(16) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`staging_resource_type_realm_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_storage_mountpoint`
--

DROP TABLE IF EXISTS `staging_storage_mountpoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_storage_mountpoint` (
  `mountpoint_id` int(11) NOT NULL AUTO_INCREMENT,
  `path` varchar(255) NOT NULL COMMENT 'Mountpoint directory path',
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`path`),
  UNIQUE KEY `uk_mountpoint_id` (`mountpoint_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Storage file system mountpoint';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_storage_usage`
--

DROP TABLE IF EXISTS `staging_storage_usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_storage_usage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_name` varchar(200) NOT NULL COMMENT 'Resource name',
  `mountpoint_name` varchar(255) NOT NULL COMMENT 'File system mountpoint',
  `user_name` varchar(255) NOT NULL COMMENT 'User''s system username',
  `pi_name` varchar(255) NOT NULL COMMENT 'PI''s system username',
  `dt` varchar(25) NOT NULL COMMENT 'Date and time usage data was collected',
  `file_count` bigint(20) unsigned NOT NULL COMMENT 'File count',
  `logical_usage` bigint(20) unsigned NOT NULL COMMENT 'Logical file system usage in bytes',
  `physical_usage` bigint(20) unsigned DEFAULT NULL COMMENT 'Physical file system usage in bytes',
  `soft_threshold` bigint(20) unsigned DEFAULT NULL COMMENT 'Soft threshold in bytes',
  `hard_threshold` bigint(20) unsigned DEFAULT NULL COMMENT 'Hard threshold in bytes',
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_usage` (`resource_name`,`mountpoint_name`,`user_name`,`pi_name`,`dt`),
  KEY `idx_mountpoint_name` (`mountpoint_name`),
  KEY `idx_user_name` (`user_name`),
  KEY `idx_pi_name` (`pi_name`),
  KEY `idx_dt` (`dt`),
  KEY `idx_resource_name_pi_name_user_name` (`resource_name`,`pi_name`,`user_name`),
  KEY `idx_resource_name_user_name` (`resource_name`,`user_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Storage usage data';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_union_user_pi`
--

DROP TABLE IF EXISTS `staging_union_user_pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_union_user_pi` (
  `union_user_pi_id` int(11) NOT NULL AUTO_INCREMENT,
  `union_user_pi_name` varchar(255) NOT NULL COMMENT 'User or PI username',
  PRIMARY KEY (`union_user_pi_name`),
  UNIQUE KEY `uk_union_user_pi_id` (`union_user_pi_id`)
) ENGINE=InnoDB AUTO_INCREMENT=257 DEFAULT CHARSET=latin1 COMMENT='Staging table for the union of all User and PI usernames';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_union_user_pi_resource`
--

DROP TABLE IF EXISTS `staging_union_user_pi_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_union_user_pi_resource` (
  `union_user_pi_resource_id` int(11) NOT NULL AUTO_INCREMENT,
  `union_user_pi_name` varchar(255) NOT NULL COMMENT 'User or PI username',
  `resource_name` varchar(255) NOT NULL COMMENT 'Resource name',
  PRIMARY KEY (`union_user_pi_name`,`resource_name`),
  UNIQUE KEY `uk_union_user_pi_resource_id` (`union_user_pi_resource_id`),
  KEY `idx_resource_name` (`resource_name`)
) ENGINE=InnoDB AUTO_INCREMENT=257 DEFAULT CHARSET=latin1 COMMENT='Staging table for all User or PI and resource combinations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staging_user_pi_resource`
--

DROP TABLE IF EXISTS `staging_user_pi_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staging_user_pi_resource` (
  `user_pi_resource_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(255) NOT NULL COMMENT 'User username',
  `pi_name` varchar(255) NOT NULL COMMENT 'PI username',
  `resource_name` varchar(255) NOT NULL COMMENT 'Resource name',
  PRIMARY KEY (`user_name`,`pi_name`,`resource_name`),
  UNIQUE KEY `uk_user_pi_resource_id` (`user_pi_resource_id`),
  KEY `idx_pi_name` (`pi_name`),
  KEY `idx_resource_name` (`resource_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Staging table for all user, PI and resource combinations';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-09-14 21:36:57
