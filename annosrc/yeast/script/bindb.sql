.echo ON
ATTACH DATABASE 'sgdsrc.sqlite' AS sgdsrc;

--sgd is the union of systematic_name and gene_name
--show their mappings to sgd
--useful for go mappings

-- The "sgd" table is the central table.
CREATE TABLE sgd (
  _id INTEGER PRIMARY KEY,
  systematic_name VARCHAR(14) NULL UNIQUE,      -- Yeast gene systematic name
  gene_name VARCHAR(14) NULL UNIQUE,            -- Yeast gene name
  sgd_id CHAR(10) NOT NULL UNIQUE               -- SGD ID
);

-- CREATE TABLE sgd (
--  id INTEGER PRIMARY KEY,
--  systematic_name TEXT,
--  gene_name TEXT,
--  sgd_id TEXT NOT NULL
-- );

-- OLD code that used registry genenames
-- INSERT INTO sgd (systematic_name, gene_name, sgd_id)
--  SELECT DISTINCT f.feature_name, g.gene_name, g.sgd
--  FROM sgdsrc.registry_genenames as g LEFT OUTER JOIN sgdsrc.sgd_features as f
--  	ON g.sgd=f.sgd;

-- INSERT INTO sgd (systematic_name, sgd_id)
--  SELECT DISTINCT feature_name, sgd
--  FROM sgdsrc.sgd_features 
--  WHERE sgd NOT IN 
-- 	(SELECT sgd FROM sgdsrc.registry_genenames); 


-- NEW code that doesn't
INSERT INTO sgd (systematic_name, gene_name, sgd_id)
 SELECT DISTINCT feature_name, standard_gene_name, sgd
 FROM sgdsrc.sgd_features;

CREATE INDEX s1 on sgd(sgd_id);
CREATE INDEX s2 on sgd(systematic_name);
 
