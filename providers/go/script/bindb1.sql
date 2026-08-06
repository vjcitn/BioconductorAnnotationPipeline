.echo ON
ATTACH DATABASE 'gosrcsrc.sqlite' AS gosrc;

CREATE TABLE metadata (
	name TEXT,
	value TEXT
);

INSERT INTO metadata
 SELECT * FROM gosrc.metadata;

CREATE TABLE go_ontology (
	ontology_id INTEGER PRIMARY KEY,
	term_type TEXT,
	ontology TEXT	
);

INSERT INTO go_ontology VALUES(1, 'universal', 'universal');
INSERT INTO go_ontology VALUES(2, 'biological_process', 'BP');
INSERT INTO go_ontology VALUES(3, 'molecular_function', 'MF');
INSERT INTO go_ontology VALUES(4, 'cellular_component', 'CC');

CREATE TABLE go2go_evidence (
	relationship_type TEXT,
	evidence_id INTEGER PRIMARY KEY
);

INSERT INTO go2go_evidence 
 SELECT r.name AS relationship_type, r.id AS evidence_id
 FROM gosrc.term AS r
 WHERE r.id IN 
	(SELECT DISTINCT relationship_type_id FROM gosrc.term2term);

--real_goterm contains go terms whose term_type are list in go_ontology
--not synonym here, I think

CREATE TEMP TABLE real_goterm AS
 SELECT t.id AS id, t.name AS name, o.ontology_id AS term_type, 
	t.acc AS acc, 
	t.is_obsolete AS is_obsolete
 FROM go_ontology as o CROSS JOIN gosrc.term AS t
 WHERE  t.term_type=o.term_type;

CREATE INDEX rgt1 on real_goterm(id);

CREATE TABLE go_term (
	_id INTEGER PRIMARY KEY,
	go_id TEXT,
	term TEXT,
	ontology_id INTEGER REFERENCES go_ontology(ontology_id),
	definition TEXT
);

INSERT INTO go_term 
 SELECT DISTINCT t.id as _id, t.acc, t.name, t.term_type as term_type,
	d.term_definition 
 FROM real_goterm AS t LEFT OUTER JOIN gosrc.term_definition AS d
	on t.id=d.term_id
 WHERE t.is_obsolete=0
 ORDER BY term_type, _id;

CREATE INDEX gt1 on go_term(_id);
CREATE INDEX gt3 on go_term(ontology_id, go_id);
CREATE INDEX gt0 on go_term(go_id);

CREATE TABLE go_obsolete (
	go_id TEXT,
	term TEXT,
	ontology_id INTEGER REFERENCES go_ontology(ontology_id),
	definition TEXT
);

-- CREATE TABLE go_obsolete (
-- 	_id INTEGER PRIMARY KEY,
-- 	go_id TEXT,
-- 	term TEXT,
-- 	ontology_id INTEGER REFERENCES go_ontology(ontology_id),
-- 	definition TEXT
-- );

INSERT INTO go_obsolete
 SELECT DISTINCT t.acc, t.name, t.term_type,
	d.term_definition
 FROM real_goterm AS t LEFT OUTER JOIN gosrc.term_definition AS d
	on t.id=d.term_id
 WHERE t.is_obsolete=1
 ORDER BY term_type, term_id;

-- INSERT INTO go_obsolete
--  SELECT DISTINCT t.id as _id, t.acc, t.name, t.term_type,
-- 	d.term_definition
--  FROM real_goterm AS t LEFT OUTER JOIN gosrc.term_definition AS d
-- 	on t.id=d.term_id
--  WHERE t.is_obsolete=1
--  ORDER BY term_type, _id;

--CREATE INDEX gt2 on go_obsolete(_id);

CREATE TABLE go_synonym (
	_id INTEGER REFERENCES go_term(_id),
	synonym TEXT,
	secondary TEXT
);

INSERT INTO go_synonym
 SELECT term_id, term_synonym, acc_synonym
 FROM gosrc.term_synonym 
 WHERE term_id IN (SELECT id from real_goterm)
 ORDER BY term_id;

UPDATE go_synonym
  SET synonym=NULL
  WHERE synonym='\N';
