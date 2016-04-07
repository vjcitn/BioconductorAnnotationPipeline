.echo ON
.separator "\t"

DROP TABLE IF EXISTS affy_AG;
CREATE TABLE affy_AG(
  array_element_name TEXT NOT NULL,
  locus TEXT NOT NULL
) ;
.import affy_AG_array_elements1.txt affy_AG
CREATE INDEX ag1 on affy_AG(locus);
CREATE INDEX ag2 on affy_AG(array_element_name);

DROP TABLE IF EXISTS affy_ATH1;
CREATE TABLE affy_ATH1(
  array_element_name TEXT NOT NULL,
  locus TEXT NOT NULL
) ;
.import affy_ATH1_array_elements1.txt affy_ATH1
CREATE INDEX ath1 on affy_ATH1(locus);
CREATE INDEX ath2 on affy_ATH1(array_element_name);

DROP TABLE IF EXISTS aracyc;
CREATE TABLE aracyc (
  pathway_id TEXT,
  pathway_name TEXT,  -- eg. 'salicylate biosynthesis I'
  reaction_id TEXT,
  reaction_name TEXT, -- aka EC 'RXN-1981' but usually an ec number '2.6.1.5'
  protein_id TEXT, 
  enzyme_name TEXT,   -- aka enzyme name 'isochorismate synthase'
  locus TEXT,         -- aka locus name 'AT5G53970'
  locus_name TEXT
) ;
.import aracyc_dump1 aracyc
CREATE INDEX aracyc1 on aracyc(locus);

DROP TABLE IF EXISTS enzyme;
CREATE TABLE enzyme (
 locus TEXT,
 enzyme_name TEXT
);
-- .import locus_enzymes.txt enzyme
-- CREATE INDEX enzyme1 on enzyme(locus);
  
DROP TABLE IF EXISTS go;
CREATE TEMP TABLE tmp_go (
 locus TEXT,
 tair_acc TEXT,
 object_name TEXT,
 relationship TEXT,
 go_term TEXT,
 go_id TEXT,
 tair_keyword_id TEXT,
 category TEXT,
 goslim_term TEXT,
 evidence TEXT,
 description TEXT,
 evidence_with TEXT,
 reference TEXT,
 annotating_db TEXT,
 annotation_date TEXT
);
.import ATH_GO_GOSLIM.txt tmp_go
CREATE TABLE go (
 locus TEXT,
 tair_acc TEXT,
 object_name TEXT,
 relationship TEXT,
 go_term TEXT,
 go_id TEXT,
 tair_keyword_id TEXT,
 category TEXT,
 goslim_term TEXT,
 evidence TEXT,
 description TEXT,
 evidence_with TEXT,
 reference TEXT,
 annotating_db TEXT,
 annotation_date TEXT
);
INSERT INTO go 
 SELECT
  locus,
  replace(tair_acc,",",""),
  object_name,
  relationship,
  go_term,
  go_id,
  replace(tair_keyword_id,",",""),
  category,
  goslim_term,
  evidence,
  description,
  evidence_with,
  reference,
  annotating_db,
  annotation_date 
 FROM tmp_go;
CREATE INDEX go1 on go(category, locus);
CREATE INDEX go_id1 on go(go_id);


--DROP TABLE IF EXISTS est;
--CREATE TABLE est (
-- accession TEXT,
-- clone_name TEXT,
-- start INTEGER,
-- end INTEGER,
-- length INTEGER,
-- orientation TEXT,
-- locus TEXT
--);
--.import est.Assignment.Locus1 est
--CREATE INDEX est1 on est(locus);

DROP TABLE IF EXISTS gene_aliases;
CREATE TABLE gene_aliases (
 locus TEXT,
 gene_symbol TEXT
);
.import gene_aliases1 gene_aliases
CREATE INDEX alias1 on gene_aliases(locus);

DROP TABLE IF EXISTS pmid;
CREATE TABLE pmid (
 locus TEXT,
-- gene_name TEXT,
 tair_acc TEXT,
 pubmed_id TEXT NOT NULL
);
--.import LocusPublished1.txt pmid


DROP TABLE IF EXISTS sequenced_genest;
CREATE TABLE sequenced_genest (
-- locus TEXT,
 gene_name TEXT,
 coding TEXT,
 protein_name TEXT,
-- chromosome TEXT,
 description TEXT,
 associated_func TEXT
);
.import TAIR_sequenced_genes2 sequenced_genest
CREATE INDEX sg1 on sequenced_genest(gene_name);

DROP TABLE IF EXISTS sv_gene;
CREATE TABLE sv_gene (
 tair_acc TEXT,
 gene_name TEXT,
 start INTEGER,
 stop INTEGER,
 orientation TEXT,
 chromosome TEXT
);
.import sv_gene.data sv_gene
CREATE INDEX sv1 on sv_gene(gene_name); 

DROP TABLE IF EXISTS metadata;
CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

-- CREATE TABLE metadata (
--  name TEXT,
--  value TEXT
-- );

ANALYZE;

