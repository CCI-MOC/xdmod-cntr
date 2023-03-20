-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: mariadb    Database: moddb
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
-- Table structure for table `APIKeys`
--

DROP TABLE IF EXISTS `APIKeys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `APIKeys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `api_key` varchar(16) DEFAULT NULL,
  `public_key` text DEFAULT NULL,
  `identifier` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `AccountRequests`
--

DROP TABLE IF EXISTS `AccountRequests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `AccountRequests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` text DEFAULT NULL,
  `last_name` text DEFAULT NULL,
  `organization` text DEFAULT NULL,
  `title` text DEFAULT NULL,
  `email_address` text DEFAULT NULL,
  `field_of_science` text DEFAULT NULL,
  `additional_information` text DEFAULT NULL,
  `time_submitted` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `status` varchar(100) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ChartPool`
--

DROP TABLE IF EXISTS `ChartPool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ChartPool` (
  `user_id` int(11) DEFAULT NULL,
  `chart_id` text DEFAULT NULL,
  `insertion_rank` int(11) NOT NULL AUTO_INCREMENT,
  `chart_title` text DEFAULT NULL,
  `chart_drill_details` text NOT NULL,
  `chart_date_description` text DEFAULT NULL,
  `type` enum('image','datasheet') DEFAULT NULL,
  `active_role` varchar(30) DEFAULT NULL,
  `image_data` longblob DEFAULT NULL,
  PRIMARY KEY (`insertion_rank`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Colors`
--

DROP TABLE IF EXISTS `Colors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Colors` (
  `color` char(8) NOT NULL,
  `description` varchar(45) DEFAULT NULL,
  `order` int(11) DEFAULT NULL,
  PRIMARY KEY (`color`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ExceptionEmailAddresses`
--

DROP TABLE IF EXISTS `ExceptionEmailAddresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ExceptionEmailAddresses` (
  `email_address` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RESTx509`
--

DROP TABLE IF EXISTS `RESTx509`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RESTx509` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `distinguished_name` text DEFAULT NULL,
  `api_key` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `time_cert_signed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ReportCharts`
--

DROP TABLE IF EXISTS `ReportCharts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ReportCharts` (
  `report_id` varchar(100) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `chart_type` text DEFAULT NULL,
  `type` enum('image','datasheet') DEFAULT NULL,
  `selected` tinyint(1) DEFAULT 0,
  `chart_id` text DEFAULT NULL,
  `ordering` int(11) NOT NULL DEFAULT 0,
  `chart_date_description` text DEFAULT NULL,
  `chart_title` varchar(100) DEFAULT NULL,
  `chart_drill_details` text NOT NULL,
  `timeframe_type` text DEFAULT NULL,
  `image_data` longblob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ReportTemplateCharts`
--

DROP TABLE IF EXISTS `ReportTemplateCharts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ReportTemplateCharts` (
  `template_id` int(11) DEFAULT NULL,
  `chart_id` text DEFAULT NULL,
  `ordering` int(11) DEFAULT NULL,
  `chart_date_description` text DEFAULT NULL,
  `chart_title` varchar(100) DEFAULT NULL,
  `chart_drill_details` text DEFAULT NULL,
  `timeframe_type` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ReportTemplates`
--

DROP TABLE IF EXISTS `ReportTemplates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ReportTemplates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(1000) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `template` varchar(30) DEFAULT NULL,
  `title` varchar(1000) DEFAULT NULL,
  `header` varchar(1000) DEFAULT NULL,
  `footer` varchar(1000) DEFAULT NULL,
  `format` enum('Pdf','Pptx','Doc','Xls','Html') DEFAULT NULL,
  `schedule` enum('Once','Daily','Weekly','Monthly','Quarterly','Semi-annually','Annually') DEFAULT NULL,
  `delivery` enum('Download','E-mail') DEFAULT NULL,
  `charts_per_page` int(1) DEFAULT NULL,
  `use_submenu` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Reports`
--

DROP TABLE IF EXISTS `Reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Reports` (
  `report_id` varchar(100) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(1000) DEFAULT 'TAS Report',
  `derived_from` varchar(1000) DEFAULT NULL,
  `title` varchar(1000) DEFAULT 'TAS Report',
  `header` varchar(1000) DEFAULT NULL,
  `footer` varchar(1000) DEFAULT NULL,
  `format` enum('Pdf','Pptx','Doc','Xls','Html') NOT NULL DEFAULT 'Pdf',
  `schedule` enum('Once','Daily','Weekly','Monthly','Quarterly','Semi-annually','Annually') NOT NULL DEFAULT 'Once',
  `delivery` enum('Download','E-mail') NOT NULL DEFAULT 'E-mail',
  `selected` tinyint(1) NOT NULL DEFAULT 0,
  `charts_per_page` int(1) DEFAULT NULL,
  `active_role` varchar(30) DEFAULT NULL,
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SessionManager`
--

DROP TABLE IF EXISTS `SessionManager`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SessionManager` (
  `session_token` varchar(40) NOT NULL,
  `session_id` text NOT NULL,
  `user_id` int(11) unsigned NOT NULL,
  `ip_address` varchar(40) NOT NULL,
  `user_agent` varchar(255) NOT NULL,
  `init_time` varchar(100) NOT NULL,
  `last_active` varchar(100) NOT NULL,
  `used_logout` tinyint(1) unsigned DEFAULT NULL,
  PRIMARY KEY (`session_token`) USING BTREE,
  KEY `idx_user_id` (`user_id`),
  KEY `idx_init_time` (`init_time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `UserProfiles`
--

DROP TABLE IF EXISTS `UserProfiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserProfiles` (
  `user_id` int(11) NOT NULL DEFAULT 0,
  `serialized_profile_data` longblob DEFAULT NULL,
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `UserTypes`
--

DROP TABLE IF EXISTS `UserTypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserTypes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) DEFAULT NULL,
  `color` char(7) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(200) NOT NULL DEFAULT '',
  `password` varchar(255) DEFAULT NULL,
  `email_address` varchar(200) DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `middle_name` varchar(50) DEFAULT '',
  `last_name` varchar(50) DEFAULT NULL,
  `time_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `time_last_updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `password_last_updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `account_is_active` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `person_id` int(11) DEFAULT NULL COMMENT 'references TGcDB.people.person_id',
  `organization_id` int(11) DEFAULT NULL COMMENT 'references TGcDB.organizations.organization_id',
  `field_of_science` int(11) DEFAULT NULL,
  `token` varchar(32) DEFAULT NULL,
  `token_expiration` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `user_type` int(11) NOT NULL,
  `sticky` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Set when an admin manually updates the [person|organization]_id. Indicates that further modification must be made manually by an admin.',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uniq_username` (`username`) USING BTREE,
  KEY `person_id_idx` (`person_id`) USING BTREE,
  KEY `idx_user_type` (`user_type`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`xdmod`@`%`*/ /*!50003 TRIGGER `moddb`.`users_insert_timestamp` BEFORE INSERT ON `moddb`.`Users` FOR EACH ROW
 BEGIN


	SET NEW.time_created = NOW();

	SET NEW.time_last_updated = NOW();


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`xdmod`@`%`*/ /*!50003 TRIGGER `moddb`.`users_update_timestamp` BEFORE UPDATE ON `moddb`.`Users` FOR EACH ROW
 BEGIN


	IF NEW.password <> OLD.password THEN

		SET NEW.password_last_updated = NOW();

	END IF;

	SET NEW.time_last_updated = NOW();


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `VersionCheck`
--

DROP TABLE IF EXISTS `VersionCheck`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `VersionCheck` (
  `entry_date` datetime NOT NULL,
  `ip_address` varchar(15) NOT NULL,
  `name` varchar(255) DEFAULT NULL COMMENT 'Log of xdmod version checks',
  `email` varchar(255) DEFAULT NULL,
  `organization` varchar(255) DEFAULT NULL,
  `current_version` varchar(16) DEFAULT NULL,
  `all_params` text DEFAULT NULL,
  KEY `entry_date` (`entry_date`) USING BTREE,
  KEY `ip` (`ip_address`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acl_dimensions`
--

DROP TABLE IF EXISTS `acl_dimensions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acl_dimensions` (
  `acl_dimension_id` int(11) NOT NULL AUTO_INCREMENT,
  `acl_id` int(11) NOT NULL,
  `group_by_id` int(11) NOT NULL COMMENT 'The group_by that this acl uses to filter query data.',
  PRIMARY KEY (`acl_dimension_id`) USING BTREE,
  KEY `idx_acl_id` (`acl_id`) USING BTREE,
  KEY `idx_group_by_id` (`group_by_id`) USING BTREE,
  CONSTRAINT `fk_ad_acl_id` FOREIGN KEY (`acl_id`) REFERENCES `acls` (`acl_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ad_gb_id` FOREIGN KEY (`group_by_id`) REFERENCES `group_bys` (`group_by_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1 COMMENT='Tracks which dimension(s) are used by an acl to filter query data.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acl_group_bys`
--

DROP TABLE IF EXISTS `acl_group_bys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acl_group_bys` (
  `acl_group_by_id` int(11) NOT NULL AUTO_INCREMENT,
  `acl_id` int(11) NOT NULL,
  `group_by_id` int(11) NOT NULL,
  `realm_id` int(11) NOT NULL,
  `statistic_id` int(11) NOT NULL,
  `visible` tinyint(1) NOT NULL DEFAULT 1,
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`acl_group_by_id`) USING BTREE,
  UNIQUE KEY `uniq_acl_group_by_realm_statistic` (`acl_id`,`group_by_id`,`realm_id`,`statistic_id`) USING BTREE,
  KEY `idx_acl_id` (`acl_id`),
  KEY `idx_group_by_id` (`group_by_id`),
  KEY `idx_realm_id` (`realm_id`),
  KEY `idx_statistic_id` (`statistic_id`),
  CONSTRAINT `fk_agb_acl_id` FOREIGN KEY (`acl_id`) REFERENCES `acls` (`acl_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_agb_group_by_id` FOREIGN KEY (`group_by_id`) REFERENCES `group_bys` (`group_by_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_agb_realm_id` FOREIGN KEY (`realm_id`) REFERENCES `realms` (`realm_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_agb_statistic_id` FOREIGN KEY (`statistic_id`) REFERENCES `statistics` (`statistic_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4745 DEFAULT CHARSET=latin1 COMMENT='Tracks which `acls` have a relation to which `group_bys` ( what is known in the code base as a `QueryDescripter` ).';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acl_hierarchies`
--

DROP TABLE IF EXISTS `acl_hierarchies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acl_hierarchies` (
  `acl_hierarchy_id` int(11) NOT NULL AUTO_INCREMENT,
  `acl_id` int(11) NOT NULL,
  `hierarchy_id` int(11) NOT NULL,
  `level` int(11) NOT NULL DEFAULT 0,
  `filter_override` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`acl_hierarchy_id`) USING BTREE,
  KEY `idx_aclid_hierarchyid` (`acl_id`,`hierarchy_id`) USING BTREE,
  KEY `idx_hierarchy_id` (`hierarchy_id`),
  CONSTRAINT `fk_ah_acl_id` FOREIGN KEY (`acl_id`) REFERENCES `acls` (`acl_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ah_hierarchy_id` FOREIGN KEY (`hierarchy_id`) REFERENCES `hierarchies` (`hierarchy_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COMMENT='Tracks which `acls` have a relationship with which `hierarchies`';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acl_tabs`
--

DROP TABLE IF EXISTS `acl_tabs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acl_tabs` (
  `acl_tab_id` int(11) NOT NULL AUTO_INCREMENT,
  `acl_id` int(11) NOT NULL,
  `tab_id` int(11) NOT NULL,
  `parent_acl_tab_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`acl_tab_id`) USING BTREE,
  KEY `idx_acl_tab` (`acl_id`,`tab_id`),
  KEY `idx_tab_id` (`tab_id`),
  CONSTRAINT `fk_at_acl_id` FOREIGN KEY (`acl_id`) REFERENCES `acls` (`acl_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_at_tab_id` FOREIGN KEY (`tab_id`) REFERENCES `tabs` (`tab_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=latin1 COMMENT='Tracks which `acls` have a relationship with which `tabs`';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acl_types`
--

DROP TABLE IF EXISTS `acl_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acl_types` (
  `acl_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `display` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`acl_type_id`) USING BTREE,
  KEY `idx_module_id` (`module_id`),
  CONSTRAINT `fk_atp_module_id` FOREIGN KEY (`module_id`) REFERENCES `modules` (`module_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='Tracks types that pertain only to acls';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acls`
--

DROP TABLE IF EXISTS `acls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acls` (
  `acl_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `acl_type_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `display` varchar(1024) DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`acl_id`) USING BTREE,
  UNIQUE KEY `idx_module_id_name` (`module_id`,`name`) USING BTREE,
  KEY `idx_type_id` (`acl_type_id`),
  CONSTRAINT `fk_a_acl_type_id` FOREIGN KEY (`acl_type_id`) REFERENCES `acl_types` (`acl_type_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_a_module_id` FOREIGN KEY (`module_id`) REFERENCES `modules` (`module_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COMMENT='Tracks the currently defined `acls`';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `batch_export_requests`
--

DROP TABLE IF EXISTS `batch_export_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `batch_export_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'References the user that requested the export.',
  `realm` varchar(255) NOT NULL COMMENT 'The realm from which data will be exported.',
  `start_date` date NOT NULL COMMENT 'Start date for the date range of the data that will be exported.',
  `end_date` date NOT NULL COMMENT 'End date for the date range of the data that will be exported.',
  `export_file_format` enum('CSV','JSON') NOT NULL COMMENT 'File format that will be used to store the exported data.',
  `requested_datetime` datetime NOT NULL COMMENT 'Date and time the export request was created.',
  `export_succeeded` tinyint(1) DEFAULT NULL COMMENT 'True if the export was a success, false if not, null if the request has not yet been processed.',
  `export_created_datetime` datetime DEFAULT NULL COMMENT 'Date and time the export data was generated.',
  `downloaded_datetime` datetime DEFAULT NULL COMMENT 'Date and time of the first download of the exported data.',
  `export_expires_datetime` datetime DEFAULT NULL COMMENT 'Date and time the export data will expire.',
  `export_expired` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'True if the export has expired, false if not.',
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'True if the export has been deleted',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_requested_datetime` (`requested_datetime`),
  KEY `idx_state` (`is_deleted`,`export_succeeded`,`export_expired`,`export_created_datetime`),
  CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Data warehouse batch export requests.';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`xdmod`@`%`*/ /*!50003 TRIGGER `moddb`.`batch_export_requests_before_insert` BEFORE INSERT ON `moddb`.`batch_export_requests` FOR EACH ROW
 BEGIN
SET NEW.requested_datetime = NOW();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `group_bys`
--

DROP TABLE IF EXISTS `group_bys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_bys` (
  `group_by_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `realm_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`group_by_id`) USING BTREE,
  UNIQUE KEY `idx_module_id_realm_id_name` (`module_id`,`realm_id`,`name`) USING BTREE,
  KEY `idx_module_id` (`module_id`),
  KEY `idx_realm_id` (`realm_id`),
  CONSTRAINT `fk_gb_module_id` FOREIGN KEY (`module_id`) REFERENCES `modules` (`module_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_gb_realm_id` FOREIGN KEY (`realm_id`) REFERENCES `realms` (`realm_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1 COMMENT='Tracks which `group_bys` are available to the system';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hierarchies`
--

DROP TABLE IF EXISTS `hierarchies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchies` (
  `hierarchy_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `display` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`hierarchy_id`) USING BTREE,
  KEY `idx_module_id` (`module_id`),
  CONSTRAINT `fk_h_module_id` FOREIGN KEY (`module_id`) REFERENCES `modules` (`module_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COMMENT='Tracks the module installed `hierarchies`.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `module_versions`
--

DROP TABLE IF EXISTS `module_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `module_versions` (
  `module_version_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `version_major` int(11) NOT NULL DEFAULT 0,
  `version_minor` int(11) NOT NULL DEFAULT 0,
  `version_patch` int(11) NOT NULL DEFAULT 1,
  `version_pre_release` varchar(12) NOT NULL DEFAULT '',
  `created_on` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `last_modified_on` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`module_version_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COMMENT='Tracks per module versions.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `modules`
--

DROP TABLE IF EXISTS `modules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `modules` (
  `module_id` int(11) NOT NULL AUTO_INCREMENT,
  `current_version_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `display` varchar(1024) DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL,
  PRIMARY KEY (`module_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COMMENT='Currently installed modules';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `realms`
--

DROP TABLE IF EXISTS `realms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `realms` (
  `realm_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `display` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`realm_id`) USING BTREE,
  UNIQUE KEY `idx_module_id_name` (`module_id`,`name`) USING BTREE,
  KEY `fk_r_module_id` (`module_id`),
  CONSTRAINT `fk_r_module_id` FOREIGN KEY (`module_id`) REFERENCES `modules` (`module_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COMMENT='Tracks which `realms` are available to the system';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_template_acls`
--

DROP TABLE IF EXISTS `report_template_acls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_template_acls` (
  `report_template_acl_id` int(11) NOT NULL AUTO_INCREMENT,
  `report_template_id` int(11) NOT NULL,
  `acl_id` int(11) NOT NULL,
  UNIQUE KEY `idx_report_template_acl_id` (`report_template_acl_id`) USING BTREE,
  KEY `idx_report_template_id` (`report_template_id`),
  KEY `idx_acl_id` (`acl_id`),
  CONSTRAINT `fk_rta_acl_id` FOREIGN KEY (`acl_id`) REFERENCES `acls` (`acl_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COMMENT='Tracks which acls have access to which report templates.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_template_acls_staging`
--

DROP TABLE IF EXISTS `report_template_acls_staging`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_template_acls_staging` (
  `template_id` int(11) DEFAULT NULL,
  `acl_name` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resource_type_realms`
--

DROP TABLE IF EXISTS `resource_type_realms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_type_realms` (
  `resource_type_realm_id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_type_id` int(11) NOT NULL,
  `realm_id` int(11) NOT NULL,
  PRIMARY KEY (`resource_type_realm_id`),
  KEY `idx_resource_type_id_realm_name` (`resource_type_id`,`realm_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `statistics`
--

DROP TABLE IF EXISTS `statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `statistics` (
  `statistic_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `realm_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`statistic_id`) USING BTREE,
  UNIQUE KEY `idx_module_id_realm_id_name` (`module_id`,`realm_id`,`name`) USING BTREE,
  KEY `idx_module_id` (`module_id`),
  KEY `idx_realm_id` (`realm_id`),
  CONSTRAINT `fk_s_module_id` FOREIGN KEY (`module_id`) REFERENCES `modules` (`module_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_s_realm_id` FOREIGN KEY (`realm_id`) REFERENCES `realms` (`realm_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=latin1 COMMENT='Tracks all of the `statistics` currently available to the system';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tabs`
--

DROP TABLE IF EXISTS `tabs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tabs` (
  `tab_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `parent_tab_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`tab_id`) USING BTREE,
  KEY `idx_module_id` (`module_id`),
  KEY `idx_parent_tab_id` (`parent_tab_id`),
  CONSTRAINT `fk_t_module_id` FOREIGN KEY (`module_id`) REFERENCES `modules` (`module_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_t_parent_tab_id` FOREIGN KEY (`parent_tab_id`) REFERENCES `tabs` (`tab_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COMMENT='Tracks which `tabs` are available to the system';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_acl_group_by_parameters`
--

DROP TABLE IF EXISTS `user_acl_group_by_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_acl_group_by_parameters` (
  `user_acl_parameter_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `acl_id` int(11) DEFAULT NULL,
  `group_by_id` int(11) DEFAULT NULL,
  `value` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_acl_parameter_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`),
  KEY `idx_acl_id` (`acl_id`),
  KEY `idx_group_by_id` (`group_by_id`),
  CONSTRAINT `fk_uagbp_acl_id` FOREIGN KEY (`acl_id`) REFERENCES `acls` (`acl_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_uagbp_group_by_id` FOREIGN KEY (`group_by_id`) REFERENCES `group_bys` (`group_by_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_uagbp_user_id` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COMMENT='Tracks which `Users` have which `acls`';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_acls`
--

DROP TABLE IF EXISTS `user_acls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_acls` (
  `user_acl_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `acl_id` int(11) NOT NULL,
  PRIMARY KEY (`user_acl_id`) USING BTREE,
  UNIQUE KEY `idx_user_id_acl_id` (`user_id`,`acl_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`),
  KEY `idx_acl_id` (`acl_id`),
  CONSTRAINT `fk_ua_acl_id` FOREIGN KEY (`acl_id`) REFERENCES `acls` (`acl_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ua_user_id` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COMMENT='Tracks which `Users` have which `acls`';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-09-14 21:37:16
