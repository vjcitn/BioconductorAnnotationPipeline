-- MySQL dump 10.9
--
-- Host: localhost    Database: go
-- ------------------------------------------------------
-- Server version	4.1.12
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=',MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table term
--

DROP TABLE IF EXISTS term;
CREATE TABLE term (
  id int(11) NOT NULL,
  name varchar(255) NOT NULL default '',
  term_type varchar(55) NOT NULL default '',
  acc varchar(255) NOT NULL default '',
  is_obsolete int(11) NOT NULL default '0',
  is_root int(11) NOT NULL default '0',
  is_relation int(11) NOT NULL default '0',
  PRIMARY KEY  (id)
) ;

CREATE INDEX t2 on term(term_type);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

