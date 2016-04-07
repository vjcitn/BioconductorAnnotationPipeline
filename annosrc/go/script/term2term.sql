-- MySQL dump 10.9
--
-- Host: localhost    Database: go
-- ------------------------------------------------------
-- Server version	4.1.12
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=',MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table term2term
--

DROP TABLE IF EXISTS term2term;
CREATE TABLE term2term (
  id int(11) NOT NULL,
  relationship_type_id int(11) NOT NULL default '0',
  term1_id int(11) NOT NULL default '0',
  term2_id int(11) NOT NULL default '0',
  complete int(11) NOT NULL default '0',
  PRIMARY KEY  (id)
); 
CREATE INDEX tt3 on term2term(term1_id, term2_id);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

