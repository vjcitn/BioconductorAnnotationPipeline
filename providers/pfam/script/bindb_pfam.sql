.echo ON
ATTACH DATABASE 'metadatasrc.sqlite' AS meta;

INSERT INTO metadata (name, value)
 VALUES ('PKGNAME', 'PFAM');

INSERT INTO metadata
 SELECT 'DBSCHEMA', db_schema
 FROM meta.metadata
 WHERE package_name IN
        (SELECT value FROM metadata WHERE name='PKGNAME');

INSERT INTO metadata
 SELECT 'CHIPNAME', chip_name
 FROM meta.metadata
 WHERE package_name IN
        (SELECT value FROM metadata WHERE name='PKGNAME');

INSERT INTO metadata
 SELECT 'MANUFACTURERURL', manufacture_url
 FROM meta.metadata
 WHERE package_name IN
        (SELECT value FROM metadata WHERE name='PKGNAME');

INSERT INTO metadata
 (name,value) VALUES ("Db type","GODb");

DELETE FROM metadata WHERE name='PKGNAME';

DETACH DATABASE meta;



--Add map_metadata info

CREATE TABLE map_metadata (
  map_name VARCHAR(80) NOT NULL,
  source_name VARCHAR(80) NOT NULL,
  source_url VARCHAR(255) NOT NULL,
  source_date VARCHAR(20) NOT NULL
);

INSERT INTO map_metadata
 SELECT 'CAZY', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'DE', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'HOMSTRAD', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ID', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'INTERPRO', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'LOAD', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'MEROPS', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'MIM', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PDB', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

-- INSERT INTO map_metadata
--  SELECT 'PFAMB', m1.value, m2.value, m3.value
--  FROM metadata AS m1, metadata AS m2, metadata AS m3
--  WHERE m1.name='PFAMSOURCENAME' AND
--        m2.name='PFAMSOURCEURL' AND
--        m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PRINTS', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PROSITE', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PROSITEPROFILE', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'RM', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'SCOP', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'SMART', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'TC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'TP', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'URL', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

--Also need to do the rev maps:
INSERT INTO map_metadata
 SELECT 'CAZY2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'DE2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'HOMSTRAD2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ID2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'INTERPRO2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'LOAD2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'MEROPS2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'MIM2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PDB2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

-- INSERT INTO map_metadata
--  SELECT 'PFAMB2AC', m1.value, m2.value, m3.value
--  FROM metadata AS m1, metadata AS m2, metadata AS m3
--  WHERE m1.name='PFAMSOURCENAME' AND
--        m2.name='PFAMSOURCEURL' AND
--        m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PRINTS2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PROSITE2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PROSITEPROFILE2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'RM2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'SCOP2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'SMART2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'TC2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'TP2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'URL2AC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PFAMSOURCENAME' AND
       m2.name='PFAMSOURCEURL' AND
       m3.name='PFAMSOURCEDATE';









--Add map_counts info

CREATE TABLE map_counts (
  map_name VARCHAR(80) PRIMARY KEY,
  count INTEGER NOT NULL
);

INSERT INTO map_counts
 SELECT 'CAZY', COUNT(DISTINCT ac)
 FROM cazy;

INSERT INTO map_counts
 SELECT 'DE', COUNT(DISTINCT ac)
 FROM de;

INSERT INTO map_counts
 SELECT 'HOMSTRAD', COUNT(DISTINCT ac)
 FROM homstrad;

INSERT INTO map_counts
 SELECT 'ID', COUNT(DISTINCT ac)
 FROM id;

INSERT INTO map_counts
 SELECT 'INTERPRO', COUNT(DISTINCT ac)
 FROM interpro;

INSERT INTO map_counts
 SELECT 'LOAD', COUNT(DISTINCT ac)
 FROM load;

INSERT INTO map_counts
 SELECT 'MEROPS', COUNT(DISTINCT ac)
 FROM merops;

