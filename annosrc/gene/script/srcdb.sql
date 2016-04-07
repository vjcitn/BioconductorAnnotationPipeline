.echo ON
.separator \t

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);

CREATE TABLE gene2go (
        tax_id INTEGER NOT NULL,
        gene_id INTEGER NOT NULL,
        go_id TEXT NOT NULL,
        evidence TEXT,
        go_qualifier TEXT,
        go_description TEXT,
        pubmed_id TEXT,
	category TEXT
);
.import gene2go gene2go
CREATE INDEX gg1 on gene2go(gene_id);
CREATE INDEX gg2 on gene2go(tax_id);

CREATE TABLE gene2pubmed (
        tax_id INTEGER NOT NULL,
        gene_id INTEGER NOT NULL,
        pubmed_id INTEGER
);
.import gene2pubmed gene2pubmed
CREATE INDEX gp1 on gene2pubmed(gene_id);
CREATE INDEX gp2 on gene2pubmed(tax_id);

CREATE TABLE gene2accession (
        tax_id INTEGER NOT NULL,
        gene_id INTEGER NOT NULL,
        status TEXT,
        rna_accession TEXT,
        rna_gi INTEGER,
        protein_accession TEXT,
        protein_gi INTEGER,
        genomic_dna_accession TEXT,
        genomic_dna_gi INTEGER,
        genomic_start INTEGER,
        genomic_end INTEGER,
        orientation TEXT,
        assembly TEXT,
	mature_peptide_accession TEXT,
	mature_peptide_gi INTEGER,
        default_gene_symbol TEXT	 
);
.import gene2accession gene2accession
CREATE INDEX ga1 on gene2accession(gene_id);
CREATE INDEX ga2 on gene2accession(tax_id);

CREATE TABLE gene2refseq (
        tax_id INTEGER NOT NULL,
        gene_id INTEGER NOT NULL,
        status TEXT,
        rna_accession TEXT,
        rna_gi INTEGER,
        protein_accession TEXT,
        protein_gi INTEGER,
        genomic_dna_accession TEXT,
        genomic_dna_gi INTEGER,
        genomic_start INTEGER,
        genomic_end INTEGER,
        orientation TEXT,
        assembly TEXT,
	mature_peptide_accession TEXT,
	mature_peptide_gi INTEGER,
        default_gene_symbol TEXT
);
.import gene2refseq gene2refseq
CREATE INDEX gr1 on gene2refseq(gene_id);
CREATE INDEX gr2 on gene2refseq(tax_id);

CREATE TABLE gene2unigene (
        gene_id INTEGER NOT NULL,
        unigene_id TEXT
);
.import gene2unigene gene2unigene
CREATE INDEX gu1 on gene2unigene(gene_id);
CREATE INDEX gu2 on gene2unigene(unigene_id);

CREATE TABLE gene_info (
        tax_id INTEGER NOT NULL,
        gene_id INTEGER NOT NULL,
        symbol TEXT,
        locus_tag TEXT,
        synonyms TEXT,
        dbXrefs TEXT,
        chromosome TEXT,
        map_location TEXT,
        description TEXT,
        gene_type TEXT,
        nomenclature_symbol TEXT,
        nomenclature_name TEXT,
        nomenclature_status TEXT,
	other_designations TEXT
);
.import gene_info gene_info
CREATE INDEX gi1 on gene_info(gene_id);
CREATE INDEX gi2 on gene_info(tax_id);

CREATE TABLE gene_map_location (
	gene_id INTEGER NOT NULL,
	map_location TEXT
);
.import gene_cytogenetic.tab gene_map_location
CREATE INDEX gm1 on gene_map_location(gene_id);

CREATE TABLE gene_chromosome (
	gene_id INTEGER NOT NULL,
	chromosome TEXT
);
.import gene_chromosome.tab gene_chromosome
CREATE INDEX gc1 on gene_chromosome(gene_id);

CREATE TABLE gene_synonym (
	gene_id INTEGER NOT NULL,
	synonym TEXT
);
.import gene_synonym.tab gene_synonym
CREATE INDEX gs1 on gene_synonym(gene_id);

CREATE TABLE gene_dbXref (
	gene_id INTEGER NOT NULL,
	dbXref TEXT
);
.import gene_dbXrefs.tab gene_dbXref
CREATE INDEX gx1 on gene_dbXref(gene_id);

CREATE TABLE mim2gene (
        mim_id INTEGER NOT NULL,
        gene_id INTEGER NOT NULL,
        relation_type TEXT,
	mim_source TEXT,
	MedGenCUI TEXT,
	comment TEXT
);
.import mim2gene_medgen mim2gene
CREATE INDEX mg1 on mim2gene(gene_id);


CREATE TABLE refseq_uniprot (
        refseq_id TEXT NOT NULL,
        uniprot_id TEXT NOT NULL
);
.import gene_refseq_uniprotkb_collab  refseq_uniprot
CREATE INDEX rsUpkb1 on refseq_uniprot(refseq_id);

ANALYZE;
