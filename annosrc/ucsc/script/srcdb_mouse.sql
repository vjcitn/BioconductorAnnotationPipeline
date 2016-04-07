.echo ON
.separator \t

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);

CREATE TEMP TABLE refGene (
	bin TEXT,
	name TEXT,
	chrom TEXT,
	strand TEXT,
	txStart INTEGER,
	txEnd INTEGER,
	cdsStart INTEGER,
	cdsEnd INTEGER,
	exonCount INTEGER,
	exonStarts TEXT,
	exonEnds TEXT,
	id TEXT,
	name2 TEXT,
	cdsStartStat TEXT,
	cdsEndStat TEXT,
	exonFrames TEXT
);
.import refGene.txt refGene
CREATE INDEX g1 on refGene(name);

CREATE TEMP TABLE refLink (
	name TEXT,
	product TEXT,
	mrnaAcc TEXT,
	protAcc TEXT,
	geneName TEXT,
	prodName TEXT,
	locusLinkId TEXT,
	omimId TEXT
);
.import refLink.txt refLink 
CREATE INDEX l1 on refLink(mrnaAcc);

CREATE TABLE chrloc AS
 SELECT DISTINCT l.locusLinkId as gene_id, 
	substr(g.chrom, 4, length(g.chrom)-3) as chrom,
	CASE WHEN g.strand="+" THEN g.txStart ELSE (0-g.txStart) END as start,
	CASE WHEN g.strand="+" THEN g.txEnd ELSE (0-g.txEnd) END as end
 FROM refLink as l, refGene as g
 WHERE l.mrnaAcc=g.name;
CREATE INDEX c1 on chrloc(chrom);

CREATE TABLE cytoBand (
        chrom TEXT,
        chromStart INTEGER,
        chromEnd INTEGER,
        cytoBandName TEXT,
        gieStain TEXT,
        PRIMARY KEY (chrom, chromStart)
);
.import cytoBand.txt cytoBand

CREATE TABLE chrlength (
       chr TEXT PRIMARY KEY,
       length INTEGER,
       path TEXT
);
.import chromInfo.txt chrlength

-- CREATE TABLE ucsc_id (
-- 	ucsc_id TEXT,
-- 	gene_id TEXT
-- );
-- .import knownToLocusLink.txt ucsc_id 
