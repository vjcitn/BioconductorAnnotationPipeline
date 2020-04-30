.echo ON

ATTACH DATABASE 'metadatasrc.sqlite' AS metadatasrc;
INSERT INTO metadata
 SELECT "DBSCHEMA", db_schema FROM metadatasrc.metadata WHERE package_name="GO"; 
DETACH DATABASE metadatasrc;

ATTACH DATABASE 'genesrc.sqlite' AS genesrc;
DROP TABLE IF EXISTS go_gene;
DROP TABLE IF EXISTS go_all_gene;
DROP TABLE IF EXISTS gene2go_evidence;

INSERT INTO metadata
 SELECT * FROM genesrc.metadata;

UPDATE metadata
 SET name='GOEGSOURCEDATE' WHERE name='EGSOURCEDATE';
UPDATE metadata
 SET name='GOEGSOURCENAME' WHERE name='EGSOURCENAME';
UPDATE metadata
 SET name='GOEGSOURCEURL' WHERE name='EGSOURCEURL';

CREATE TABLE gene2go_evidence (
 evidence_code TEXT
) ;

INSERT INTO gene2go_evidence (evidence_code)
 SELECT DISTINCT evidence
 FROM genesrc.gene2go;

CREATE TABLE go_gene (
	_id INTEGER REFERENCES go_term(_id),
	relationship_type TEXT,
	gene_id TEXT
);
 
INSERT INTO go_gene 
SELECT DISTINCT go._id, g.evidence, g.gene_id
FROM genesrc.gene2go as g CROSS JOIN go_term as go 
WHERE g.tax_id IN 
	('9606', '10090', '10116', '6239', '4932', '7955', '7227') 
	and g.go_id=go.go_id;

CREATE INDEX gh1 on go_gene(_id);
CREATE INDEX gh2 on go_gene(gene_id);
CREATE INDEX gh3 on go_gene(relationship_type);

CREATE TABLE go_all_gene (
	_id INTEGER REFERENCES go_term(_id),
	relationship_type TEXT,
	gene_id TEXT
);

INSERT INTO go_all_gene
SELECT DISTINCT a._id, g.relationship_type, g.gene_id
FROM go_gene as g CROSS JOIN go_bp_offspring as r CROSS JOIN go_term as a
WHERE g._id=r._offspring_id AND r._id=a._id;
 
INSERT INTO go_all_gene
SELECT DISTINCT a._id, g.relationship_type, g.gene_id
FROM go_gene as g CROSS JOIN go_mf_offspring as r CROSS JOIN go_term as a
WHERE g._id=r._offspring_id AND r._id=a._id;
 
INSERT INTO go_all_gene
SELECT DISTINCT a._id, g.relationship_type, g.gene_id
FROM go_gene as g CROSS JOIN go_cc_offspring as r CROSS JOIN go_term as a
WHERE g._id=r._offspring_id AND r._id=a._id;
 
INSERT INTO go_all_gene
SELECT *
FROM go_gene;

CREATE INDEX gh4 on go_all_gene(_id);
CREATE INDEX gh5 on go_all_gene(gene_id);
CREATE INDEX gh6 on go_all_gene(relationship_type);
 
CREATE TABLE map_metadata (
 map_name TEXT,
 source_name TEXT,
 source_url TEXT,
 source_date TEXT
);

BEGIN TRANSACTION;

INSERT INTO map_metadata
 SELECT 'TERM', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='GOSOURCENAME' AND
	m2.name='GOSOURCEURL' AND
	m3.name='GOSOURCEDATE';

INSERT INTO map_metadata 
SELECT 'ENTREZID2GO', m1.value, m2.value, m3.value
FROM metadata AS m1, metadata AS m2, metadata AS m3
WHERE m1.name='GOEGSOURCENAME' AND
	m2.name='GOEGSOURCEURL' AND
	m3.name='GOEGSOURCEDATE';

INSERT INTO map_metadata
SELECT 'ENTREZID', source_name, source_url, source_date
FROM map_metadata
WHERE map_name='ENTREZID2GO';

INSERT INTO map_metadata
SELECT 'ALLENTREZID', source_name, source_url, source_date 
FROM map_metadata
WHERE map_name IN ('TERM', 'ENTREZID2GO');

