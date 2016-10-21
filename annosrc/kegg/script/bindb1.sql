.echo ON
ATTACH DATABASE "genome_src.sqlite" AS genome;

INSERT INTO metadata
 SELECT * FROM genome.metadata;

--CREATE TABLE pathway2gene AS
-- SELECT pathway_id as pathway_id, gene_id as gene_id
-- FROM genome.hsa; 

CREATE TABLE pathway2gene (
  pathway_id CHAR(8) NOT NULL,                  -- KEGG pathway long ID
  gene_or_orf_id VARCHAR(20) NOT NULL                  -- Entrez Gene or ORF ID
);

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.hsa; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.ath ; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.dme; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.mmu; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.rno; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.sce; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.pfa; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.dre; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.eco; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.ecs; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.cfa; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.bta; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.cel; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.ssc; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.gga; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.mcc; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.xla; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.aga; 

INSERT INTO pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.ptr; 


-- CREATE INDEX p1 on  pathway2gene(gene_or_orf_id);
CREATE INDEX Ipathway2gene ON pathway2gene (gene_or_orf_id);



CREATE TABLE ath_NCBI_pathway2gene (
  pathway_id CHAR(8) NOT NULL,                  -- KEGG pathway long ID
  gene_or_orf_id VARCHAR(20) NOT NULL                  -- Entrez Gene or ORF ID
);


INSERT INTO ath_NCBI_pathway2gene 
 SELECT pathway_id, gene_id 
 FROM genome.ath_ncbi; 


-- CREATE INDEX p1 on  pathway2gene(gene_or_orf_id);
CREATE INDEX ath_NCBI_Ipathway2gene ON ath_NCBI_pathway2gene (gene_or_orf_id);