.echo ON

ATTACH DATABASE 'metadatasrc.sqlite' AS metadatasrc;
INSERT INTO metadata
 SELECT "DBSCHEMA", db_schema FROM metadatasrc.metadata WHERE package_name="KEGG";
INSERT INTO metadata
 (name,value) VALUES ("Db type","KEGGDb");
DETACH DATABASE metadatasrc;

CREATE TABLE map_counts (
  map_name VARCHAR(80) PRIMARY KEY,
  count INTEGER NOT NULL
);

--CREATE TABLE map_counts (
-- map_name TEXT,
-- count INTEGER,
-- UNIQUE(map_name)
--);

BEGIN TRANSACTION;

INSERT INTO map_counts
 SELECT 'ENZYMEID2GO', count(DISTINCT ec_no)
 FROM ec2go;

INSERT INTO map_counts
 SELECT 'GO2ENZYMEID', count(DISTINCT go_id)
 FROM ec2go;

INSERT INTO map_counts
 SELECT 'EXTID2PATHID', count(DISTINCT gene_or_orf_id)
 FROM pathway2gene;

INSERT INTO map_counts
 SELECT 'PATHID2EXTID', count(DISTINCT pathway_id)
 FROM pathway2gene;

INSERT INTO map_counts
 SELECT 'PATHID2NAME', count(DISTINCT path_id)
 FROM pathway2name;

INSERT INTO map_counts
 SELECT 'PATHNAME2ID', count(DISTINCT path_name)
 FROM pathway2name;

COMMIT TRANSACTION;

CREATE TABLE map_metadata (
  map_name VARCHAR(80) NOT NULL,
  source_name VARCHAR(80) NOT NULL,
  source_url VARCHAR(255) NOT NULL,
  source_date VARCHAR(20) NOT NULL
);

--CREATE TABLE map_metadata (
-- map_name TEXT,
-- source_name TEXT,
-- source_url TEXT,
-- source_date TEXT
--);

BEGIN TRANSACTION;

INSERT INTO map_metadata
  SELECT 'ENZYMEID2GO', m1.value, m2.value, m3.value
  FROM metadata AS m1, metadata AS m2, metadata AS m3
  WHERE m1.name='GOEXTSOURCENAME' AND 
	m2.name='GOEXTSOURCEURL' AND
	m3.name='GOEXTSOURCEDATE';

INSERT INTO map_metadata
  SELECT 'GO2ENZYMEID', source_name, source_url, source_date
  FROM map_metadata
  WHERE map_name='ENZYMEID2GO';

INSERT INTO map_metadata
  SELECT 'EXTID2PATHID',  m1.value, m2.value, m3.value
  FROM metadata AS m1, metadata AS m2, metadata AS m3
  WHERE m1.name='KEGGSOURCENAME' AND
        m2.name='KEGGSOURCEURL' AND
        m3.name='KEGGSOURCEDATE';

INSERT INTO map_metadata
  SELECT 'PATHID2EXTID', source_name, source_url, source_date
  FROM map_metadata
  WHERE map_name='EXTID2PATHID';

INSERT INTO map_metadata
  SELECT 'PATHNAME2ID',  m1.value, m2.value, m3.value
  FROM metadata AS m1, metadata AS m2, metadata AS m3
  WHERE m1.name='PATHNAMESOURCENAME' AND
        m2.name='PATHNAMESOURCEURL' AND
        m3.name='PATHNAMESOURCEDATE';

INSERT INTO map_metadata
  SELECT 'PATHID2NAME', source_name, source_url, source_date
  FROM map_metadata
  WHERE map_name='PATHNAME2ID';

COMMIT TRANSACTION;

