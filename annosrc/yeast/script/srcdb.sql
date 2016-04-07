--for more details about orf_geneontology, gene_literature and gene_association, 
--go to
--ftp://genome-ftp.stanford.edu/pub/yeast/data_download/literature_curation/README
--and search for orf_geneontology.tab, gene_literature.tab and gene_association.sgd.gz 

.echo ON
.separator "\t"

DROP TABLE IF EXISTS gene_literature;
CREATE TABLE gene_literature(
  pubmed TEXT NOT NULL,
  citation TEXT NOT NULL,
  gene_name TEXT,
  orf TEXT,
  literature_topic TEXT NOT NULL,
  sgd TEXT NOT NULL
) ;

DROP TABLE IF EXISTS gene_association;
CREATE TABLE gene_association (
  db_name TEXT NOT NULL,
  sgd TEXT NOT NULL,
  gene_or_orf_name TEXT,
  not_qualifier TEXT,
  go_id TEXT NOT NULL,
  go_ref TEXT NOT NULL,
  evidence TEXT NOT NULL,
  with_or_from TEXT,
  go_category TEXT NOT NULL,
  gene_description TEXT,
  gene_synonym TEXT,
  object_type TEXT NOT NULL,
  taxon TEXT NOT NULL,
  annotation_date TEXT NOT NULL,
  assigned_by TEXT NOT NULL
) ;
.import gene_association.sgd gene_association
--attach the GO database from earlier.
ATTACH DATABASE 'GO.sqlite' AS go;
--then use that to get rid of things that are not in the GO.sqlite DB...
--this works to grab the rows
--SELECT count(DISTINCT go_id) FROM gene_association WHERE go_id NOT IN (SELECT DISTINCT go_id FROM go.go_term UNION SELECT DISTINCT go_id FROM go.go_obsolete);

--update version works (have to decide what fields we are going to rub out...)
--UPDATE gene_association SET go_id=NULL WHERE go_id NOT IN (SELECT DISTINCT go_id FROM go.go_term UNION SELECT DISTINCT go_id FROM go.go_obsolete);
--UPDATE gene_association SET go_ref=NULL WHERE go_id NOT IN (SELECT DISTINCT go_id FROM go.go_term UNION SELECT DISTINCT go_id FROM go.go_obsolete);
--UPDATE gene_association SET evidence=NULL WHERE go_id NOT IN (SELECT DISTINCT go_id FROM go.go_term UNION SELECT DISTINCT go_id FROM go.go_obsolete);
--UPDATE gene_association SET go_category=NULL WHERE go_id NOT IN (SELECT DISTINCT go_id FROM go.go_term UNION SELECT DISTINCT go_id FROM go.go_obsolete);

--But we might also really want these entire rows filtered OUT of here...
--Because of constraints, I HAVE to do it this way (ie. the fields above are not allowed to be null...
DELETE FROM gene_association WHERE go_id NOT IN (SELECT DISTINCT go_id FROM go.go_term UNION SELECT DISTINCT go_id FROM go.go_obsolete);

--then back to what normally should happen here...
CREATE INDEX go1 on gene_association(sgd);



  
DROP TABLE IF EXISTS sgd_features;

CREATE TABLE sgd_features (
  sgd TEXT PRIMARY KEY,
  feature_type TEXT NOT NULL,
  feature_qualifier TEXT,
  feature_name TEXT,
  standard_gene_name TEXT,
  alias TEXT,
  parent_feature_name TEXT,
  secondary_sgd TEXT,
  chromosome TEXT,
  start_coordinate INTEGER,
  stop_coordinate INTEGER,
  strand TEXT,
  genetic_position TEXT,
  coordinate_version TEXT,
  sequence_version TEXT,
  feature_description TEXT
) ;


-- DROP TABLE IF EXISTS registry_genenames;
-- CREATE TABLE registry_genenames (
--   gene_name TEXT,
--   alias	TEXT,
--   gene_description TEXT,
--   gene_product TEXT,
--   phenotype TEXT,
--   orf_name TEXT,
--   sgd TEXT PRIMARY KEY
-- ) ;
--.import registry.genenames.tab registry_genenames


DROP TABLE IF EXISTS gene2alias;
CREATE TABLE gene2alias (
  sgd TEXT NOT NULL,
  alias TEXT
) ;
.import gene2alias.tab gene2alias
CREATE INDEX ga1 on gene2alias(sgd);

DROP TABLE IF EXISTS domains;
CREATE TABLE domains (
  systematic_name TEXT,
  analysis_method TEXT,
  db_id TEXT,
  interpro TEXT
);
.import domains1.tab domains
CREATE INDEX d1 on domains(systematic_name);

DROP TABLE IF EXISTS reject_orf;
CREATE TABLE reject_orf (
  systematic_name TEXT,
  gene_name TEXT,
  RFC TEXT,
  length INTEGER,
  description TEXT
);
.import a.orf_decisions1.txt reject_orf
CREATE INDEX re1 ON reject_orf(systematic_name);

-- DROP TABLE IF EXISTS metadata;
-- CREATE TABLE metadata (
--  name TEXT,
--  value TEXT
-- );

