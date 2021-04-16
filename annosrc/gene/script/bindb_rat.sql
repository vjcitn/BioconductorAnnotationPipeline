.echo ON

ATTACH DATABASE 'genesrc.sqlite' AS genesrc;

INSERT INTO metadata
 SELECT * FROM genesrc.metadata;

CREATE TABLE accession (
 gene_id INTEGER,
 accession TEXT
);

INSERT INTO accession
 SELECT min(gene_id), rna_accession
 FROM genesrc.gene2accession 
 WHERE  tax_id='10116' AND rna_accession != '-'
 GROUP BY rna_accession
UNION
 SELECT min(gene_id), protein_accession
 FROM genesrc.gene2accession 
 WHERE tax_id='10116'  AND protein_accession != '-'
 GROUP BY protein_accession;

CREATE INDEX a1 ON accession(accession);

CREATE TABLE refseq (
 gene_id INTEGER,
 accession TEXT
);

INSERT INTO refseq
 SELECT min(gene_id), rna_accession
 FROM genesrc.gene2refseq 
 WHERE  tax_id='10116' AND rna_accession != '-'
 GROUP BY rna_accession
UNION
 SELECT min(gene_id), protein_accession
 FROM genesrc.gene2refseq 
 WHERE tax_id='10116'  AND protein_accession != '-'
 GROUP BY protein_accession;

CREATE INDEX r1 ON refseq(accession);

-- Removed as of BioC 3.13

-- CREATE TABLE unigene (
--  gene_id INTEGER,
--  unigene_id TEXT
-- );

-- INSERT INTO unigene 
--  SELECT min(gene_id), unigene_id 
--  FROM genesrc.gene2unigene
--  WHERE unigene_id LIKE 'Rn.%'
--  GROUP BY unigene_id;

-- CREATE INDEX u1 ON unigene(unigene_id);


CREATE TABLE EGList (gene_id TEXT NOT NULL, UNIQUE(gene_id));
INSERT INTO EGList SELECT DISTINCT gene_id FROM accession;
INSERT INTO EGList SELECT DISTINCT new FROM (
  SELECT r.gene_id new, e.gene_id old FROM refseq r 
  LEFT JOIN EGList e ON r.gene_id=e.gene_id) where old!=new;
-- INSERT INTO EGList SELECT DISTINCT new FROM (
--   SELECT u.gene_id new, e.gene_id old FROM unigene u 
--   LEFT JOIN EGList e ON u.gene_id=e.gene_id) where old!=new;


DETACH DATABASE genesrc;

ANALYZE;
