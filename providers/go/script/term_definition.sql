-- MySQL dump 10.9
--
-- Host: localhost    Database: go
-- ------------------------------------------------------
-- Server version	4.1.12
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=',MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table term_definition
--

DROP TABLE IF EXISTS term_definition;
CREATE TABLE term_definition (
  term_id int(11) NOT NULL default '0',
  term_definition text NOT NULL,
  dbxref_id int(11) default NULL,
  term_comment mediumtext,
  reference varchar(255) default NULL
) ;
CREATE INDEX td1 on term_definition(term_id);


/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

