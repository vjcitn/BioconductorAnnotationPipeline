.echo ON
ATTACH DATABASE 'tairsrc.sqlite' AS tair;

CREATE TABLE genes (
 id INTEGER PRIMARY KEY,
 gene_id TEXT
);

INSERT INTO genes (gene_id)
 SELECT DISTINCT locus
 FROM tair.affy_AG;

CREATE INDEX ge1 ON genes(gene_id);

CREATE TEMP TABLE match_count (
 probe_id TEXT,
 is_multiple INTEGER
);

INSERT INTO match_count 
 SELECT array_element_name, 
        CASE WHEN count(DISTINCT locus)>1 THEN 1 ELSE 0 END
 FROM tair.affy_AG
 GROUP BY array_element_name;

CREATE INDEX mc1 ON match_count(probe_id);

CREATE TABLE probes (
 id INTEGER REFERENCES genes(id),
 probe_id TEXT,
 is_multiple INTEGER
);

INSERT INTO probes
 SELECT DISTINCT g.id as id, p.probe_id, p.is_multiple as is_multiple
 FROM tair.affy_AG as m, match_count as p, genes as g
 WHERE g.gene_id=m.locus AND m.array_element_name=p.probe_id
 ORDER BY is_multiple, id;

CREATE INDEX pr1 ON probes(id);
CREATE INDEX pr2 ON probes(probe_id);

CREATE TABLE gene_info (
 id INTEGER REFERENCES genes(id),
 gene_name TEXT,
 symbol TEXT,
 chromosome TEXT
);

INSERT INTO gene_info
 SELECT DISTINCT g.id, s.description, a.gene_symbol, s.chromosome
 FROM tair.sequenced_genes as s, tair.gene_aliases as a, genes as g
 WHERE g.gene_id=s.locus AND s.locus=a.locus;

CREATE INDEX gi1 ON gene_info(id);

-- comment out because merged into 'gene_info' table
--CREATE TABLE chromosomes (
-- id INTEGER REFERENCES genes(id),
-- chromosome TEXT
--);
--
--INSERT INTO chromosomes
-- SELECT DISTINCT g.id, i.chromosome
-- FROM tair.sequenced_genes as i, genes as g
-- WHERE g.gene_id=i.locus;
--
--CREATE INDEX c5 ON chromosomes(id);

CREATE TABLE chromosome_locations (
 id INTEGER REFERENCES genes(id),
 chromosome TEXT,
 start_location INTEGER
);

INSERT INTO chromosome_locations 
 SELECT g.id, 
	v.chromosome,
	CASE WHEN v.orientation='F' THEN v.start ELSE (0-v.start) END	
 FROM genes as g CROSS JOIN tair.sequenced_genes as s CROSS JOIN tair.sv_gene as v
 WHERE g.gene_id=s.locus AND s.gene_name=v.gene_name;

CREATE INDEX cl1 ON chromosome_locations(id);

CREATE TABLE aracyc (
 id INTEGER REFERENCES genes(id),
 ec_number TEXT,
 pathway_name TEXT
);

INSERT INTO aracyc 
 SELECT g.id, a.enzyme_name, a.pathway_name
 FROM genes as g CROSS JOIN tair.aracyc as a
 WHERE g.gene_id=a.locus;

CREATE INDEX ar1 ON aracyc(id);

CREATE TABLE pubmed (
 id INTEGER REFERENCES genes(id),
 pubmed_id TEXT
);

INSERT INTO pubmed
 SELECT g.id, i.pubmed_id
 FROM genes as g, tair.pmid as i
 WHERE g.gene_id=i.locus;

CREATE INDEX pu1 ON pubmed(id);
 
CREATE TABLE go_bp (
 id INTEGER REFERENCES genes(id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_bp
 SELECT g.id, i.go_id, i.evidence
 FROM genes as g, tair.go as i
 WHERE i.locus=g.gene_id AND i.category='proc';

CREATE INDEX go1 ON go_bp(id);
CREATE INDEX go4 ON go_bp(go_id);

CREATE TABLE go_mf (
 id INTEGER REFERENCES genes(id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_mf
 SELECT g.id, i.go_id, i.evidence
 FROM genes as g, tair.go as i
 WHERE i.locus=g.gene_id AND i.category='func';

CREATE INDEX go2 ON go_mf(id);
CREATE INDEX go5 ON go_mf(go_id);

CREATE TABLE go_cc (
 id INTEGER REFERENCES genes(id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_cc
 SELECT g.id, i.go_id, i.evidence
 FROM genes as g, tair.go as i
 WHERE i.locus=g.gene_id AND i.category='comp';

CREATE INDEX go3 ON go_cc(id);
CREATE INDEX go6 ON go_cc(go_id);

