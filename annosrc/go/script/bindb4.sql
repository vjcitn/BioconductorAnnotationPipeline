.echo ON
ATTACH DATABASE 'gosrcsrc.sqlite' AS gosrc;

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

INSERT INTO metadata
 SELECT * FROM gosrc.metadata;

INSERT INTO metadata
 (name,value) VALUES ("Db type","GODb");

INSERT INTO metadata
 (name,value) VALUES ("package","AnnotationDbi");




CREATE TABLE go_ontology (
  ontology VARCHAR(9) PRIMARY KEY,               -- GO ontology (short label)	
  term_type VARCHAR(18) NOT NULL UNIQUE          -- GO ontology (full label)
);

INSERT INTO go_ontology VALUES('universal', 'universal');
INSERT INTO go_ontology VALUES( 'BP', 'biological_process');
INSERT INTO go_ontology VALUES( 'MF', 'molecular_function');
INSERT INTO go_ontology VALUES('CC', 'cellular_component');


--real_goterm contains go terms whose term_type are list in go_ontology
--not synonym here, I think

-- The "go_term" table is the central table.
CREATE TABLE go_term (
  _id INTEGER PRIMARY KEY,
  go_id CHAR(10) NOT NULL UNIQUE,               -- GO ID
  term VARCHAR(255) NOT NULL,                   -- textual label for the GO term
  ontology VARCHAR(9) NOT NULL,                 -- REFERENCES go_ontology
  definition TEXT NULL,                         -- textual definition for the GO term
  FOREIGN KEY (ontology) REFERENCES go_ontology (ontology)
);

INSERT INTO go_term 
 SELECT DISTINCT t.id AS _id, t.acc, t.name, t.ontology AS ontology,
	d.term_definition 
 FROM 
	(SELECT te.id AS id, te.acc AS acc, 
		te.name AS name, o.ontology AS ontology
	FROM gosrc.term AS te, go_ontology AS o
	WHERE te.is_obsolete=0 AND te.term_type=o.term_type) AS t 
    LEFT OUTER JOIN 
	gosrc.term_definition AS d
    ON t.id=d.term_id
 ORDER BY ontology, _id;

-- CREATE INDEX gt1 on go_term(_id);
CREATE INDEX gt3 on go_term(ontology, go_id);
-- CREATE INDEX gt0 on go_term(go_id);
CREATE INDEX Fgo_term ON go_term (ontology);


ANALYZE go_term;

CREATE TABLE tmp_go_obsolete (
  _id INTEGER,
  go_id CHAR(10) PRIMARY KEY,                   -- GO ID
  term VARCHAR(255) NOT NULL,                   -- textual label for the GO term
  ontology VARCHAR(9) NOT NULL,                 -- REFERENCES go_ontology
  definition TEXT NULL,                         -- textual definition for the GO term
  FOREIGN KEY (ontology) REFERENCES go_ontology (ontology)
);

--there is some hanky panky here that Nianhua has inserted to get more terms into the obsolete table.
--It looks like this is a good thing to ensure that no terms get left out of the sources
--if this should turn out to not be true someday, or if the sources should become cleaner (likely)
--then the following inserts and temp tables should be clipped out.

INSERT INTO tmp_go_obsolete
 SELECT DISTINCT t.id AS _id, t.acc, t.name, t.ontology AS ontology,
	d.term_definition 
 FROM 
	(SELECT te.id AS id, te.acc AS acc, 
		te.name AS name, o.ontology AS ontology
	FROM gosrc.term AS te, go_ontology AS o
	WHERE te.is_obsolete=1 AND te.term_type=o.term_type) AS t 
    LEFT OUTER JOIN 
	gosrc.term_definition AS d
    ON t.id=d.term_id;

INSERT INTO tmp_go_obsolete (go_id, term, ontology, definition)
 SELECT DISTINCT term_synonym, o.term, o.ontology, o.definition
 FROM tmp_go_obsolete AS o, gosrc.term_synonym AS s
 WHERE o._id=s.term_id AND s.term_synonym LIKE 'GO:%';