CREATE TABLE chromosome_features (
  _id INTEGER NOT NULL,                          -- REFERENCES sgd
  chromosome VARCHAR(2) NULL,                   -- chromosome name
  start INTEGER NULL,
  stop INTEGER NULL,
  feature_description TEXT NULL,                -- Yeast feature description
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

-- CREATE TABLE chromosome_features (
--  id INTEGER REFERENCES sgd(id),
--  chromosome TEXT,
--  start INTEGER,
--  feature_description TEXT
-- );

--The sgd guys "flip" the orientation of the start and stop so that 
--the start indicates where transcription begins in an absolute sense.
--So we have to flip the orientation back when we are putting a minus on
--so that we can keep everything consistent.
--THEREFORE, if we are not on the W strand, then we must not only put a
--minus sign on there, but also start will become stop and vice versa...
INSERT INTO chromosome_features
(_id, chromosome, start, stop, feature_description)
 SELECT DISTINCT  s._id, 
	f.chromosome, 
	CASE WHEN f.strand=='W' 
	     THEN f.start_coordinate 
	     ELSE (0-f.stop_coordinate) END,
	CASE WHEN f.strand=='W' 
	     THEN f.stop_coordinate 
	     ELSE (0-f.start_coordinate) END,
	f.feature_description
 FROM sgdsrc.sgd_features as f, sgd as s
 WHERE f.sgd=s.sgd_id; 

CREATE INDEX cf1 on chromosome_features(_id);
CREATE INDEX Fchromosome_features ON chromosome_features (_id);

CREATE TABLE gene2alias (
  _id INTEGER NOT NULL,                          -- REFERENCES sgd
  alias VARCHAR(13) NOT NULL,                   -- Yeast gene alias
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

-- CREATE TABLE gene2alias (
--  id INTEGER REFERENCES sgd(id),
--  alias TEXT
-- );

INSERT INTO gene2alias
 SELECT DISTINCT s._id, g.alias
 FROM sgd as s, sgdsrc.gene2alias as g
 WHERE s.sgd_id=g.sgd;

CREATE INDEX ga1 on gene2alias(_id);
CREATE INDEX Fgene2alias ON gene2alias (_id);

CREATE TABLE gene2systematic (
  _id INTEGER NOT NULL, 
  gene_name VARCHAR(14) NULL,                   -- Yeast gene name
  systematic_name VARCHAR(14) NULL,             -- Yeast gene systematic name
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

-- CREATE TABLE gene2systematic (
--  gene_name TEXT,
--  systematic_name TEXT
-- );

INSERT INTO gene2systematic
 SELECT _id, gene_name, systematic_name
 FROM sgd;

INSERT INTO gene2systematic
 SELECT DISTINCT s._id, a.alias, s.systematic_name
 FROM sgd as s, gene2alias as a
 WHERE s._id=a._id;

DELETE FROM gene2systematic WHERE _id IS NULL AND
gene_name IS NULL AND
systematic_name IS NULL;

CREATE TABLE go_bp (
  _id INTEGER NOT NULL,                          -- REFERENCES sgd
  go_id CHAR(10) NOT NULL,                      -- GO ID
  evidence CHAR(3) NOT NULL,                    -- GO evidence code
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

-- CREATE TABLE go_bp (
--  id INTEGER REFERENCES sgd(id),
--  go_id TEXT,
--  relationship_type TEXT
-- );

INSERT INTO go_bp
 SELECT DISTINCT s._id, go.go_id, go.evidence
 FROM sgd as s, sgdsrc.gene_association as go 
 WHERE go.go_category='P' and go.sgd=s.sgd_id; 
 
CREATE TABLE go_mf (
  _id INTEGER NOT NULL,                          -- REFERENCES sgd
  go_id CHAR(10) NOT NULL,                      -- GO ID
  evidence CHAR(3) NOT NULL,                    -- GO evidence code
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

-- CREATE TABLE go_mf (
--  id INTEGER REFERENCES sgd(id),
--  go_id TEXT,
--  relationship_type TEXT
-- );

INSERT INTO go_mf
 SELECT DISTINCT s._id, go.go_id, go.evidence
 FROM sgd as s, sgdsrc.gene_association as go 
 WHERE go.go_category='F' and go.sgd=s.sgd_id; 
 
CREATE TABLE go_cc (
  _id INTEGER NOT NULL,                          -- REFERENCES sgd
  go_id CHAR(10) NOT NULL,                      -- GO ID
  evidence CHAR(3) NOT NULL,                    -- GO evidence code
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

-- CREATE TABLE go_cc (
--  id INTEGER REFERENCES sgd(id),
--  go_id TEXT,
--  relationship_type TEXT
-- );

INSERT INTO go_cc
 SELECT DISTINCT s._id, go.go_id, go.evidence
 FROM sgd as s, sgdsrc.gene_association as go 
 WHERE go.go_category='C' and go.sgd=s.sgd_id; 
 
CREATE INDEX go1 on go_bp(_id);
CREATE INDEX go2 on go_mf(_id);
CREATE INDEX go3 on go_cc(_id);
CREATE INDEX go4 on go_bp(go_id);
CREATE INDEX go5 on go_mf(go_id);
CREATE INDEX go6 on go_cc(go_id);
CREATE INDEX Fgo_bp ON go_bp (_id);
CREATE INDEX Fgo_cc ON go_cc (_id);
CREATE INDEX Fgo_mf ON go_mf (_id);


CREATE TABLE pubmed (
  _id INTEGER NOT NULL,                          -- REFERENCES sgd
  pubmed_id VARCHAR(10) NOT NULL,               -- PubMed ID
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

-- CREATE TABLE pubmed (
--  id INTEGER REFERENCES sgd(id),
--  pubmed_id TEXT
-- );

INSERT INTO pubmed
 SELECT DISTINCT s._id, g.pubmed as PMID
 FROM sgd as s, sgdsrc.gene_literature as g
 WHERE g.sgd=s.sgd_id AND s.systematic_name NOT NULL;

CREATE INDEX pm1 ON pubmed(_id);
CREATE INDEX Fpubmed ON pubmed (_id);

CREATE TABLE interpro (
  _id INTEGER NOT NULL,                          -- REFERENCES sgd
  interpro_id CHAR(9) NOT NULL,                 -- InterPro ID
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

-- CREATE TABLE interpro (
--  id INTEGER REFERENCES sgd(id),
--  interpro_id TEXT
-- );

INSERT INTO interpro
 SELECT DISTINCT s._id, d.interpro
 FROM sgdsrc.domains as d CROSS JOIN sgd as s
 WHERE d.interpro LIKE 'IPR%' AND d.systematic_name=s.systematic_name; 

CREATE INDEX in1 ON interpro(_id);
CREATE INDEX Finterpro ON interpro (_id);

-- CREATE TABLE pfam (
--   _id INTEGER NOT NULL,                          -- REFERENCES sgd
--   pfam_id CHAR(7) NOT NULL,                     -- Pfam ID
--   FOREIGN KEY (_id) REFERENCES sgd (_id)
-- );

-- -- CREATE TABLE pfam (
-- --  id INTEGER REFERENCES sgd(id),
-- --  pfam_id TEXT
-- -- );

-- INSERT INTO pfam
--  SELECT DISTINCT s._id, d.db_id
--  FROM sgdsrc.domains as d CROSS JOIN sgd as s
--  WHERE d.analysis_method='HMMPfam' AND d.systematic_name=s.systematic_name;

-- CREATE INDEX pf1 ON pfam(_id);
-- CREATE INDEX Fpfam ON pfam (_id);

CREATE TABLE smart (
  _id INTEGER NOT NULL,                          -- REFERENCES sgd
  smart_id CHAR(7) NOT NULL,                    -- SMART ID
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

-- CREATE TABLE smart (
--  id INTEGER REFERENCES sgd(id),
--  smart_id TEXT
-- );

INSERT INTO smart
 SELECT DISTINCT s._id, d.db_id
 FROM sgdsrc.domains as d CROSS JOIN sgd as s
 WHERE d.analysis_method='HMMSmart' AND d.systematic_name=s.systematic_name;

CREATE INDEX sm1 ON smart(_id);
CREATE INDEX Fsmart ON smart (_id);

CREATE TABLE reject_orf (
  systematic_name VARCHAR(14) PRIMARY KEY       -- Yeast gene systematic name
);

-- CREATE TABLE reject_orf (
--  systematic_name TEXT
-- );

INSERT INTO reject_orf 
 SELECT DISTINCT systematic_name
 FROM sgdsrc.reject_orf as s 
 WHERE s.RFC="reject";

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

-- CREATE TABLE metadata (
--         name TEXT,
--         value TEXT
-- );

INSERT INTO metadata
 SELECT * FROM sgdsrc.metadata;

INSERT INTO metadata (name,value) VALUES ('CENTRALID','ORF');
INSERT INTO metadata (name,value) VALUES ('TAXID','559292');

CREATE TABLE map_counts (
  map_name VARCHAR(80) PRIMARY KEY,
  count INTEGER NOT NULL
);

-- CREATE TABLE map_counts (
--  map_name TEXT,
--  count INTEGER,
--  UNIQUE(map_name)
-- );

BEGIN TRANSACTION;

INSERT INTO map_counts
 SELECT 'ALIAS', count(DISTINCT a._id)
 FROM gene2alias as a, sgd
 WHERE a.alias NOT NULL AND a._id=sgd._id AND sgd.systematic_name NOT NULL;

-- INSERT INTO map_counts
--  SELECT 'CHR', count(DISTINCT id)
--  FROM chromosome_features
--  WHERE id IN 
--  	(SELECT DISTINCT id FROM sgd WHERE 
-- 	sgd.systematic_name NOT NULL); 

INSERT INTO map_counts
  SELECT 'CHR', COUNT(DISTINCT systematic_name)
    FROM sgd INNER JOIN chromosome_features USING(_id)
    WHERE chromosome IS NOT NULL;

-- INSERT INTO map_counts
--   SELECT 'COMMON2SYSTEMATIC', count(DISTINCT gene_name)
--   FROM gene2systematic;

INSERT INTO map_counts
  SELECT 'COMMON2SYSTEMATIC', COUNT(DISTINCT gene_name)
    FROM gene2systematic
    WHERE systematic_name IS NOT NULL;

INSERT INTO map_counts
  SELECT 'GENENAME', count(DISTINCT systematic_name)
  FROM sgd
  WHERE gene_name NOT NULL;

-- INSERT INTO map_counts
--   SELECT 'GO', count(DISTINCT id)
--   FROM sgd
--   WHERE id IN (
--     SELECT id FROM go_bp UNION
--     SELECT id FROM go_mf UNION
--     SELECT id FROM go_cc
--   );

INSERT INTO map_counts
  SELECT 'GO', COUNT(DISTINCT systematic_name) FROM (
    SELECT systematic_name FROM sgd INNER JOIN go_bp USING(_id) WHERE go_id IS NOT NULL
      UNION
    SELECT systematic_name FROM sgd INNER JOIN go_cc USING(_id) WHERE go_id IS NOT NULL
      UNION
    SELECT systematic_name FROM sgd INNER JOIN go_mf USING(_id) WHERE go_id IS NOT NULL
  );

--INSERT INTO map_counts
--  SELECT 'GO2GENE', count(go_id)
--  FROM (SELECT DISTINCT go_id FROM go_bp UNION
--	SELECT DISTINCT go_id FROM go_mf UNION
--	SELECT DISTINCT go_id FROM go_cc);

INSERT INTO map_counts
  SELECT 'GO2GENE', COUNT(DISTINCT go_id) FROM (
    SELECT go_id FROM sgd INNER JOIN go_bp USING(_id) WHERE systematic_name IS NOT NULL
      UNION
    SELECT go_id FROM sgd INNER JOIN go_cc USING(_id) WHERE systematic_name IS NOT NULL
      UNION
    SELECT go_id FROM sgd INNER JOIN go_mf USING(_id) WHERE systematic_name IS NOT NULL
  );



INSERT INTO map_counts
  SELECT 'INTERPRO', count(DISTINCT _id)
  FROM interpro; 

-- INSERT INTO map_counts
--   SELECT 'PFAM', count(DISTINCT _id)
--   FROM pfam;

INSERT INTO map_counts
  SELECT 'SMART', count(DISTINCT _id)
  FROM smart;

INSERT INTO map_counts
  SELECT 'REJECTORF', count(*)
  FROM reject_orf;

INSERT INTO map_counts
  SELECT 'PMID', count(DISTINCT _id)
  FROM pubmed; 

INSERT INTO map_counts
  SELECT 'PMID2GENE', count(DISTINCT pubmed_id)
  FROM pubmed;

INSERT INTO map_counts
  SELECT 'TOTAL', count(DISTINCT systematic_name)
  FROm sgd;

COMMIT TRANSACTION;
BEGIN TRANSACTION;

-- INSERT INTO map_counts
--   SELECT 'CHRLOC', count
--   FROM map_counts
--   WHERE map_name='CHR';

INSERT INTO map_counts
  SELECT 'CHRLOC', COUNT(DISTINCT systematic_name)
    FROM sgd INNER JOIN chromosome_features USING(_id)
    WHERE start IS NOT NULL;

INSERT INTO map_counts
  SELECT 'CHRLOCEND', COUNT(DISTINCT systematic_name)
    FROM sgd INNER JOIN chromosome_features USING(_id)
    WHERE stop IS NOT NULL;

-- INSERT INTO map_counts
--   SELECT 'DESCRIPTION', count
--   FROM map_counts
--   WHERE map_name='CHR';

INSERT INTO map_counts
  SELECT 'DESCRIPTION', COUNT(DISTINCT systematic_name)
    FROM sgd INNER JOIN chromosome_features USING(_id)
    WHERE feature_description IS NOT NULL;

COMMIT TRANSACTION;
ANALYZE; 
