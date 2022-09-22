-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: mariadb    Database: modw_filters
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
-- Table structure for table `Cloud_configuration`
--

DROP TABLE IF EXISTS `Cloud_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_configuration` (
  `configuration` varchar(256) NOT NULL,
  PRIMARY KEY (`configuration`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_configuration___person`
--

DROP TABLE IF EXISTS `Cloud_configuration___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_configuration___person` (
  `configuration` varchar(256) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`configuration`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_configuration___pi`
--

DROP TABLE IF EXISTS `Cloud_configuration___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_configuration___pi` (
  `configuration` varchar(256) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`configuration`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_configuration___provider`
--

DROP TABLE IF EXISTS `Cloud_configuration___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_configuration___provider` (
  `configuration` varchar(256) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`configuration`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_domain`
--

DROP TABLE IF EXISTS `Cloud_domain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_domain` (
  `domain` varchar(64) NOT NULL,
  PRIMARY KEY (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_domain___person`
--

DROP TABLE IF EXISTS `Cloud_domain___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_domain___person` (
  `domain` varchar(64) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`domain`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_domain___pi`
--

DROP TABLE IF EXISTS `Cloud_domain___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_domain___pi` (
  `domain` varchar(64) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`domain`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_domain___provider`
--

DROP TABLE IF EXISTS `Cloud_domain___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_domain___provider` (
  `domain` varchar(64) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`domain`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_fieldofscience`
--

DROP TABLE IF EXISTS `Cloud_fieldofscience`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_fieldofscience` (
  `fieldofscience` int(11) NOT NULL,
  PRIMARY KEY (`fieldofscience`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_fieldofscience___person`
--

DROP TABLE IF EXISTS `Cloud_fieldofscience___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_fieldofscience___person` (
  `fieldofscience` int(11) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`fieldofscience`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_fieldofscience___pi`
--

DROP TABLE IF EXISTS `Cloud_fieldofscience___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_fieldofscience___pi` (
  `fieldofscience` int(11) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`fieldofscience`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_fieldofscience___provider`
--

DROP TABLE IF EXISTS `Cloud_fieldofscience___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_fieldofscience___provider` (
  `fieldofscience` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`fieldofscience`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_nsfdirectorate`
--

DROP TABLE IF EXISTS `Cloud_nsfdirectorate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_nsfdirectorate` (
  `nsfdirectorate` int(11) NOT NULL,
  PRIMARY KEY (`nsfdirectorate`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_nsfdirectorate___person`
--

DROP TABLE IF EXISTS `Cloud_nsfdirectorate___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_nsfdirectorate___person` (
  `nsfdirectorate` int(11) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`nsfdirectorate`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_nsfdirectorate___pi`
--

DROP TABLE IF EXISTS `Cloud_nsfdirectorate___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_nsfdirectorate___pi` (
  `nsfdirectorate` int(11) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`nsfdirectorate`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_nsfdirectorate___provider`
--

DROP TABLE IF EXISTS `Cloud_nsfdirectorate___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_nsfdirectorate___provider` (
  `nsfdirectorate` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`nsfdirectorate`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_parentscience`
--

DROP TABLE IF EXISTS `Cloud_parentscience`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_parentscience` (
  `parentscience` int(11) NOT NULL,
  PRIMARY KEY (`parentscience`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_parentscience___person`
--

DROP TABLE IF EXISTS `Cloud_parentscience___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_parentscience___person` (
  `parentscience` int(11) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`parentscience`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_parentscience___pi`
--

DROP TABLE IF EXISTS `Cloud_parentscience___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_parentscience___pi` (
  `parentscience` int(11) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`parentscience`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_parentscience___provider`
--

DROP TABLE IF EXISTS `Cloud_parentscience___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_parentscience___provider` (
  `parentscience` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`parentscience`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_person`
--

DROP TABLE IF EXISTS `Cloud_person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_person` (
  `person` int(11) NOT NULL,
  PRIMARY KEY (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_person___pi`
--

DROP TABLE IF EXISTS `Cloud_person___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_person___pi` (
  `person` int(11) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`person`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_person___project`
--

DROP TABLE IF EXISTS `Cloud_person___project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_person___project` (
  `person` int(11) NOT NULL,
  `project` varchar(256) NOT NULL,
  PRIMARY KEY (`person`,`project`),
  KEY `idx_second_dimension` (`project`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_person___provider`
--

DROP TABLE IF EXISTS `Cloud_person___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_person___provider` (
  `person` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`person`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_person___resource`
--

DROP TABLE IF EXISTS `Cloud_person___resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_person___resource` (
  `person` int(11) NOT NULL,
  `resource` int(11) NOT NULL,
  PRIMARY KEY (`person`,`resource`),
  KEY `idx_second_dimension` (`resource`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_person___submission_venue`
--

DROP TABLE IF EXISTS `Cloud_person___submission_venue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_person___submission_venue` (
  `person` int(11) NOT NULL,
  `submission_venue` int(11) NOT NULL,
  PRIMARY KEY (`person`,`submission_venue`),
  KEY `idx_second_dimension` (`submission_venue`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_person___username`
--

DROP TABLE IF EXISTS `Cloud_person___username`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_person___username` (
  `person` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`person`,`username`),
  KEY `idx_second_dimension` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_person___vm_size`
--

DROP TABLE IF EXISTS `Cloud_person___vm_size`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_person___vm_size` (
  `person` int(11) NOT NULL,
  `vm_size` int(4) NOT NULL,
  PRIMARY KEY (`person`,`vm_size`),
  KEY `idx_second_dimension` (`vm_size`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_person___vm_size_memory`
--

DROP TABLE IF EXISTS `Cloud_person___vm_size_memory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_person___vm_size_memory` (
  `person` int(11) NOT NULL,
  `vm_size_memory` int(4) NOT NULL,
  PRIMARY KEY (`person`,`vm_size_memory`),
  KEY `idx_second_dimension` (`vm_size_memory`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_pi`
--

DROP TABLE IF EXISTS `Cloud_pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_pi` (
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_pi___project`
--

DROP TABLE IF EXISTS `Cloud_pi___project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_pi___project` (
  `pi` int(11) NOT NULL,
  `project` varchar(256) NOT NULL,
  PRIMARY KEY (`pi`,`project`),
  KEY `idx_second_dimension` (`project`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_pi___provider`
--

DROP TABLE IF EXISTS `Cloud_pi___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_pi___provider` (
  `pi` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`pi`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_pi___resource`
--

DROP TABLE IF EXISTS `Cloud_pi___resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_pi___resource` (
  `pi` int(11) NOT NULL,
  `resource` int(11) NOT NULL,
  PRIMARY KEY (`pi`,`resource`),
  KEY `idx_second_dimension` (`resource`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_pi___submission_venue`
--

DROP TABLE IF EXISTS `Cloud_pi___submission_venue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_pi___submission_venue` (
  `pi` int(11) NOT NULL,
  `submission_venue` int(11) NOT NULL,
  PRIMARY KEY (`pi`,`submission_venue`),
  KEY `idx_second_dimension` (`submission_venue`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_pi___username`
--

DROP TABLE IF EXISTS `Cloud_pi___username`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_pi___username` (
  `pi` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`pi`,`username`),
  KEY `idx_second_dimension` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_pi___vm_size`
--

DROP TABLE IF EXISTS `Cloud_pi___vm_size`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_pi___vm_size` (
  `pi` int(11) NOT NULL,
  `vm_size` int(4) NOT NULL,
  PRIMARY KEY (`pi`,`vm_size`),
  KEY `idx_second_dimension` (`vm_size`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_pi___vm_size_memory`
--

DROP TABLE IF EXISTS `Cloud_pi___vm_size_memory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_pi___vm_size_memory` (
  `pi` int(11) NOT NULL,
  `vm_size_memory` int(4) NOT NULL,
  PRIMARY KEY (`pi`,`vm_size_memory`),
  KEY `idx_second_dimension` (`vm_size_memory`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_project`
--

DROP TABLE IF EXISTS `Cloud_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_project` (
  `project` varchar(256) NOT NULL,
  PRIMARY KEY (`project`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_project___provider`
--

DROP TABLE IF EXISTS `Cloud_project___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_project___provider` (
  `project` varchar(256) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`project`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_provider`
--

DROP TABLE IF EXISTS `Cloud_provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_provider` (
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_provider___resource`
--

DROP TABLE IF EXISTS `Cloud_provider___resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_provider___resource` (
  `provider` int(11) NOT NULL,
  `resource` int(11) NOT NULL,
  PRIMARY KEY (`provider`,`resource`),
  KEY `idx_second_dimension` (`resource`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_provider___submission_venue`
--

DROP TABLE IF EXISTS `Cloud_provider___submission_venue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_provider___submission_venue` (
  `provider` int(11) NOT NULL,
  `submission_venue` int(11) NOT NULL,
  PRIMARY KEY (`provider`,`submission_venue`),
  KEY `idx_second_dimension` (`submission_venue`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_provider___username`
--

DROP TABLE IF EXISTS `Cloud_provider___username`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_provider___username` (
  `provider` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`provider`,`username`),
  KEY `idx_second_dimension` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_provider___vm_size`
--

DROP TABLE IF EXISTS `Cloud_provider___vm_size`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_provider___vm_size` (
  `provider` int(11) NOT NULL,
  `vm_size` int(4) NOT NULL,
  PRIMARY KEY (`provider`,`vm_size`),
  KEY `idx_second_dimension` (`vm_size`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_provider___vm_size_memory`
--

DROP TABLE IF EXISTS `Cloud_provider___vm_size_memory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_provider___vm_size_memory` (
  `provider` int(11) NOT NULL,
  `vm_size_memory` int(4) NOT NULL,
  PRIMARY KEY (`provider`,`vm_size_memory`),
  KEY `idx_second_dimension` (`vm_size_memory`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_resource`
--

DROP TABLE IF EXISTS `Cloud_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_resource` (
  `resource` int(11) NOT NULL,
  PRIMARY KEY (`resource`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_submission_venue`
--

DROP TABLE IF EXISTS `Cloud_submission_venue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_submission_venue` (
  `submission_venue` int(11) NOT NULL,
  PRIMARY KEY (`submission_venue`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_username`
--

DROP TABLE IF EXISTS `Cloud_username`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_username` (
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_vm_size`
--

DROP TABLE IF EXISTS `Cloud_vm_size`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_vm_size` (
  `vm_size` int(4) NOT NULL,
  PRIMARY KEY (`vm_size`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Cloud_vm_size_memory`
--

DROP TABLE IF EXISTS `Cloud_vm_size_memory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Cloud_vm_size_memory` (
  `vm_size_memory` int(4) NOT NULL,
  PRIMARY KEY (`vm_size_memory`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_fieldofscience`
--

DROP TABLE IF EXISTS `Jobs_fieldofscience`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_fieldofscience` (
  `fieldofscience` int(11) NOT NULL,
  PRIMARY KEY (`fieldofscience`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_fieldofscience___person`
--

DROP TABLE IF EXISTS `Jobs_fieldofscience___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_fieldofscience___person` (
  `fieldofscience` int(11) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`fieldofscience`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_fieldofscience___pi`
--

DROP TABLE IF EXISTS `Jobs_fieldofscience___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_fieldofscience___pi` (
  `fieldofscience` int(11) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`fieldofscience`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_fieldofscience___provider`
--

DROP TABLE IF EXISTS `Jobs_fieldofscience___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_fieldofscience___provider` (
  `fieldofscience` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`fieldofscience`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_gpucount`
--

DROP TABLE IF EXISTS `Jobs_gpucount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_gpucount` (
  `gpucount` int(11) NOT NULL,
  PRIMARY KEY (`gpucount`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_gpucount___person`
--

DROP TABLE IF EXISTS `Jobs_gpucount___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_gpucount___person` (
  `gpucount` int(11) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`gpucount`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_gpucount___pi`
--

DROP TABLE IF EXISTS `Jobs_gpucount___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_gpucount___pi` (
  `gpucount` int(11) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`gpucount`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_gpucount___provider`
--

DROP TABLE IF EXISTS `Jobs_gpucount___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_gpucount___provider` (
  `gpucount` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`gpucount`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobsize`
--

DROP TABLE IF EXISTS `Jobs_jobsize`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobsize` (
  `jobsize` int(4) NOT NULL,
  PRIMARY KEY (`jobsize`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobsize___person`
--

DROP TABLE IF EXISTS `Jobs_jobsize___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobsize___person` (
  `jobsize` int(4) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`jobsize`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobsize___pi`
--

DROP TABLE IF EXISTS `Jobs_jobsize___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobsize___pi` (
  `jobsize` int(4) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`jobsize`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobsize___provider`
--

DROP TABLE IF EXISTS `Jobs_jobsize___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobsize___provider` (
  `jobsize` int(4) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`jobsize`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobwaittime`
--

DROP TABLE IF EXISTS `Jobs_jobwaittime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobwaittime` (
  `jobwaittime` int(4) NOT NULL,
  PRIMARY KEY (`jobwaittime`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobwaittime___person`
--

DROP TABLE IF EXISTS `Jobs_jobwaittime___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobwaittime___person` (
  `jobwaittime` int(4) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`jobwaittime`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobwaittime___pi`
--

DROP TABLE IF EXISTS `Jobs_jobwaittime___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobwaittime___pi` (
  `jobwaittime` int(4) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`jobwaittime`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobwaittime___provider`
--

DROP TABLE IF EXISTS `Jobs_jobwaittime___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobwaittime___provider` (
  `jobwaittime` int(4) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`jobwaittime`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobwalltime`
--

DROP TABLE IF EXISTS `Jobs_jobwalltime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobwalltime` (
  `jobwalltime` int(4) NOT NULL,
  PRIMARY KEY (`jobwalltime`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobwalltime___person`
--

DROP TABLE IF EXISTS `Jobs_jobwalltime___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobwalltime___person` (
  `jobwalltime` int(4) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`jobwalltime`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobwalltime___pi`
--

DROP TABLE IF EXISTS `Jobs_jobwalltime___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobwalltime___pi` (
  `jobwalltime` int(4) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`jobwalltime`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_jobwalltime___provider`
--

DROP TABLE IF EXISTS `Jobs_jobwalltime___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_jobwalltime___provider` (
  `jobwalltime` int(4) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`jobwalltime`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_nodecount`
--

DROP TABLE IF EXISTS `Jobs_nodecount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_nodecount` (
  `nodecount` int(11) NOT NULL,
  PRIMARY KEY (`nodecount`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_nodecount___person`
--

DROP TABLE IF EXISTS `Jobs_nodecount___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_nodecount___person` (
  `nodecount` int(11) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`nodecount`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_nodecount___pi`
--

DROP TABLE IF EXISTS `Jobs_nodecount___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_nodecount___pi` (
  `nodecount` int(11) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`nodecount`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_nodecount___provider`
--

DROP TABLE IF EXISTS `Jobs_nodecount___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_nodecount___provider` (
  `nodecount` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`nodecount`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_nsfdirectorate`
--

DROP TABLE IF EXISTS `Jobs_nsfdirectorate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_nsfdirectorate` (
  `nsfdirectorate` int(11) NOT NULL,
  PRIMARY KEY (`nsfdirectorate`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_nsfdirectorate___person`
--

DROP TABLE IF EXISTS `Jobs_nsfdirectorate___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_nsfdirectorate___person` (
  `nsfdirectorate` int(11) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`nsfdirectorate`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_nsfdirectorate___pi`
--

DROP TABLE IF EXISTS `Jobs_nsfdirectorate___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_nsfdirectorate___pi` (
  `nsfdirectorate` int(11) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`nsfdirectorate`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_nsfdirectorate___provider`
--

DROP TABLE IF EXISTS `Jobs_nsfdirectorate___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_nsfdirectorate___provider` (
  `nsfdirectorate` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`nsfdirectorate`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_parentscience`
--

DROP TABLE IF EXISTS `Jobs_parentscience`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_parentscience` (
  `parentscience` int(11) NOT NULL,
  PRIMARY KEY (`parentscience`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_parentscience___person`
--

DROP TABLE IF EXISTS `Jobs_parentscience___person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_parentscience___person` (
  `parentscience` int(11) NOT NULL,
  `person` int(11) NOT NULL,
  PRIMARY KEY (`parentscience`,`person`),
  KEY `idx_second_dimension` (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_parentscience___pi`
--

DROP TABLE IF EXISTS `Jobs_parentscience___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_parentscience___pi` (
  `parentscience` int(11) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`parentscience`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_parentscience___provider`
--

DROP TABLE IF EXISTS `Jobs_parentscience___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_parentscience___provider` (
  `parentscience` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`parentscience`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_person`
--

DROP TABLE IF EXISTS `Jobs_person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_person` (
  `person` int(11) NOT NULL,
  PRIMARY KEY (`person`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_person___pi`
--

DROP TABLE IF EXISTS `Jobs_person___pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_person___pi` (
  `person` int(11) NOT NULL,
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`person`,`pi`),
  KEY `idx_second_dimension` (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_person___provider`
--

DROP TABLE IF EXISTS `Jobs_person___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_person___provider` (
  `person` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`person`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_person___qos`
--

DROP TABLE IF EXISTS `Jobs_person___qos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_person___qos` (
  `person` int(11) NOT NULL,
  `qos` int(11) NOT NULL,
  PRIMARY KEY (`person`,`qos`),
  KEY `idx_second_dimension` (`qos`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_person___queue`
--

DROP TABLE IF EXISTS `Jobs_person___queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_person___queue` (
  `person` int(11) NOT NULL,
  `queue` char(255) NOT NULL,
  PRIMARY KEY (`person`,`queue`),
  KEY `idx_second_dimension` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_person___resource`
--

DROP TABLE IF EXISTS `Jobs_person___resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_person___resource` (
  `person` int(11) NOT NULL,
  `resource` int(11) NOT NULL,
  PRIMARY KEY (`person`,`resource`),
  KEY `idx_second_dimension` (`resource`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_person___resource_type`
--

DROP TABLE IF EXISTS `Jobs_person___resource_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_person___resource_type` (
  `person` int(11) NOT NULL,
  `resource_type` int(11) NOT NULL,
  PRIMARY KEY (`person`,`resource_type`),
  KEY `idx_second_dimension` (`resource_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_person___username`
--

DROP TABLE IF EXISTS `Jobs_person___username`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_person___username` (
  `person` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`person`,`username`),
  KEY `idx_second_dimension` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_pi`
--

DROP TABLE IF EXISTS `Jobs_pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_pi` (
  `pi` int(11) NOT NULL,
  PRIMARY KEY (`pi`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_pi___provider`
--

DROP TABLE IF EXISTS `Jobs_pi___provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_pi___provider` (
  `pi` int(11) NOT NULL,
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`pi`,`provider`),
  KEY `idx_second_dimension` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_pi___qos`
--

DROP TABLE IF EXISTS `Jobs_pi___qos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_pi___qos` (
  `pi` int(11) NOT NULL,
  `qos` int(11) NOT NULL,
  PRIMARY KEY (`pi`,`qos`),
  KEY `idx_second_dimension` (`qos`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_pi___queue`
--

DROP TABLE IF EXISTS `Jobs_pi___queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_pi___queue` (
  `pi` int(11) NOT NULL,
  `queue` char(255) NOT NULL,
  PRIMARY KEY (`pi`,`queue`),
  KEY `idx_second_dimension` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_pi___resource`
--

DROP TABLE IF EXISTS `Jobs_pi___resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_pi___resource` (
  `pi` int(11) NOT NULL,
  `resource` int(11) NOT NULL,
  PRIMARY KEY (`pi`,`resource`),
  KEY `idx_second_dimension` (`resource`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_pi___resource_type`
--

DROP TABLE IF EXISTS `Jobs_pi___resource_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_pi___resource_type` (
  `pi` int(11) NOT NULL,
  `resource_type` int(11) NOT NULL,
  PRIMARY KEY (`pi`,`resource_type`),
  KEY `idx_second_dimension` (`resource_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_pi___username`
--

DROP TABLE IF EXISTS `Jobs_pi___username`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_pi___username` (
  `pi` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`pi`,`username`),
  KEY `idx_second_dimension` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_provider`
--

DROP TABLE IF EXISTS `Jobs_provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_provider` (
  `provider` int(11) NOT NULL,
  PRIMARY KEY (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_provider___qos`
--

DROP TABLE IF EXISTS `Jobs_provider___qos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_provider___qos` (
  `provider` int(11) NOT NULL,
  `qos` int(11) NOT NULL,
  PRIMARY KEY (`provider`,`qos`),
  KEY `idx_second_dimension` (`qos`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_provider___queue`
--

DROP TABLE IF EXISTS `Jobs_provider___queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_provider___queue` (
  `provider` int(11) NOT NULL,
  `queue` char(255) NOT NULL,
  PRIMARY KEY (`provider`,`queue`),
  KEY `idx_second_dimension` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_provider___resource`
--

DROP TABLE IF EXISTS `Jobs_provider___resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_provider___resource` (
  `provider` int(11) NOT NULL,
  `resource` int(11) NOT NULL,
  PRIMARY KEY (`provider`,`resource`),
  KEY `idx_second_dimension` (`resource`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_provider___resource_type`
--

DROP TABLE IF EXISTS `Jobs_provider___resource_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_provider___resource_type` (
  `provider` int(11) NOT NULL,
  `resource_type` int(11) NOT NULL,
  PRIMARY KEY (`provider`,`resource_type`),
  KEY `idx_second_dimension` (`resource_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_provider___username`
--

DROP TABLE IF EXISTS `Jobs_provider___username`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_provider___username` (
  `provider` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`provider`,`username`),
  KEY `idx_second_dimension` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_qos`
--

DROP TABLE IF EXISTS `Jobs_qos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_qos` (
  `qos` int(11) NOT NULL,
  PRIMARY KEY (`qos`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_queue`
--

DROP TABLE IF EXISTS `Jobs_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_queue` (
  `queue` char(255) NOT NULL,
  PRIMARY KEY (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_resource`
--

DROP TABLE IF EXISTS `Jobs_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_resource` (
  `resource` int(11) NOT NULL,
  PRIMARY KEY (`resource`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_resource_type`
--

DROP TABLE IF EXISTS `Jobs_resource_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_resource_type` (
  `resource_type` int(11) NOT NULL,
  PRIMARY KEY (`resource_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Jobs_username`
--

DROP TABLE IF EXISTS `Jobs_username`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Jobs_username` (
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-09-14 21:38:52
