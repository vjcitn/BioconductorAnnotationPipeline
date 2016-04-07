.echo ON

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

ATTACH DATABASE 'genesrc.sqlite' AS genesrc;

INSERT INTO metadata
 SELECT * FROM genesrc.metadata;

INSERT INTO metadata (name,value) VALUES ('CENTRALID','EG');
INSERT INTO metadata (name,value) VALUES ('TAXID','511145');

CREATE TABLE genes (
 _id INTEGER PRIMARY KEY,
 gene_id TEXT
);

INSERT INTO genes (gene_id)
 SELECT DISTINCT gene_id
 FROM gene_info
 WHERE tax_id='511145'
 ORDER BY gene_id;

CREATE INDEX c1 ON genes(gene_id);

CREATE TABLE gene_info (
 _id INTEGER REFERENCES genes(_id),
 gene_name TEXT,
 symbol TEXT
);

INSERT INTO gene_info
 SELECT g._id as _id, 
	CASE WHEN i.description='-' THEN NULL ELSE i.description END,
	CASE WHEN i.symbol='-' THEN NULL ELSE i.symbol END
 FROM genes as g, genesrc.gene_info as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

DELETE FROM gene_info WHERE gene_name IS NULL AND symbol IS NULL;

CREATE INDEX c4 ON gene_info(_id);

CREATE TEMP TABLE gene_synonyms_orgi (
 _id INTEGER REFERENCES genes(_id),
 symbol TEXT
);

INSERT INTO gene_synonyms_orgi
 SELECT g._id, i.synonym 
 FROM genes as g CROSS JOIN genesrc.gene_synonym as i
 WHERE i.gene_id=g.gene_id AND synonym != "-";

INSERT INTO gene_synonyms_orgi
 SELECT _id, symbol
 FROM gene_info; 

CREATE TABLE gene_synonyms (
 _id INTEGER REFERENCES genes(_id),
 symbol TEXT
);

INSERT INTO gene_synonyms
 SELECT DISTINCT _id, symbol
 FROM gene_synonyms_orgi;

DROP TABLE gene_synonyms_orgi;
VACUUM;
CREATE INDEX c22 ON gene_synonyms(_id);


-- I need to do this more like the gene_synonyms
-- table above, because there are often several
-- items in the field of interest, so I need to 
-- 1) parse out the items into their own table 
-- and 2) filter out all but the ones that start
-- with ensemble in here.

-- CREATE TEMP TABLE ensembl_orgi (
--  _id INTEGER REFERENCES genes(_id),
--  ensid TEXT
-- );

-- INSERT INTO ensembl_orgi
--  SELECT g._id, i.dbXref
--  FROM genes as g CROSS JOIN genesrc.gene_dbXref as i
--  WHERE i.gene_id=g.gene_id AND i.dbXref != "-"
--  AND i.dbXref LIKE '%Ensembl:%';

-- CREATE TABLE ensembl (
--  _id INTEGER REFERENCES genes(_id),
--  ensid TEXT
-- );

-- INSERT INTO ensembl
--  SELECT DISTINCT _id, ltrim(ltrim(ensid,'Ensembl'),':')
--  FROM ensembl_orgi;

-- DROP TABLE ensembl_orgi;
-- VACUUM;
-- CREATE INDEX c23 ON ensembl(_id);






CREATE TABLE accessions (
 _id INTEGER REFERENCES genes(_id),
 accession TEXT
);

INSERT INTO accessions
 SELECT DISTINCT g._id as _id, i.rna_accession
 FROM genes as g, genesrc.gene2accession as i
 WHERE i.gene_id=g.gene_id  and i.rna_accession != '-'
UNION
 SELECT DISTINCT g._id as _id, i.protein_accession
 FROM genes as g, genesrc.gene2accession as i
 WHERE i.gene_id=g.gene_id  and i.protein_accession != '-'
 ORDER BY _id;

CREATE INDEX c2 ON accessions(_id);

-- CREATE TABLE chromosomes (
--  _id INTEGER REFERENCES genes(_id),
--  chromosome TEXT
-- );

-- INSERT INTO chromosomes
--  SELECT DISTINCT g._id as _id, i.chromosome
--  FROM genes as g, genesrc.gene_chromosome as i
--  WHERE i.gene_id=g.gene_id and i.chromosome != '-'
--  ORDER BY _id;

-- CREATE INDEX c5 ON chromosomes(_id);

-- CREATE TABLE cytogenetic_locations (
--  _id INTEGER REFERENCES genes(_id),
--  cytogenetic_location TEXT
-- );

-- INSERT INTO cytogenetic_locations
--  SELECT DISTINCT g._id as _id,  i.map_location
--  FROM genes as g CROSS JOIN genesrc.gene_map_location as i
--  WHERE i.gene_id=g.gene_id AND  i.map_location != '-'
--  ORDER BY _id;

-- CREATE INDEX c6 ON cytogenetic_locations(_id);


CREATE TABLE refseq (
 _id INTEGER REFERENCES genes(_id),
 accession TEXT
);

INSERT INTO refseq
 SELECT DISTINCT g._id as _id, i.rna_accession
 FROM genes as g, genesrc.gene2refseq as i
 WHERE i.gene_id=g.gene_id  and i.rna_accession != '-'
UNION
 SELECT DISTINCT g._id as _id, i.protein_accession
 FROM genes as g, genesrc.gene2refseq as i
 WHERE i.gene_id=g.gene_id  and i.protein_accession != '-'
 ORDER BY _id;

CREATE INDEX c8 ON refseq(_id);

CREATE TABLE pubmed (
 _id INTEGER REFERENCES genes(_id),
 pubmed_id TEXT
);