INSERT INTO map_metadata
 SELECT 'OBSOLETE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'BPPARENTS', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'BPCHILDREN', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'BPANCESTOR', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'BPOFFSPRING', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'MFPARENTS', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'MFCHILDREN', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'MFANCESTOR', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'MFOFFSPRING', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'CCPARENTS', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'CCCHILDREN', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'CCANCESTOR', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

INSERT INTO map_metadata
 SELECT 'CCOFFSPRING', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='TERM';

COMMIT TRANSACTION;

CREATE TABLE map_counts (
 map_name TEXT,
 count INTEGER,
 UNIQUE(map_name)
);

BEGIN TRANSACTION;

INSERT INTO map_counts
SELECT 'ENTREZID2GO', count(distinct gene_id)
FROM go_gene;

INSERT INTO map_counts
SELECT 'ENTREZID', count(distinct _id)
FROM go_gene;

INSERT INTO map_counts
SELECT 'ALLENTREZID', count(distinct _id)
FROM go_all_gene;

INSERT INTO map_counts
 SELECT 'TERM', count(distinct _id)
 FROM go_term;

INSERT INTO map_counts
 SELECT 'OBSOLETE', count(DISTINCT go_id)
 FROM go_obsolete;

INSERT INTO map_counts --OK
 SELECT 'BPPARENTS', count(DISTINCT _id)
 FROM go_bp_parents;

INSERT INTO map_counts
 SELECT 'BPCHILDREN', COUNT(DISTINCT parent.go_id) FROM go_term AS children
  INNER JOIN go_bp_parents ON children._id=go_bp_parents._id
  INNER JOIN go_term AS parent ON go_bp_parents._parent_id=parent._id
  WHERE parent.ontology='BP';

INSERT INTO map_counts
 SELECT 'BPANCESTOR', count(DISTINCT _offspring_id)  
 FROM go_bp_offspring;

INSERT INTO map_counts
 SELECT 'BPOFFSPRING', COUNT(DISTINCT ancestor.go_id) FROM go_term AS offspring
  INNER JOIN go_bp_offspring ON offspring._id=go_bp_offspring._offspring_id
  INNER JOIN go_term AS ancestor ON go_bp_offspring._id=ancestor._id
  WHERE ancestor.ontology='BP';

INSERT INTO map_counts
 SELECT 'MFPARENTS', count(DISTINCT _id)
 FROM go_mf_parents;

INSERT INTO map_counts
 SELECT 'MFCHILDREN', COUNT(DISTINCT parent.go_id) FROM go_term AS children
  INNER JOIN go_mf_parents ON children._id=go_mf_parents._id
  INNER JOIN go_term AS parent ON go_mf_parents._parent_id=parent._id
  WHERE parent.ontology='MF';

INSERT INTO map_counts
 SELECT 'MFANCESTOR', count(DISTINCT _offspring_id)
 FROM go_mf_offspring;
INSERT INTO map_counts
 SELECT 'MFOFFSPRING', COUNT(DISTINCT ancestor.go_id) FROM go_term AS offspring
  INNER JOIN go_mf_offspring ON offspring._id=go_mf_offspring._offspring_id
  INNER JOIN go_term AS ancestor ON go_mf_offspring._id=ancestor._id
  WHERE ancestor.ontology='MF';


INSERT INTO map_counts 
 SELECT 'CCPARENTS', count(DISTINCT _id)
 FROM go_cc_parents;

INSERT INTO map_counts
 SELECT 'CCCHILDREN', COUNT(DISTINCT parent.go_id) FROM go_term AS children
  INNER JOIN go_cc_parents ON children._id=go_cc_parents._id
  INNER JOIN go_term AS parent ON go_cc_parents._parent_id=parent._id
  WHERE parent.ontology='CC';

INSERT INTO map_counts 
 SELECT 'CCANCESTOR', count(DISTINCT _offspring_id)
 FROM go_cc_offspring;

INSERT INTO map_counts
 SELECT 'CCOFFSPRING', COUNT(DISTINCT ancestor.go_id) FROM go_term AS offspring
  INNER JOIN go_cc_offspring ON offspring._id=go_cc_offspring._offspring_id
  INNER JOIN go_term AS ancestor ON go_cc_offspring._id=ancestor._id
  WHERE ancestor.ontology='CC';

COMMIT TRANSACTION;

-- VACUUM gh1;

ANALYZE;
