.echo ON
ATTACH DATABASE 'metadatasrc.sqlite' AS meta;

INSERT INTO metadata
 SELECT 'DBSCHEMA', db_schema
 FROM meta.metadata
 WHERE package_name = 'YEAST'; 

INSERT INTO metadata
 SELECT 'ORGANISM', organism
 FROM meta.metadata
 WHERE package_name = 'YEAST'; 

INSERT INTO metadata
 SELECT 'SPECIES', species
 FROM meta.metadata
 WHERE package_name = 'YEAST'; 

DETACH DATABASE meta;
ATTACH DATABASE 'keggsrc.sqlite' AS keggsrc;

CREATE TABLE kegg (
  _id INTEGER NOT NULL,                          -- REFERENCES sgd
  path_id CHAR(5) NOT NULL,                     -- KEGG pathway short ID
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

INSERT INTO kegg
 SELECT s._id, substr(p.pathway_id, -5, 5)
 FROM sgd as s, keggsrc.pathway2gene as p
 WHERE s.systematic_name=p.gene_or_orf_id;

CREATE INDEX k1 ON kegg(_id);
CREATE INDEX Fkegg ON kegg (_id);

CREATE TABLE ec (
  _id INTEGER NOT NULL,                          -- REFERENCES sgd
  ec_number VARCHAR(13) NOT NULL,               -- EC number (no "EC:" prefix)
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

INSERT INTO ec
 SELECT s._id, e.ec_id
 FROM sgd as s, keggsrc.sce_ec as e
 WHERE s.systematic_name=e.gene_or_orf_id;

CREATE INDEX e1 ON ec(_id);
CREATE INDEX Fec ON ec (_id);

INSERT INTO metadata
 SELECT * FROM keggsrc.metadata
 WHERE name LIKE "KEGGSOURCE%";

DETACH DATABASE keggsrc;

ATTACH DATABASE 'gpsrc.sqlite' AS gp;

CREATE TABLE chrlengths (
 chromosome VARCHAR(2) PRIMARY KEY,
 length INTEGER NOT NULL
);

INSERT INTO chrlengths
 SELECT chr, length FROM gp.chrlength_yeast;

ATTACH DATABASE 'gosrc.sqlite' AS gosrc;

CREATE TABLE go_bp_all (
 _id INTEGER NOT NULL,
 go_id CHAR(10) NOT NULL,
 evidence CHAR(3) NOT NULL,
 FOREIGN KEY (_id) REFERENCES sgd (_id)
);

INSERT INTO go_bp_all
 SELECT g._id, t.go_id, g.evidence
 FROM gosrc.go_bp_offspring as t, 
        go_bp as g
 WHERE g.go_id=t.offspring_go_id; 

INSERT INTO go_bp_all
 SELECT _id, go_id, evidence
 FROM go_bp;

CREATE INDEX goa1 on go_bp_all(_id);

CREATE TABLE go_mf_all (
 _id INTEGER NOT NULL,
 go_id CHAR(10) NOT NULL,
 evidence CHAR(3) NOT NULL,
 FOREIGN KEY (_id) REFERENCES sgd (_id)
);

INSERT INTO go_mf_all
 SELECT g._id, t.go_id, g.evidence
 FROM gosrc.go_mf_offspring as t, 
        go_mf as g
 WHERE g.go_id=t.offspring_go_id; 

INSERT INTO go_mf_all
 SELECT _id, go_id, evidence
 FROM go_mf;

CREATE INDEX goa2 on go_mf_all(_id);

CREATE TABLE go_cc_all (
 _id INTEGER NOT NULL,
 go_id CHAR(10) NOT NULL,
 evidence CHAR(3) NOT NULL,
 FOREIGN KEY (_id) REFERENCES sgd (_id)
);

INSERT INTO go_cc_all
 SELECT g._id, t.go_id, g.evidence
 FROM gosrc.go_cc_offspring as t, 
        go_cc as g
 WHERE g.go_id=t.offspring_go_id; 

INSERT INTO go_cc_all
 SELECT _id, go_id, evidence
 FROM go_cc;

CREATE INDEX goa3 on go_cc_all(_id);

INSERT INTO metadata
 SELECT * FROM gosrc.metadata WHERE name LIKE "GOSOURCE%";

DETACH DATABASE gosrc;


ATTACH DATABASE 'chipsrc_yeastNCBI.sqlite' AS NCBIsrc;

INSERT INTO metadata
 SELECT * FROM NCBIsrc.metadata
 WHERE name LIKE "EGSOURCE%";

CREATE TABLE genes (
  _id INTEGER NOT NULL,                             -- REFERENCES sgd
  gene_id VARCHAR(15) NOT NULL,                     -- Entrez Gene ID
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

INSERT INTO genes
 SELECT DISTINCT s._id, n.gene_id
 FROM (SELECT * FROM NCBIsrc.genes INNER JOIN NCBIsrc.locus_tags USING(_id)) AS n, 
        sgd as s
 WHERE s.systematic_name=n.locus_tag
UNION 
 SELECT DISTINCT s._id, n.gene_id
 FROM (SELECT * FROM NCBIsrc.genes INNER JOIN NCBIsrc.sgd_ids USING(_id)) AS n, 
        sgd as s
 WHERE s.sgd_id=n.sgd_id; 
 
CREATE INDEX eg1 on genes(_id);


--We also have to pass the ensembl IDs along from the NCBI yeast DB.
INSERT INTO metadata
 SELECT * FROM NCBIsrc.metadata
 WHERE name LIKE "ENSOURCE%";

CREATE TABLE ensembl (
  _id INTEGER NOT NULL,                         -- REFERENCES sgd
  ensid VARCHAR(20) NOT NULL,                   -- Ensembl gene ID
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

INSERT INTO ensembl
 SELECT DISTINCT s._id, n.ensid
 FROM (SELECT * FROM NCBIsrc.ensembl INNER JOIN NCBIsrc.locus_tags USING(_id)) AS n, 
        sgd as s
 WHERE s.systematic_name=n.locus_tag
UNION 
 SELECT DISTINCT s._id, n.ensid
 FROM (SELECT * FROM NCBIsrc.ensembl INNER JOIN NCBIsrc.sgd_ids USING(_id)) AS n,  
        sgd as s
 WHERE s.sgd_id=n.sgd_id; 
 
CREATE INDEX ens1 on ensembl(_id);


--make a table to store this data as it was (from ncbi)
CREATE TABLE ncbi2ensembl (
  _id INTEGER NOT NULL,
  ensid VARCHAR(20) NOT NULL,
  FOREIGN KEY (_id) REFERENCES sgd (_id)	
);
INSERT INTO ncbi2ensembl
 SELECT * FROM ensembl;
CREATE INDEX ncbi2ens__id ON ncbi2ensembl(_id);


--Now make and pop a table to hold the ncbi to ensembl mappings (from ensembl)
ATTACH DATABASE 'ensembl.sqlite' AS ens;

DELETE FROM metadata WHERE name LIKE 'ENS%';

INSERT INTO metadata
 SELECT * FROM ens.metadata;

CREATE TABLE ensembl2ncbi (
  _id INTEGER NOT NULL,
  ensid VARCHAR(20) NOT NULL,
  FOREIGN KEY (_id) REFERENCES sgd (_id)	
);


-- Note insert below depends on the genes table having been added above...
-- Almost all the sgds have an EG id so this is acceptable.
INSERT INTO ensembl2ncbi
 SELECT g._id, e.ensid
 FROM genes as g CROSS JOIN ens.scerevisiae_gene_ensembl as e
 WHERE e.gene_id=g.gene_id;

CREATE INDEX ens2ncbi__id ON ensembl2ncbi(_id);


--Insert everything
INSERT INTO ensembl
 SELECT _id, ensid FROM ensembl2ncbi;

--THEN remove the duplicate rows like this:
DELETE FROM ensembl
 WHERE rowid NOT IN (SELECT rowid
  FROM ensembl
  GROUP BY _id, ensid
  HAVING min(rowid));






--Same trick also is used to map the uniprots over from NCBI
CREATE TABLE uniprot (
  _id INTEGER NOT NULL,                         -- REFERENCES sgd
  uniprot_id CHAR(5) NOT NULL,                  -- uniprot ID
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

INSERT INTO uniprot
 SELECT DISTINCT s._id, n.uniprot_id
 FROM (SELECT * FROM NCBIsrc.uniprot INNER JOIN NCBIsrc.locus_tags USING(_id)) AS n, 
        sgd as s
 WHERE s.systematic_name=n.locus_tag 
UNION
 SELECT DISTINCT s._id, n.uniprot_id
 FROM (SELECT * FROM NCBIsrc.uniprot INNER JOIN NCBIsrc.sgd_ids USING(_id)) AS n, 
        sgd as s
 WHERE s.sgd_id=n.sgd_id; 

 CREATE INDEX up1 on uniprot(_id);


CREATE TABLE refseq (
  _id INTEGER NOT NULL,                         -- REFERENCES sgd
  accession CHAR(5) NOT NULL,                   -- refseq accession
  FOREIGN KEY (_id) REFERENCES sgd (_id)
);

INSERT INTO refseq
 SELECT DISTINCT s._id, n.accession
 FROM (SELECT * FROM NCBIsrc.refseq INNER JOIN NCBIsrc.locus_tags USING(_id)) AS n, 
        sgd as s
 WHERE s.systematic_name=n.locus_tag
UNION
 SELECT DISTINCT s._id, n.accession
 FROM (SELECT * FROM NCBIsrc.refseq INNER JOIN NCBIsrc.sgd_ids USING(_id)) AS n, 
        sgd as s
 WHERE s.sgd_id=n.sgd_id; 
 
CREATE INDEX rs1 on refseq(_id);


DETACH DATABASE NCBIsrc;
BEGIN TRANSACTION;


INSERT INTO map_counts
  SELECT 'CHRLENGTHS', count(*)
  FROM chrlengths;

INSERT INTO map_counts
  SELECT 'ENZYME', count(DISTINCT _id)
  FROM ec;

INSERT INTO map_counts
  SELECT 'ENZYME2GENE', count(DISTINCT ec_number)
  FROM ec;

INSERT INTO map_counts
  SELECT 'PATH', count(DISTINCT _id)
  FROM kegg;

INSERT INTO map_counts
  SELECT 'PATH2GENE', count(DISTINCT path_id)
  FROM kegg;

INSERT INTO map_counts
  SELECT 'GO2ALLGENES', COUNT(DISTINCT go_id) FROM (
    SELECT go_id FROM sgd INNER JOIN go_bp_all USING(_id) WHERE systematic_name IS NOT NULL
      UNION
    SELECT go_id FROM sgd INNER JOIN go_cc_all USING(_id) WHERE systematic_name IS NOT NULL
      UNION
    SELECT go_id FROM sgd INNER JOIN go_mf_all USING(_id) WHERE systematic_name IS NOT NULL
  );

INSERT INTO map_counts
  SELECT 'ENSEMBL', count(DISTINCT _id)   
  FROM ensembl;

INSERT INTO map_counts
  SELECT 'ENSEMBL2GENE', count(DISTINCT ensid)
  FROM ensembl;



COMMIT TRANSACTION;

CREATE TABLE map_metadata (
  map_name VARCHAR(80) NOT NULL,
  source_name VARCHAR(80) NOT NULL,
  source_url VARCHAR(255) NOT NULL,
  source_date VARCHAR(20) NOT NULL
);

BEGIN TRANSACTION;

INSERT INTO map_metadata
 SELECT 'ALIAS', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='YGSOURCENAME' AND
        m2.name='YGSOURCEURL' AND
        m3.name='YGSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'COMMON2SYSTEMATIC', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'GENENAME', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'INTERPRO', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'PFAM', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'SMART', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'PMID', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'PMID2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'CHRLOC', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'CHRLOCEND', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'CHR', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'DESCRIPTION', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'GO', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'GO2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'GO2ALLGENES', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ALIAS';

INSERT INTO map_metadata
 SELECT 'ENZYME', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='KEGGSOURCENAME' AND
        m2.name='KEGGSOURCEURL' AND
        m3.name='KEGGSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ENZYME2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENZYME';

INSERT INTO map_metadata
 SELECT 'PATH', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENZYME';

INSERT INTO map_metadata
 SELECT 'PATH2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENZYME';

INSERT INTO map_metadata
 SELECT 'GO2ALLGENES', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='GOSOURCENAME' AND
        m2.name='GOSOURCEURL' AND
        m3.name='GOSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ENTREZID', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='EGSOURCENAME' AND
        m2.name='EGSOURCEURL' AND
        m3.name='EGSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'UNIPROT', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENTREZID';

INSERT INTO map_metadata
 SELECT 'REFSEQ', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENTREZID';

INSERT INTO map_metadata
 SELECT 'ENSEMBL', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='ENSOURCENAME' AND
        m2.name='ENSOURCEURL' AND
        m3.name='ENSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ENSEMBL2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENSEMBL';



COMMIT TRANSACTION;
ANALYZE;