INSERT INTO map_counts
 SELECT 'MIM', COUNT(DISTINCT ac)
 FROM mim;

INSERT INTO map_counts
 SELECT 'PDB', COUNT(DISTINCT ac)
 FROM pdb;

-- INSERT INTO map_counts
--  SELECT 'PFAMB', COUNT(DISTINCT ac)
--  FROM pfamb;

INSERT INTO map_counts
 SELECT 'PRINTS', COUNT(DISTINCT ac)
 FROM prints;

INSERT INTO map_counts
 SELECT 'PROSITE', COUNT(DISTINCT ac)
 FROM prosite;

INSERT INTO map_counts
 SELECT 'PROSITEPROFILE', COUNT(DISTINCT ac)
 FROM prosite_profile;

INSERT INTO map_counts
 SELECT 'RM', COUNT(DISTINCT ac)
 FROM rm;

INSERT INTO map_counts
 SELECT 'SCOP', COUNT(DISTINCT ac)
 FROM scop;

INSERT INTO map_counts
 SELECT 'SMART', COUNT(DISTINCT ac)
 FROM smart;

INSERT INTO map_counts
 SELECT 'TC', COUNT(DISTINCT ac)
 FROM tc;

INSERT INTO map_counts
 SELECT 'TP', COUNT(DISTINCT ac)
 FROM tp;

INSERT INTO map_counts
 SELECT 'URL', COUNT(DISTINCT ac)
 FROM url;

--Now do the reverse map counts:
INSERT INTO map_counts
 SELECT 'CAZY2AC', COUNT(DISTINCT cazy)
 FROM cazy;

INSERT INTO map_counts
 SELECT 'DE2AC', COUNT(DISTINCT de)
 FROM de;

INSERT INTO map_counts
 SELECT 'HOMSTRAD2AC', COUNT(DISTINCT homstrad)
 FROM homstrad;

INSERT INTO map_counts
 SELECT 'ID2AC', COUNT(DISTINCT id)
 FROM id;

INSERT INTO map_counts
 SELECT 'INTERPRO2AC', COUNT(DISTINCT interpro)
 FROM interpro;

INSERT INTO map_counts
 SELECT 'LOAD2AC', COUNT(DISTINCT load)
 FROM load;

INSERT INTO map_counts
 SELECT 'MEROPS2AC', COUNT(DISTINCT merops)
 FROM merops;

INSERT INTO map_counts
 SELECT 'MIM2AC', COUNT(DISTINCT mim)
 FROM mim;

INSERT INTO map_counts
 SELECT 'PDB2AC', COUNT(DISTINCT pdb)
 FROM pdb;

-- INSERT INTO map_counts
--  SELECT 'PFAMB2AC', COUNT(DISTINCT pfamb)
--  FROM pfamb;

INSERT INTO map_counts
 SELECT 'PRINTS2AC', COUNT(DISTINCT prints)
 FROM prints;

INSERT INTO map_counts
 SELECT 'PROSITE2AC', COUNT(DISTINCT prosite)
 FROM prosite;

INSERT INTO map_counts
 SELECT 'PROSITEPROFILE2AC', COUNT(DISTINCT prosite_profile)
 FROM prosite_profile;

INSERT INTO map_counts
 SELECT 'RM2AC', COUNT(DISTINCT rm)
 FROM rm;

INSERT INTO map_counts
 SELECT 'SCOP2AC', COUNT(DISTINCT scop)
 FROM scop;

INSERT INTO map_counts
 SELECT 'SMART2AC', COUNT(DISTINCT smart)
 FROM smart;

INSERT INTO map_counts
 SELECT 'TC2AC', COUNT(DISTINCT tc)
 FROM tc;

INSERT INTO map_counts
 SELECT 'TP2AC', COUNT(DISTINCT tp)
 FROM tp;

INSERT INTO map_counts
 SELECT 'URL2AC', COUNT(DISTINCT url)
 FROM url;



ANALYZE;