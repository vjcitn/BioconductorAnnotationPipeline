.echo ON
.mode tabs

-- a single inparanoid DB with all needed tables inside...

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);


CREATE TABLE alias (
 gene_id VARCHAR(25) NOT NULL,
 alias	 VARCHAR(25) NOT NULL
);
.import ALIAStable.txt alias

CREATE TABLE symbol (
 gene_id VARCHAR(25) UNIQUE NOT NULL,
 description VARCHAR(100) NOT NULL
);
.import SYMBOLtable.txt symbol

CREATE TEMP TABLE gotmp (
 gene_id VARCHAR(25) NOT NULL,		
 go_id VARCHAR(10) NOT NULL,		
 ontology VARCHAR(18) NOT NULL,		
--  _GO_ID VARCHAR(10) NOT NULL,	
 GO_Term_Name VARCHAR(100) NOT NULL,	
 go_source VARCHAR(20) NOT NULL,
 evidence_code VARCHAR(3) NOT NULL
-- lc_evidence_code VARCHAR(3) NOT NULL
--  _Evidence_code VARCHAR(3) NOT NULL
);
.import GOtable.txt gotmp


CREATE TABLE go (
 gene_id VARCHAR(25) NOT NULL,
 go_id VARCHAR(10) NOT NULL,
 ontology VARCHAR(18) NOT NULL,
--  _GO_ID VARCHAR(10) NOT NULL,
 GO_Term_Name VARCHAR(100) NOT NULL,
 go_source VARCHAR(20) NOT NULL,
 evidence_code VARCHAR(3) NOT NULL
-- lc_evidence_code VARCHAR(3) NOT NULL
--  _Evidence_code VARCHAR(3) NOT NULL
);


INSERT INTO go 
 SELECT 
--   rtrim(gene_id, 'null'),
  gene_id,
  go_id, 
  ontology, 
--   _GO_ID, 
  GO_Term_Name, 
  go_source, 
  evidence_code 
--  lc_evidence_code
--   _Evidence_code
 FROM gotmp;

ANALYZE;

