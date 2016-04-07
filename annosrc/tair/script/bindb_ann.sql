.echo ON
ATTACH DATABASE 'tairsrc.sqlite' AS tair;

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

-- CREATE TABLE metadata (
--         name TEXT,
--         value TEXT
-- );

INSERT INTO metadata
 SELECT * FROM tair.metadata;

INSERT INTO metadata (name,value) VALUES ('CENTRALID','TAIR');
INSERT INTO metadata (name,value) VALUES ('TAXID','3702');

CREATE TABLE genes (
 _id INTEGER PRIMARY KEY,
 gene_id TEXT
);

INSERT INTO genes (gene_id)
 SELECT DISTINCT locus
 FROM tair.sequenced_genes;

CREATE INDEX ge1 ON genes(gene_id);

CREATE TABLE gene_info (
 _id INTEGER REFERENCES genes(_id),
 gene_name TEXT,
 symbol TEXT,
 chromosome TEXT
);

INSERT INTO gene_info
 SELECT DISTINCT i._id, i.description, a.gene_symbol, i.chromosome
 FROM (SELECT g._id AS _id, s.description AS description, 
		s.chromosome AS chromosome, s.locus AS locus
	FROM tair.sequenced_genes as s, genes as g
	WHERE s.locus=g.gene_id) AS i
 LEFT OUTER JOIN
	tair.gene_aliases AS a
 ON i.locus=a.locus;

UPDATE gene_info
 SET chromosome=NULL WHERE chromosome='';

UPDATE gene_info
 SET gene_name=NULL WHERE gene_name='';

CREATE INDEX gi1 ON gene_info(_id);

-- comment out because merged into 'gene_info' table
--CREATE TABLE chromosomes (
-- _id INTEGER REFERENCES genes(_id),
-- chromosome TEXT
--);
--
--INSERT INTO chromosomes
-- SELECT DISTINCT g._id, i.chromosome
-- FROM tair.sequenced_genes as i, genes as g
-- WHERE g.gene_id=i.locus;
--
--CREATE INDEX c5 ON chromosomes(_id);

CREATE TABLE chromosome_locations (
 _id INTEGER REFERENCES genes(_id),
 chromosome TEXT,
 start_location INTEGER,
 end_location INTEGER
);

INSERT INTO chromosome_locations 
 SELECT g._id, 
	v.chromosome,
	CASE WHEN v.orientation='F' THEN v.start ELSE (0-v.start) END,	
	CASE WHEN v.orientation='F' THEN v.stop ELSE (0-v.stop) END	
 FROM genes as g CROSS JOIN tair.sequenced_genes as s CROSS JOIN tair.sv_gene as v
 WHERE g.gene_id=s.locus AND s.gene_name=v.gene_name;

CREATE INDEX cl1 ON chromosome_locations(_id);

CREATE TABLE aracyc (
 _id INTEGER REFERENCES genes(_id),
 pathway_name TEXT
);

INSERT INTO aracyc 
 SELECT g._id, a.pathway_name
 FROM genes as g CROSS JOIN tair.aracyc as a
 WHERE g.gene_id=a.locus;

CREATE INDEX ar1 ON aracyc(_id);

CREATE TABLE enzyme (
 _id INTEGER REFERENCES genes(_id),
 ec_name TEXT
);

INSERT INTO enzyme
 SELECT g._id, a.enzyme_name
 FROM genes as g CROSS JOIN tair.enzyme as a
 WHERE g.gene_id=a.locus AND enzyme_name != 'unknown';

-- DELETE FROM enzyme where locus="Gene";
--Remove duplicate rows
DELETE FROM enzyme 
 WHERE rowid NOT IN (
  SELECT rowid FROM enzyme 
  GROUP BY _id, ec_name 
  HAVING min(rowid));


CREATE INDEX en1 ON enzyme(_id);

CREATE TABLE pubmed (
 _id INTEGER REFERENCES genes(_id),
 pubmed_id TEXT
);

INSERT INTO pubmed
 SELECT g._id, i.pubmed_id
 FROM genes as g, tair.pmid as i
 WHERE g.gene_id=i.locus AND i.pubmed_id != '<null>';

CREATE INDEX pu1 ON pubmed(_id);


ATTACH DATABASE 'GO.sqlite' AS goterms;
 