CREATE TABLE go_obsolete (
  go_id CHAR(10) PRIMARY KEY,                   -- GO ID
  term VARCHAR(255) NOT NULL,                   -- textual label for the GO term
  ontology VARCHAR(9) NOT NULL,                 -- REFERENCES go_ontology
  definition TEXT NULL,                         -- textual definition for the GO term
  FOREIGN KEY (ontology) REFERENCES go_ontology (ontology)
);

INSERT INTO go_obsolete SELECT DISTINCT go_id, term, ontology, definition 
FROM tmp_go_obsolete;

DROP TABLE tmp_go_obsolete;

--CREATE INDEX gt2 on go_obsolete(_id);
CREATE INDEX Fgo_obsolete ON go_obsolete (ontology);

-- Data linked to the "go_term" table.
CREATE TABLE go_synonym (
  _id INTEGER NOT NULL,                     -- REFERENCES go_term
  synonym VARCHAR(255) NOT NULL,                -- label or GO ID
  secondary CHAR(10) NULL,                      -- GO ID
  like_go_id SMALLINT,                          -- boolean (1 or 0)
  FOREIGN KEY (_id) REFERENCES go_term (_id)
);

INSERT INTO go_synonym
 SELECT t._id, term_synonym, acc_synonym, 0
 FROM gosrc.term_synonym AS s, go_term AS t 
 WHERE s.term_id=t._id 
 ORDER BY t._id;

UPDATE go_synonym
  SET synonym=NULL
  WHERE synonym='\N';
UPDATE go_synonym
  SET secondary=NULL
  WHERE secondary='\N';

UPDATE go_synonym
  SET like_go_id=1
  WHERE synonym LIKE 'GO:%';

-- CREATE INDEX gs1 on go_synonym(_id);
CREATE INDEX gs2 on go_synonym(synonym);
CREATE INDEX Fgo_synonym ON go_synonym (_id);

--go_offspring is a subset of graph_path
--we remove obsolete terms, none bp,mf,cc,universal terms, etc

--the following should be a TEMP
CREATE TEMP TABLE go_offspring AS 
 SELECT DISTINCT g.term1_id AS id, g.term2_id AS _offspring_id,
	t.ontology AS ontology 
 FROM gosrc.graph_path AS g CROSS JOIN go_term AS t 
 WHERE g.distance>0 AND g.term2_id=t._id;

-- parent-offspring relationship.
CREATE TABLE go_bp_offspring (
  _id INTEGER NOT NULL,                     -- REFERENCES go_term
  _offspring_id INTEGER NOT NULL,                -- REFERENCES go_term
  FOREIGN KEY (_id) REFERENCES go_term (_id),
  FOREIGN KEY (_offspring_id) REFERENCES go_term (_id)
);
 
INSERT INTO go_bp_offspring  
 SELECT id, _offspring_id 
 FROM go_offspring 
 WHERE ontology='BP'
 ORDER BY id;

CREATE INDEX of1 on go_bp_offspring(_id, _offspring_id);
CREATE INDEX of2 on go_bp_offspring(_offspring_id, _id);
CREATE INDEX F1go_bp_offspring ON go_bp_offspring (_id);
CREATE INDEX F2go_bp_offspring ON go_bp_offspring (_offspring_id);

-- parent-offspring relationship.
CREATE TABLE go_mf_offspring (
  _id INTEGER NOT NULL,                     -- REFERENCES go_term
  _offspring_id INTEGER NOT NULL,                -- REFERENCES go_term
  FOREIGN KEY (_id) REFERENCES go_term (_id),
  FOREIGN KEY (_offspring_id) REFERENCES go_term (_id)
);
 
INSERT INTO go_mf_offspring 
 SELECT id, _offspring_id 
 FROM go_offspring 
 WHERE ontology='MF'
 ORDER BY id;

CREATE INDEX of3 on go_mf_offspring(_id, _offspring_id);
CREATE INDEX of4 on go_mf_offspring(_offspring_id, _id);
CREATE INDEX F1go_mf_offspring ON go_mf_offspring (_id);
CREATE INDEX F2go_mf_offspring ON go_mf_offspring (_offspring_id);

