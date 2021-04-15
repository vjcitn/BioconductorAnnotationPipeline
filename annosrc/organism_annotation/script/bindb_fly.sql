.echo ON

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

ATTACH DATABASE 'genesrc.sqlite' AS genesrc;

INSERT INTO metadata
 SELECT * FROM genesrc.metadata;

INSERT INTO metadata (name,value) VALUES ('CENTRALID','EG');
INSERT INTO metadata (name,value) VALUES ('TAXID','7227');

CREATE TABLE genes (
 _id INTEGER PRIMARY KEY,
 gene_id TEXT
);

INSERT INTO genes (gene_id)
 SELECT DISTINCT gene_id
 FROM gene_info
 WHERE tax_id='7227'
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

--TODO: change this so that its taking these IDs from the 
--pre-processed dbXref table (ie like the ensembl tables 
--for mammals)
CREATE TEMP TABLE flybase_orgi (
 _id INTEGER REFERENCES genes(_id),
 FBid TEXT
);

INSERT INTO flybase_orgi
 SELECT g._id, i.dbXref
 FROM genes as g CROSS JOIN genesrc.gene_dbXref as i
 WHERE i.gene_id=g.gene_id AND i.dbXref != "-" 
 AND i.dbXref LIKE 'FLYBASE:%';

CREATE TABLE flybase (
 _id INTEGER REFERENCES genes(_id),
 FBid TEXT
);

INSERT INTO flybase
 SELECT DISTINCT _id, ltrim(ltrim(FBid,'FLYBASE'),':') 
 FROM flybase_orgi;

DROP TABLE flybase_orgi;
VACUUM;
CREATE INDEX c23 ON flybase(_id);

CREATE TEMP TABLE cg_orgi (
 _id INTEGER REFERENCES genes(_id),
 CGid TEXT
);

INSERT INTO cg_orgi
 SELECT g._id, i.locus_tag
 FROM genes as g CROSS JOIN genesrc.gene_info as i
 WHERE i.gene_id=g.gene_id AND i.locus_tag != "-"
 AND i.locus_tag LIKE 'Dmel_%';

CREATE TABLE flybase_cg (
 _id INTEGER REFERENCES genes(_id),
 CGid TEXT
);

INSERT INTO flybase_cg
 SELECT DISTINCT _id, ltrim(ltrim(CGid,'Dmel'),'_') 
 FROM cg_orgi;

DROP TABLE cg_orgi;
VACUUM;
CREATE INDEX c24 ON flybase_cg(_id);

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

CREATE TABLE chromosomes (
 _id INTEGER REFERENCES genes(_id),
 chromosome TEXT
);

INSERT INTO chromosomes
 SELECT DISTINCT g._id as _id, i.chromosome
 FROM genes as g, genesrc.gene_chromosome as i
 WHERE i.gene_id=g.gene_id and i.chromosome != '-'
 ORDER BY _id;

CREATE INDEX c5 ON chromosomes(_id);

CREATE TABLE cytogenetic_locations (
 _id INTEGER REFERENCES genes(_id),
 cytogenetic_location TEXT
);

INSERT INTO cytogenetic_locations
 SELECT DISTINCT g._id as _id,  i.map_location
 FROM genes as g CROSS JOIN genesrc.gene_map_location as i
 WHERE i.gene_id=g.gene_id AND  i.map_location != '-'
 ORDER BY _id;

CREATE INDEX c6 ON cytogenetic_locations(_id);

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
 
CREATE TABLE genetype (
 _id INTEGER REFERENCES genes(_id),
 gene_type TEXT
);

INSERT INTO genetype 
 SELECT DISTINCT g._id as _id, gene_type 
 FROM genes as g, genesrc.gene_info as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

CREATE INDEX c10 ON genetype(_id);

DETACH DATABASE genesrc;

ATTACH DATABASE 'gpsrc.sqlite' AS gp;

CREATE TABLE chrlengths (
 chromosome TEXT PRIMARY KEY,
 length INTEGER
);

