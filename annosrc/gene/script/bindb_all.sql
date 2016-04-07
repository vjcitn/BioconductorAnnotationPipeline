.echo ON

ATTACH DATABASE 'genesrc.sqlite' AS genesrc;

CREATE TABLE metadata (
        name TEXT,
        value TEXT
);

INSERT INTO metadata
 SELECT * FROM genesrc.metadata;

CREATE TABLE accession (
 gene_id INTEGER,
 accession TEXT
);

INSERT INTO accession
 SELECT min(gene_id), rna_accession
 FROM genesrc.gene2accession 
 WHERE  rna_accession != '-'
 GROUP BY rna_accession
UNION
 SELECT min(gene_id), protein_accession
 FROM genesrc.gene2accession 
 WHERE protein_accession != '-'
 GROUP BY protein_accession;

CREATE INDEX a1 ON accession(accession);

CREATE TABLE refseq (
 gene_id INTEGER,
 accession TEXT
);

INSERT INTO refseq
 SELECT min(gene_id), rna_accession
 FROM genesrc.gene2refseq 
 WHERE  rna_accession != '-'
 GROUP BY rna_accession
UNION
 SELECT min(gene_id), protein_accession
 FROM genesrc.gene2refseq 
 WHERE protein_accession != '-'
 GROUP BY protein_accession;

CREATE INDEX r1 ON refseq(accession);

DETACH DATABASE genesrc;

ANALYZE;