-- parent-offspring relationship.
CREATE TABLE go_cc_offspring (
  _id INTEGER NOT NULL,                     -- REFERENCES go_term
  _offspring_id INTEGER NOT NULL,                -- REFERENCES go_term
  FOREIGN KEY (_id) REFERENCES go_term (_id),
  FOREIGN KEY (_offspring_id) REFERENCES go_term (_id)
);
 
INSERT INTO go_cc_offspring 
 SELECT id, _offspring_id  
 FROM go_offspring 
 WHERE ontology='CC'
 ORDER BY id;

CREATE INDEX of5 on go_cc_offspring(_id, _offspring_id);
CREATE INDEX of6 on go_cc_offspring(_offspring_id, _id);
CREATE INDEX F1go_cc_offspring ON go_cc_offspring (_id);
CREATE INDEX F2go_cc_offspring ON go_cc_offspring (_offspring_id);

--the following should be a TEMP
CREATE TEMP TABLE go_parents AS 
 SELECT DISTINCT g.term2_id AS id, g.term1_id AS _parent_id, 
	e.name AS relationship_type, t.ontology AS ontology
 FROM gosrc.term2term AS g CROSS JOIN go_term AS t CROSS JOIN gosrc.term AS e  
 WHERE g.term2_id=t._id and g.relationship_type_id=e.id; 

-- child-parent relationship.
CREATE TABLE go_bp_parents ( 
  _id INTEGER NOT NULL,                     -- REFERENCES go_term
  _parent_id INTEGER NOT NULL,                   -- REFERENCES go_term
  relationship_type VARCHAR(7) NOT NULL,                 -- type of GO child-parent relationship
  FOREIGN KEY (_id) REFERENCES go_term (_id),
  FOREIGN KEY (_parent_id) REFERENCES go_term (_id)
);

INSERT INTO go_bp_parents
 SELECT id, _parent_id, relationship_type 
 FROM go_parents 
 WHERE ontology='BP'
 ORDER BY id;

CREATE INDEX pa1 on go_bp_parents(_id, _parent_id);
CREATE INDEX pa2 on go_bp_parents(_parent_id, _id);
CREATE INDEX F1go_bp_parents ON go_bp_parents (_id);
CREATE INDEX F2go_bp_parents ON go_bp_parents (_parent_id);

-- child-parent relationship.
CREATE TABLE go_mf_parents ( 
  _id INTEGER NOT NULL,                     -- REFERENCES go_term
  _parent_id INTEGER NOT NULL,                   -- REFERENCES go_term
  relationship_type VARCHAR(7) NOT NULL,                 -- type of GO child-parent relationship
  FOREIGN KEY (_id) REFERENCES go_term (_id),
  FOREIGN KEY (_parent_id) REFERENCES go_term (_id)
);

INSERT INTO go_mf_parents  
 SELECT id, _parent_id, relationship_type 
 FROM go_parents 
 WHERE ontology='MF'
 ORDER BY id;

CREATE INDEX pa3 on go_mf_parents(_id, _parent_id);
CREATE INDEX pa4 on go_mf_parents(_parent_id, _id);
CREATE INDEX F1go_mf_parents ON go_mf_parents (_id);
CREATE INDEX F2go_mf_parents ON go_mf_parents (_parent_id);


-- child-parent relationship.
CREATE TABLE go_cc_parents ( 
  _id INTEGER NOT NULL,                     -- REFERENCES go_term
  _parent_id INTEGER NOT NULL,                   -- REFERENCES go_term
  relationship_type VARCHAR(7) NOT NULL,                 -- type of GO child-parent relationship
  FOREIGN KEY (_id) REFERENCES go_term (_id),
  FOREIGN KEY (_parent_id) REFERENCES go_term (_id)
);

INSERT INTO go_cc_parents 
 SELECT id, _parent_id, relationship_type 
 FROM go_parents 
 WHERE ontology='CC'
 ORDER BY id;

CREATE INDEX pa5 on go_cc_parents(_id, _parent_id);
CREATE INDEX pa6 on go_cc_parents(_parent_id, _id);
CREATE INDEX F1go_cc_parents ON go_cc_parents (_id);
CREATE INDEX F2go_cc_parents ON go_cc_parents (_parent_id);


ANALYZE go_term;
