.echo ON
ATTACH DATABASE 'tairsrc.sqlite' AS tair;

CREATE TABLE ag(
  array_element_name TEXT NOT NULL,
  locus TEXT
) ;

INSERT INTO ag
 SELECT * FROM tair.affy_AG;

UPDATE ag SET locus=NULL WHERE locus='no_match';

CREATE INDEX ag1 on ag(locus);

CREATE TABLE ath1121501(
  array_element_name TEXT NOT NULL,
  locus TEXT 
) ;

INSERT INTO ath1121501
 SELECT * FROM tair.affy_ATH1;

UPDATE ath1121501 SET locus=NULL WHERE locus='no_match';

CREATE INDEX ath1 on ath1121501(locus);

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

-- CREATE TABLE metadata (
--  name TEXT,
--  value TEXT
-- );

INSERT INTO metadata
 SELECT * 
 FROM tair.metadata
 WHERE name IN ('TAIRSOURCENAME', 'TAIRSOURCEDATE', 'TAIRSOURCEURL', 'TAIRATHURL', 'TAIRAGURL');

DETACH tair;