UPDATE go_synonym
  SET secondary=NULL
  WHERE secondary='\N';

CREATE INDEX gs1 on go_synonym(_id);

--go_offspring is a subset of graph_path
--we remove obsolete terms, none bp,mf,cc,universal terms, etc

CREATE TEMP TABLE go_offspring AS 
 SELECT DISTINCT g.term1_id AS id, g.term2_id AS _offspring_id,
	t1.term_type AS ontology 
 FROM real_goterm AS t1, real_goterm AS t2, gosrc.graph_path AS g 
 WHERE t1.id=g.term1_id and g.term2_id=t2.id and g.distance>0
	and t1.is_obsolete=0 and t2.is_obsolete=0;

CREATE TABLE go_bp_offspring (
	_id INTEGER REFERENCES go_term(_id),
	_offspring_id INTEGER REFERENCES go_term(_id)
);
 
INSERT INTO go_bp_offspring  
 SELECT id, _offspring_id 
 FROM go_offspring 
 WHERE ontology=2
 ORDER BY id;

CREATE INDEX of1 on go_bp_offspring(_id, _offspring_id);
CREATE INDEX of2 on go_bp_offspring(_offspring_id, _id);

CREATE TABLE go_mf_offspring (
	_id INTEGER REFERENCES go_term(_id),
	_offspring_id INTEGER REFERENCES go_term(_id)
);
 
INSERT INTO go_mf_offspring 
 SELECT id, _offspring_id 
 FROM go_offspring 
 WHERE ontology=3
 ORDER BY id;

CREATE INDEX of3 on go_mf_offspring(_id, _offspring_id);
CREATE INDEX of4 on go_mf_offspring(_offspring_id, _id);

CREATE TABLE go_cc_offspring (
	_id INTEGER REFERENCES go_term(_id),
	_offspring_id INTEGER REFERENCES go_term(_id)
);
 
INSERT INTO go_cc_offspring 
 SELECT id, _offspring_id  
 FROM go_offspring 
 WHERE ontology=4
 ORDER BY id;

CREATE INDEX of5 on go_cc_offspring(_id, _offspring_id);
CREATE INDEX of6 on go_cc_offspring(_offspring_id, _id);

CREATE TEMP TABLE go_parents AS 
 SELECT DISTINCT g.term2_id AS id, g.term1_id AS _parent_id, 
	g.relationship_type_id AS relationship_type, t2.term_type AS ontology
 FROM real_goterm AS t1, real_goterm AS t2, 
 	gosrc.term2term AS g 
 WHERE t2.id=g.term1_id and g.term2_id=t1.id
	and t1.is_obsolete=0 and t2.is_obsolete=0;

CREATE TABLE go_bp_parents ( 
	_id INTEGER REFERENCES go_term(_id),
	_parent_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES go2go_evidence(evidence_id)
);

INSERT INTO go_bp_parents
 SELECT id, _parent_id, relationship_type 
 FROM go_parents 
 WHERE ontology=2
 ORDER BY id;

CREATE INDEX pa1 on go_bp_parents(_id, _parent_id);
CREATE INDEX pa2 on go_bp_parents(_parent_id, _id);

CREATE TABLE go_mf_parents ( 
	_id INTEGER REFERENCES go_term(_id),
	_parent_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES go2go_evidence(evidence_id)
);

INSERT INTO go_mf_parents  
 SELECT id, _parent_id, relationship_type 
 FROM go_parents 
 WHERE ontology=3
 ORDER BY id;

CREATE INDEX pa3 on go_mf_parents(_id, _parent_id);
CREATE INDEX pa4 on go_mf_parents(_parent_id, _id);

CREATE TABLE go_cc_parents ( 
	_id INTEGER REFERENCES go_term(_id),
	_parent_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES go2go_evidence(evidence_id)
);

INSERT INTO go_cc_parents 
 SELECT id, _parent_id, relationship_type 
 FROM go_parents 
 WHERE ontology=4
 ORDER BY id;

CREATE INDEX pa5 on go_cc_parents(_id, _parent_id);
CREATE INDEX pa6 on go_cc_parents(_parent_id, _id);

ANALYZE go_term;