INSERT INTO chrlengths
 SELECT ltrim(chr,'chr'), length FROM gp.chrlength_fly;

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
 FROM genes as g, go.go_bp_fly as i
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
 FROM genes as g, go.go_mf_fly as i
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
 FROM genes as g, go.go_cc_fly as i
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
 FROM genes as g, go.go_bpall_fly as i
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
 FROM genes as g, go.go_mfall_fly as i
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
 FROM genes as g, go.go_ccall_fly as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

CREATE INDEX c16 ON go_cc_all(_id);

DETACH DATABASE go;
ATTACH DATABASE 'keggsrc.sqlite' as kegg;

INSERT INTO metadata
 SELECT * FROM kegg.metadata WHERE name LIKE "KEGGSOURCE%";

CREATE TABLE kegg (
 _id INTEGER REFERENCES genes(_id),
 FBid TEXT,
 path_id TEXT
);

INSERT INTO kegg
 SELECT g._id, f.FBid, substr(k.pathway_id, -5, 5)
 FROM genes as g, flybase as f,
 kegg.pathway2gene as k
 WHERE g._id=f._id AND f.FBid=k.gene_or_orf_id 
 ORDER BY g._id;

CREATE INDEX c17 ON kegg(_id);

CREATE TABLE ec (
 _id INTEGER REFERENCES genes(_id),
 FBid TEXT,
 ec_number TEXT
);

INSERT INTO ec
 SELECT g._id, f.FBid, e.ec_id
 FROM genes as g, flybase as f,
 kegg.dme_ec as e
 WHERE g._id=f._id AND f.FBid=e.gene_or_orf_id
 ORDER BY g._id;

CREATE INDEX c18 ON ec(_id);

DETACH DATABASE kegg;


INSERT INTO metadata
 SELECT * FROM gp.metadata_fly;

CREATE TABLE chromosome_locations (
 _id INTEGER REFERENCES genes(_id),
 chromosome TEXT,
 start_location INTEGER,
 end_location INTEGER
);

INSERT INTO chromosome_locations 
 SELECT DISTINCT genes._id as _id, 
	g.chrom,
	g.start,
	g.end
 FROM genes, gp.chrloc_fly as g
 WHERE genes.gene_id=g.gene_id
 ORDER BY _id;

CREATE INDEX c19 ON chromosome_locations(_id);

DETACH DATABASE gp; 
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
--  FROM genes as g, ipi.fly_pfam as i
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
--  FROM genes as g, ipi.fly_prosite as i
--  WHERE g.gene_id=i.gene_id
--  ORDER BY _id;

-- CREATE INDEX c21 ON prosite(_id);




-- ATTACH DATABASE 'ensembl.sqlite' AS ens;

-- INSERT INTO metadata
--  SELECT * FROM ens.metadata;

-- CREATE TEMP TABLE uniprot_orgi (
--  eg_id INTEGER REFERENCES genes(_id),
--  uni_id TEXT
-- );

-- CREATE INDEX cTEMP25 ON uniprot_orgi(eg_id);

-- INSERT INTO uniprot_orgi
--  SELECT gene_id, protein_accession
--  FROM genesrc.gene2accession 
--  WHERE tax_id = "7227" 
--  AND protein_accession GLOB '[A-Z]*'  
--  AND length(protein_accession) = 6;

-- CREATE TABLE uniprot (
--  _id INTEGER REFERENCES genes(_id),
--  uniprot_id TEXT
-- );

-- INSERT INTO uniprot
--  SELECT DISTINCT eg._id, u.uniprot_id 
--  FROM ens.fly_eg2uniprot as u, genes as eg 
--  WHERE u.gene_id = eg.gene_id;

-- -- DROP TABLE uniprot_orgi;
-- -- VACUUM;
-- CREATE INDEX c25 ON uniprot(_id);

-- DETACH DATABASE ens;


ATTACH DATABASE 'genesrc.sqlite' AS genesrc;

CREATE TABLE uniprot (
 _id INTEGER REFERENCES genes(_id),
 uniprot_id TEXT
);

INSERT INTO uniprot
 SELECT DISTINCT r._id, up.uniprot_id 
 FROM refseq_uniprot as up, refseq as r 
 WHERE up.refseq_id = r.accession;

CREATE INDEX c25 ON uniprot(_id);

DETACH DATABASE genesrc;