INSERT INTO pubmed
 SELECT DISTINCT g._id as _id, i.pubmed_id
 FROM genes as g CROSS JOIN genesrc.gene2pubmed as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

CREATE INDEX c9 ON pubmed(_id);
 
-- CREATE TABLE unigene (
--  _id INTEGER REFERENCES genes(_id),
--  unigene_id TEXT
-- );

-- INSERT INTO unigene 
--  SELECT DISTINCT g._id as _id, unigene_id 
--  FROM genes as g, genesrc.gene2unigene as i
--  WHERE i.gene_id=g.gene_id
--  ORDER BY _id;

-- CREATE INDEX c10 ON unigene(_id);

DETACH DATABASE genesrc;
 

-- ATTACH DATABASE 'gpsrc.sqlite' AS gp;

-- CREATE TABLE chrlengths (
--  chromosome TEXT PRIMARY KEY,
--  length INTEGER
-- );

-- INSERT INTO chrlengths
--  SELECT chr, length FROM gp.chrlength_ecoliK12
--  WHERE chr NOT LIKE "ZV7_%";


ATTACH DATABASE 'gosrc.sqlite' AS go;

INSERT INTO metadata
 SELECT * from go.metadata;

CREATE TABLE go_bp (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_bp
 SELECT g._id as _id, i.go_id, i.relationship_type
 FROM genes as g, go.go_bp_ecoliK12 as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

CREATE INDEX c11 ON go_bp(_id);

CREATE TABLE go_mf (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_mf
 SELECT g._id as _id, i.go_id, i.relationship_type
 FROM genes as g, go.go_mf_ecoliK12 as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

CREATE INDEX c12 ON go_mf(_id);

CREATE TABLE go_cc (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_cc
 SELECT g._id as _id, i.go_id, i.relationship_type
 FROM genes as g, go.go_cc_ecoliK12 as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

CREATE INDEX c13 ON go_cc(_id);

CREATE TABLE go_bp_all ( 
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_bp_all
 SELECT g._id as _id, i.go_id, i.relationship_type
 FROM genes as g, go.go_bpall_ecoliK12 as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

CREATE INDEX c14 ON go_bp_all(_id);

CREATE TABLE go_mf_all (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_mf_all
 SELECT g._id as _id, i.go_id, i.relationship_type
 FROM genes as g, go.go_mfall_ecoliK12 as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

CREATE INDEX c15 ON go_mf_all(_id);

CREATE TABLE go_cc_all (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_cc_all
 SELECT g._id as _id, i.go_id, i.relationship_type
 FROM genes as g, go.go_ccall_ecoliK12 as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

CREATE INDEX c16 ON go_cc_all(_id);

DETACH DATABASE go;
ATTACH DATABASE 'keggsrc.sqlite' as kegg;

INSERT INTO metadata
 SELECT * FROM kegg.metadata WHERE name LIKE "KEGGSOURCE%";

CREATE TABLE kegg (
 _id INTEGER REFERENCES genes(_id),
 path_id TEXT
);

INSERT INTO kegg
 SELECT DISTINCT g._id as _id, substr(k.pathway_id, -5, 5)
 FROM genes as g, kegg.pathway2gene as k 
 WHERE g.gene_id=k.gene_or_orf_id
 ORDER BY _id;

CREATE INDEX c17 ON kegg(_id);

CREATE TABLE ec (
 _id INTEGER REFERENCES genes(_id),
 ec_number TEXT
);

INSERT INTO ec 
 SELECT DISTINCT g._id as _id, e.ec_id
 FROM genes as g, kegg.eco_ec as e
 WHERE g.gene_id=e.gene_or_orf_id
 ORDER BY _id;

CREATE INDEX c18 ON ec(_id);

DETACH DATABASE kegg;

-- INSERT INTO metadata
--  SELECT * FROM gp.metadata_ecoliK12;

-- CREATE TABLE chromosome_locations (
--  _id INTEGER REFERENCES genes(_id),
--  chromosome TEXT,
--  start_location INTEGER
-- );

-- INSERT INTO chromosome_locations 
--  SELECT DISTINCT genes._id as _id, 
-- 	g.chrom,
-- 	g.start
--  FROM genes, gp.chrloc_ecoliK12 as g
--  WHERE genes.gene_id=g.gene_id
--  ORDER BY _id;

-- CREATE INDEX c19 ON chromosome_locations(_id);

-- DETACH DATABASE gp; 
-- ATTACH DATABASE 'ipisrc.sqlite' as ipi;

-- INSERT INTO metadata
--  SELECT * FROM ipi.metadata;

-- CREATE TABLE pfam (
--  _id INTEGER REFERENCES genes(_id),
--  ipi_id TEXT,
--  pfam_id TEXT
-- );

-- INSERT INTO pfam
--  SELECT DISTINCT g._id as _id, i.ipi_id, i.pfam_id
--  FROM genes as g, ipi.ecoliK12_pfam as i
--  WHERE g.gene_id=i.gene_id
--  ORDER BY _id;

-- CREATE INDEX c20 ON pfam(_id);

-- CREATE TABLE prosite (
--  _id INTEGER REFERENCES genes(_id),
--  ipi_id TEXT,
--  prosite_id TEXT
-- );

-- INSERT INTO prosite
--  SELECT DISTINCT g._id as _id, i.ipi_id, i.prosite_id
--  FROM genes as g, ipi.ecoliK12_prosite as i
--  WHERE g.gene_id=i.gene_id
--  ORDER BY _id;

-- CREATE INDEX c21 ON prosite(_id);

