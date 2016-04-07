-- MySQL dump 10.9
--
-- Host: localhost    Database: go
-- ------------------------------------------------------
-- Server version	4.1.12
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=',MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table graph_path
--

DROP TABLE IF EXISTS graph_path;
CREATE TABLE graph_path (
  id int(11) NOT NULL,
  term1_id int(11) NOT NULL default '0',
  term2_id int(11) NOT NULL default '0',
  relationship_type_id int(11) NOT NULL default '0',
  distance int(11) NOT NULL default '0',
  relation_distance int(11) default NULL,
  PRIMARY KEY  (id)
);
CREATE INDEX g3 on graph_path(term1_id, term2_id);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

