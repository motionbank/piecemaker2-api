SET standard_conforming_strings = 'off';
SET backslash_quote = 'on';

-- MySQL dump 10.13  Distrib 5.6.10, for osx10.8 (x86_64)
--
-- Host: localhost    Database: piecemaker2_test
-- ------------------------------------------------------
-- Server version	5.6.10
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,POSTGRESQL' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table "event_fields"
--

DROP TABLE IF EXISTS "event_fields";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "event_fields" (
  "event_id" int(10) unsigned NOT NULL,
  "id" char(10) NOT NULL,
  "value" text,
  PRIMARY KEY ("id","event_id"),
  KEY "fk_event_has_event_fields" ("event_id"),
  CONSTRAINT "fk_event_has_event_fields" FOREIGN KEY ("event_id") REFERENCES "events" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);


--
-- Dumping data for table "event_fields"
--


--
-- Table structure for table "event_groups"
--

DROP TABLE IF EXISTS "event_groups";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "event_groups" (
  "id" int(10) unsigned NOT NULL,
  "title" varchar(255) NOT NULL,
  "text" text,
  PRIMARY KEY ("id")
);


--
-- Dumping data for table "event_groups"
--


--
-- Table structure for table "events"
--

DROP TABLE IF EXISTS "events";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "events" (
  "id" int(10) unsigned NOT NULL,
  "event_group_id" int(10) unsigned NOT NULL,
  "created_by_user_id" int(10) unsigned DEFAULT NULL,
  "utc_timestamp" decimal(20,6) NOT NULL,
  "duration" decimal(11,6) DEFAULT NULL,
  PRIMARY KEY ("id"),
  KEY "fk_event_has_user" ("created_by_user_id"),
  KEY "fk_event_has_event_groups" ("event_group_id"),
  CONSTRAINT "fk_event_has_user" FOREIGN KEY ("created_by_user_id") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT "fk_event_has_event_groups" FOREIGN KEY ("event_group_id") REFERENCES "event_groups" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);


--
-- Dumping data for table "events"
--


--
-- Table structure for table "user_has_event_groups"
--

DROP TABLE IF EXISTS "user_has_event_groups";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "user_has_event_groups" (
  "user_id" int(10) unsigned NOT NULL,
  "event_group_id" int(10) unsigned NOT NULL,
  "allow_create" tinyint(1) unsigned NOT NULL DEFAULT '0',
  "allow_read" tinyint(1) unsigned NOT NULL DEFAULT '0',
  "allow_update" tinyint(1) unsigned NOT NULL DEFAULT '0',
  "allow_delete" tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY ("user_id","event_group_id"),
  KEY "fk_user_has_event_groups" ("event_group_id"),
  KEY "fk_event_group_has_users" ("user_id"),
  CONSTRAINT "fk_event_group_has_users" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "fk_user_has_event_groups" FOREIGN KEY ("event_group_id") REFERENCES "event_groups" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);


--
-- Dumping data for table "user_has_event_groups"
--


--
-- Table structure for table "users"
--

DROP TABLE IF EXISTS "users";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "users" (
  "id" int(10) unsigned NOT NULL,
  "name" varchar(45) NOT NULL,
  "email" varchar(45) NOT NULL,
  "password" varchar(45) NOT NULL,
  "api_access_key" varchar(45) NOT NULL,
  "is_admin" tinyint(1) unsigned NOT NULL DEFAULT '0',
  "is_disabled" tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY ("id")
);


--
-- Dumping data for table "users"
--


/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-07-17 16:36:48
