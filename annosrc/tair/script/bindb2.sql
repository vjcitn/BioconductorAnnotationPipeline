.echo ON
ATTACH DATABASE 'kegg0.sqlite' AS keggsrc;

CREATE TABLE kegg (
 id INTEGER REFERENCES genes(id),
 kegg_id TEXT
);

INSERT INTO kegg
 SELECT g.id, substr(p.pathway_id, -5, 5)
 FROM keggsrc.pathway2gene as p CROSS JOIN genes as g
 WHERE g.gene_id=upper(p.gene_or_orf_id);

CREATE INDEX k1 ON kegg(id);

DETACH DATABASE keggsrc;
ATTACH DATABASE 'kegg_ec.sqlite' AS ecsrc;

CREATE TABLE ec (
 id INTEGER REFERENCES genes(id),
 ec_number TEXT
);

INSERT INTO ec
 SELECT g.id, e.ec_id
 FROM ecsrc.ath_ec as e CROSS JOIN genes as g
 WHERE g.gene_id=upper(e.gene_or_orf_id);

CREATE INDEX e1 ON ec(id);

DETACH DATABASE ecsrc;
ATTACH DATABASE 'go0.sqlite' AS gosrc;

CREATE TABLE go_bp_all (
 id INTEGER REFERENCES sgd(id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_bp_all
 SELECT g.id, t.go_id, g.evidence
 FROM gosrc.go_bp_offspring as t, 
        go_bp as g
 WHERE g.go_id=t.offspring_go_id; 

INSERT INTO go_bp_all
 SELECT id, go_id, evidence
 FROM go_bp;

CREATE INDEX goa1 on go_bp_all(id);

CREATE TABLE go_mf_all (
 id INTEGER REFERENCES sgd(id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_mf_all
 SELECT g.id, t.go_id, g.evidence
 FROM gosrc.go_mf_offspring as t, 
        go_mf as g
 WHERE g.go_id=t.offspring_go_id; 

INSERT INTO go_mf_all
 SELECT id, go_id, evidence
 FROM go_mf;

CREATE INDEX goa2 on go_mf_all(id);

CREATE TABLE go_cc_all (
 id INTEGER REFERENCES sgd(id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_cc_all
 SELECT g.id, t.go_id, g.evidence
 FROM gosrc.go_cc_offspring as t, 
        go_cc as g
 WHERE g.go_id=t.offspring_go_id; 

INSERT INTO go_cc_all
 SELECT id, go_id, evidence
 FROM go_cc;

CREATE INDEX goa3 on go_cc_all(id);

DETACH DATABASE gosrc;

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255),
  UNIQUE(table_name)
);

-- CREATE TABLE metadata (
--  table_name TEXT,
--  row_count INTEGER,
--  UNIQUE(table_name)
-- );

BEGIN TRANSACTION;

COMMIT TRANSACTION;

ANALYZE;