CREATE TABLE go_bp (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_bp
 SELECT g._id, i.go_id, i.evidence
 FROM genes as g, tair.go as i, goterms.go_term as go
--  WHERE i.locus=g.gene_id AND i.category='proc';
 WHERE i.locus=g.gene_id AND i.go_id=go.go_id AND go.ontology='BP';

CREATE INDEX go1 ON go_bp(_id);
CREATE INDEX go4 ON go_bp(go_id);

CREATE TABLE go_mf (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_mf
 SELECT g._id, i.go_id, i.evidence
 FROM genes as g, tair.go as i, goterms.go_term as go
--  WHERE i.locus=g.gene_id AND i.category='func';
 WHERE i.locus=g.gene_id AND i.go_id=go.go_id AND go.ontology='MF';

CREATE INDEX go2 ON go_mf(_id);
CREATE INDEX go5 ON go_mf(go_id);

CREATE TABLE go_cc (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_cc
 SELECT g._id, i.go_id, i.evidence
 FROM genes as g, tair.go as i, goterms.go_term as go
--  WHERE i.locus=g.gene_id AND i.category='comp';
 WHERE i.locus=g.gene_id AND i.go_id=go.go_id AND go.ontology='CC';

CREATE INDEX go3 ON go_cc(_id);
CREATE INDEX go6 ON go_cc(go_id);

DETACH DATABASE tair;
DETACH DATABASE goterms;
ATTACH DATABASE 'keggsrc.sqlite' AS keggsrc;

INSERT INTO metadata
 SELECT * from keggsrc.metadata where name LIKE 'KEGGSOURCE%';

CREATE TABLE kegg (
 _id INTEGER REFERENCES genes(_id),
 path_id TEXT
);

INSERT INTO kegg
 SELECT g._id, substr(p.pathway_id, -5, 5)
 FROM keggsrc.pathway2gene as p CROSS JOIN genes as g
 WHERE g.gene_id=upper(p.gene_or_orf_id);

CREATE INDEX k1 ON kegg(_id);

CREATE TABLE ec (
 _id INTEGER REFERENCES genes(_id),
 ec_number TEXT
);

INSERT INTO ec
 SELECT g._id, e.ec_id
 FROM keggsrc.ath_ec as e CROSS JOIN genes as g
 WHERE g.gene_id=upper(e.gene_or_orf_id);

CREATE INDEX e1 ON ec(_id);

DETACH DATABASE keggsrc;
ATTACH DATABASE 'gosrc.sqlite' AS gosrc;


INSERT INTO metadata
 SELECT * from gosrc.metadata;

CREATE TABLE go_bp_all (
 _id INTEGER REFERENCES sgd(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_bp_all
 SELECT g._id, t.go_id, g.evidence
 FROM gosrc.go_bp_offspring as t, 
        go_bp as g
 WHERE g.go_id=t.offspring_go_id; 

INSERT INTO go_bp_all
 SELECT _id, go_id, evidence
 FROM go_bp;

CREATE INDEX goa1 on go_bp_all(_id);

CREATE TABLE go_mf_all (
 _id INTEGER REFERENCES sgd(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_mf_all
 SELECT g._id, t.go_id, g.evidence
 FROM gosrc.go_mf_offspring as t, 
        go_mf as g
 WHERE g.go_id=t.offspring_go_id; 

INSERT INTO go_mf_all
 SELECT _id, go_id, evidence
 FROM go_mf;

CREATE INDEX goa2 on go_mf_all(_id);

CREATE TABLE go_cc_all (
 _id INTEGER REFERENCES sgd(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_cc_all
 SELECT g._id, t.go_id, g.evidence
 FROM gosrc.go_cc_offspring as t, 
        go_cc as g
 WHERE g.go_id=t.offspring_go_id; 

INSERT INTO go_cc_all
 SELECT _id, go_id, evidence
 FROM go_cc;

CREATE INDEX goa3 on go_cc_all(_id);

DETACH DATABASE gosrc;




--Add in entrez gene and refseq (there is no ensembl for arabidopsis)
ATTACH DATABASE 'chipsrc_arabidopsisNCBI.sqlite' AS NCBIsrc;

INSERT INTO metadata
 SELECT * FROM NCBIsrc.metadata
 WHERE name LIKE "EGSOURCE%";


-- start by adding a table for entrez genes
CREATE TABLE entrez_genes (
  _id INTEGER NOT NULL,                             -- REFERENCES genes (which contains TAIR IDs)
  gene_id VARCHAR(15) NOT NULL,                     -- Entrez Gene ID
  FOREIGN KEY (_id) REFERENCES genes(_id)
);

INSERT INTO entrez_genes
 SELECT DISTINCT g._id, n.gene_id
 FROM (SELECT * FROM NCBIsrc.genes INNER JOIN NCBIsrc.tair USING(_id)) AS n,
        genes as g
 WHERE g.gene_id=n.tair_id;

CREATE INDEX eg1 on genes(_id);


--and refseq
CREATE TABLE refseq (
  _id INTEGER NOT NULL,                         -- REFERENCES genes (TAIR)
  accession CHAR(5) NOT NULL,                   -- refseq accession
  FOREIGN KEY (_id) REFERENCES genes(_id)
);

INSERT INTO refseq
 SELECT DISTINCT g._id, n.accession
 FROM (SELECT * FROM NCBIsrc.refseq INNER JOIN NCBIsrc.tair USING(_id)) AS n,
        genes as g
 WHERE g.gene_id=n.tair_id;

CREATE INDEX rs1 on refseq(_id);


DETACH DATABASE NCBIsrc;





CREATE TABLE map_counts (
 map_name TEXT,
 count INTEGER,
 UNIQUE(map_name)
);

BEGIN TRANSACTION;

INSERT INTO map_counts
 SELECT 'ACCNUM', count(DISTINCT _id)
 FROM genes;

INSERT INTO map_counts
 SELECT 'ARACYC', count(DISTINCT _id)
 FROM aracyc;

INSERT INTO map_counts
 SELECT 'CHRLOC', count(DISTINCT _id)
 FROM chromosome_locations;

INSERT INTO map_counts
 SELECT 'CHR', count(DISTINCT _id)
 FROM gene_info
 WHERE chromosome NOT NULL;

INSERT INTO map_counts
 SELECT 'ENTREZID', count(DISTINCT _id)
 FROM genes;

INSERT INTO map_counts
 SELECT 'ENZYME', count(DISTINCT _id)
 FROM enzyme;

INSERT INTO map_counts
 SELECT 'ENZYME2GENE', count(DISTINCT ec_name)
 FROM enzyme;

INSERT INTO map_counts
 SELECT 'GENENAME', count(DISTINCT _id)
 FROM gene_info
 WHERE gene_name NOT NULL;

INSERT INTO map_counts
 SELECT 'GO', count(DISTINCT _id)
 FROM (
        SELECT _id FROM go_bp UNION
        SELECT _id FROM go_mf UNION
        SELECT _id FROM go_cc
 );

INSERT INTO map_counts
 SELECT 'GO2ALLGENES', count(go_id)
 FROM (SELECT DISTINCT go_id FROM go_bp_all UNION
        SELECT DISTINCT go_id FROM go_mf_all UNION
        SELECT DISTINCT go_id FROM go_cc_all);

INSERT INTO map_counts
 SELECT 'GO2GENE', count(go_id)
 FROM (SELECT DISTINCT go_id FROM go_bp UNION
        SELECT DISTINCT go_id FROM go_mf UNION
        SELECT DISTINCT go_id FROM go_cc);

INSERT INTO map_counts
 SELECT 'PATH', count(DISTINCT _id)
 FROM kegg;

INSERT INTO map_counts
 SELECT 'PATH2GENE', count(DISTINCT path_id)
 FROM kegg;

INSERT INTO map_counts
 SELECT 'PMID', count(DISTINCT _id)
 FROM pubmed;

INSERT INTO map_counts
 SELECT 'PMID2GENE', count(DISTINCT pubmed_id)
 FROM pubmed;

INSERT INTO map_counts
 SELECT 'SYMBOL', count(DISTINCT _id)
 FROM gene_info;

INSERT INTO map_counts
 SELECT 'TOTAL', count(*)
 FROM genes;

COMMIT TRANSACTION;

CREATE TABLE map_metadata (
 map_name TEXT,
 source_name TEXT,
 source_url TEXT,
 source_date TEXT
);

BEGIN TRANSACTION;

INSERT INTO map_metadata
 SELECT 'ACCNUM', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRGENEURL' AND
        m3.name='TAIRSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ARACYC', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRPATHURL' AND
        m3.name='TAIRSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CHRLOC', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRCHRURL' AND
        m3.name='TAIRSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CHR', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRGENEURL' AND
        m3.name='TAIRSOURCEDATE';

--INSERT INTO map_metadata
-- SELECT 'ENTREZID', m1.value, m2.value, m3.value
-- FROM metadata As m1, metadata As m2, metadata AS m3
-- WHERE m1.name='TAIRSOURCENAME' AND
--        m2.name='TAIRGENEURL' AND
--        m3.name='TAIRSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ENZYME', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRPATHURL' AND
        m3.name='TAIRSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ENZYME2GENE', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRPATHURL' AND
        m3.name='TAIRSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'GENENAME', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRGENEURL' AND
        m3.name='TAIRSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'GO', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='GOSOURCENAME' AND
        m2.name='GOSOURCEURL' AND
        m3.name='GOSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'GO2ALLGENES', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='GOSOURCENAME' AND
        m2.name='GOSOURCEURL' AND
        m3.name='GOSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'GO2GENE', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='GOSOURCENAME' AND
        m2.name='GOSOURCEURL' AND
        m3.name='GOSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PATH', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='KEGGSOURCENAME' AND
        m2.name='KEGGSOURCEURL' AND
        m3.name='KEGGSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PATH2GENE', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='KEGGSOURCENAME' AND
        m2.name='KEGGSOURCEURL' AND
        m3.name='KEGGSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PMID', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRPMIDURL' AND
        m3.name='TAIRSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PMID2GENE', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRPMIDURL' AND
        m3.name='TAIRSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'SYMBOL', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRSYMBOLURL' AND
        m3.name='TAIRSOURCEDATE';


INSERT INTO map_metadata
 SELECT 'agACCNUM', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRAGURL' AND
        m3.name='TAIRSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ath1121501ACCNUM', m1.value, m2.value, m3.value
 FROM metadata As m1, metadata As m2, metadata AS m3
 WHERE m1.name='TAIRSOURCENAME' AND
        m2.name='TAIRATHURL' AND
        m3.name='TAIRSOURCEDATE';

COMMIT TRANSACTION;

ANALYZE;
