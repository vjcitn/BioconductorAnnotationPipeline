-- MySQL dump 10.9
--
-- Host: localhost    Database: go
-- ------------------------------------------------------
-- Server version	4.1.12
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=',MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table term_synonym
--

DROP TABLE IF EXISTS term_synonym;
CREATE TABLE term_synonym (
  term_id int(11) NOT NULL default '0',
  term_synonym varchar(255) default NULL,
  acc_synonym varchar(255) default NULL,
  synonym_type_id int(11) NOT NULL default '0',
  synonym_category_id int(11) default NULL
);
CREATE INDEX ts1 on term_synonym(term_id);


/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

