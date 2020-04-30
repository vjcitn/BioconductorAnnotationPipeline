.echo ON
ATTACH DATABASE 'metadatasrc.sqlite' AS metadatasrc;
INSERT INTO metadata
 SELECT "DBSCHEMA", db_schema FROM metadatasrc.metadata WHERE package_name="GO"; 
DETACH DATABASE metadatasrc;

ATTACH DATABASE 'genesrc.sqlite' AS genesrc;
ATTACH DATABASE 'uniprot2go.sqlite' AS UPEG2GOsrc;

DROP TABLE IF EXISTS go_bp_human;
DROP TABLE IF EXISTS go_mf_human;
DROP TABLE IF EXISTS go_cc_human;
DROP TABLE IF EXISTS go_bp_mouse;
DROP TABLE IF EXISTS go_mf_mouse;
DROP TABLE IF EXISTS go_cc_mouse;
DROP TABLE IF EXISTS go_bp_rat;
DROP TABLE IF EXISTS go_mf_rat;
DROP TABLE IF EXISTS go_cc_rat;
DROP TABLE IF EXISTS go_bp_yeast;
DROP TABLE IF EXISTS go_mf_yeast;
DROP TABLE IF EXISTS go_cc_yeast;
DROP TABLE IF EXISTS go_bp_worm;
DROP TABLE IF EXISTS go_mf_worm;
DROP TABLE IF EXISTS go_cc_worm;
DROP TABLE IF EXISTS go_bp_fish;
DROP TABLE IF EXISTS go_mf_fish;
DROP TABLE IF EXISTS go_cc_fish;
DROP TABLE IF EXISTS go_bp_ecoliK12;
DROP TABLE IF EXISTS go_mf_ecoliK12;
DROP TABLE IF EXISTS go_cc_ecoliK12;
DROP TABLE IF EXISTS go_bp_ecoliSakai;
DROP TABLE IF EXISTS go_mf_ecoliSakai;
DROP TABLE IF EXISTS go_cc_ecoliSakai;
DROP TABLE IF EXISTS go_bp_fly;
DROP TABLE IF EXISTS go_mf_fly;
DROP TABLE IF EXISTS go_cc_fly;
DROP TABLE IF EXISTS go_bp_canine;
DROP TABLE IF EXISTS go_mf_canine;
DROP TABLE IF EXISTS go_cc_canine;
DROP TABLE IF EXISTS go_bp_bovine;
DROP TABLE IF EXISTS go_mf_bovine;
DROP TABLE IF EXISTS go_cc_bovine;
DROP TABLE IF EXISTS go_bp_pig;
DROP TABLE IF EXISTS go_mf_pig;
DROP TABLE IF EXISTS go_cc_pig;
DROP TABLE IF EXISTS go_bp_chicken;
DROP TABLE IF EXISTS go_mf_chicken;
DROP TABLE IF EXISTS go_cc_chicken;
DROP TABLE IF EXISTS go_bp_rhesus;
DROP TABLE IF EXISTS go_mf_rhesus;
DROP TABLE IF EXISTS go_cc_rhesus;
DROP TABLE IF EXISTS go_bp_xenopus;
DROP TABLE IF EXISTS go_mf_xenopus;
DROP TABLE IF EXISTS go_cc_xenopus;
DROP TABLE IF EXISTS go_bp_arabidopsis;
DROP TABLE IF EXISTS go_mf_arabidopsis;
DROP TABLE IF EXISTS go_cc_arabidopsis;
DROP TABLE IF EXISTS go_bp_anopheles;
DROP TABLE IF EXISTS go_mf_anopheles;
DROP TABLE IF EXISTS go_cc_anopheles;
DROP TABLE IF EXISTS go_bp_chimp;
DROP TABLE IF EXISTS go_mf_chimp;
DROP TABLE IF EXISTS go_cc_chimp;
DROP TABLE IF EXISTS gene2go_evidence;

INSERT INTO metadata
 SELECT * FROM genesrc.metadata;

UPDATE metadata
 SET name='GOEGSOURCEDATE' WHERE name='EGSOURCEDATE';
UPDATE metadata
 SET name='GOEGSOURCENAME' WHERE name='EGSOURCENAME';
UPDATE metadata
 SET name='GOEGSOURCEURL' WHERE name='EGSOURCEURL';

-- INSERT INTO metadata
--  SELECT * FROM UPEG2GOsrc.metadata;

CREATE TABLE gene2go_evidence (
 evidence_id INTEGER PRIMARY KEY,
 relationship_type TEXT
) ;

INSERT INTO gene2go_evidence (relationship_type)
 SELECT DISTINCT evidence
 FROM genesrc.gene2go;

CREATE TABLE go_bp_human (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_human (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_human (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_bp_mouse (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_mouse (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_mouse (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_bp_rat (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_rat (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_rat (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_bp_worm (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_worm (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_worm (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_bp_yeast (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_yeast (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_yeast (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_bp_fish (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_fish (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_fish (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);


CREATE TABLE go_bp_ecoliK12 (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_ecoliK12 (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_ecoliK12 (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);


CREATE TABLE go_bp_ecoliSakai (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_ecoliSakai (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_ecoliSakai (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 

CREATE TABLE go_bp_fly (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_fly (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_fly (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);

CREATE TABLE go_bp_canine (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_canine (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_canine (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);

CREATE TABLE go_bp_bovine (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_bovine (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_bovine (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);

CREATE TABLE go_bp_pig (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_pig (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_pig (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);


CREATE TABLE go_bp_chicken (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_chicken (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_chicken (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);


CREATE TABLE go_bp_rhesus (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_rhesus (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_rhesus (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);


CREATE TABLE go_bp_xenopus (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_xenopus (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_xenopus (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);


CREATE TABLE go_bp_arabidopsis (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_arabidopsis (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_arabidopsis (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);


CREATE TABLE go_bp_anopheles (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_anopheles (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_anopheles (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);


CREATE TABLE go_bp_chimp (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_mf_chimp (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);
 
CREATE TABLE go_cc_chimp (
	_id INTEGER REFERENCES go_term(_id),
	evidence_id INTEGER REFERENCES gene2go_evidence(evidence_id),
	gene_id TEXT
);




INSERT INTO go_bp_human 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '9606' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_human 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '9606' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_human 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '9606' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

CREATE INDEX gh1 on go_bp_human(_id);
CREATE INDEX gh2 on go_bp_human(gene_id);
CREATE INDEX gh3 on go_mf_human(_id);
CREATE INDEX gh4 on go_mf_human(gene_id);
CREATE INDEX gh5 on go_cc_human(_id);
CREATE INDEX gh6 on go_cc_human(gene_id);

INSERT INTO go_bp_mouse 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '10090' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_mouse 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '10090' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_mouse 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '10090' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

CREATE INDEX gm1 on go_bp_mouse(_id);
CREATE INDEX gm2 on go_bp_mouse(gene_id);
CREATE INDEX gm3 on go_mf_mouse(_id);
CREATE INDEX gm4 on go_mf_mouse(gene_id);
CREATE INDEX gm5 on go_cc_mouse(_id);
CREATE INDEX gm6 on go_cc_mouse(gene_id);

INSERT INTO go_bp_worm 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '6239' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_worm 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '6239' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_worm 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '6239' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

CREATE INDEX gw1 on go_bp_worm(_id);
CREATE INDEX gw2 on go_bp_worm(gene_id);
CREATE INDEX gw3 on go_mf_worm(_id);
CREATE INDEX gw4 on go_mf_worm(gene_id);
CREATE INDEX gw5 on go_cc_worm(_id);
CREATE INDEX gw6 on go_cc_worm(gene_id);

INSERT INTO go_bp_rat 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '10116' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_rat 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '10116' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_rat 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '10116' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

CREATE INDEX gr1 on go_bp_rat(_id);
CREATE INDEX gr2 on go_bp_rat(gene_id);
CREATE INDEX gr3 on go_mf_rat(_id);
CREATE INDEX gr4 on go_mf_rat(gene_id);
CREATE INDEX gr5 on go_cc_rat(_id);
CREATE INDEX gr6 on go_cc_rat(gene_id);

INSERT INTO go_bp_yeast 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '559292' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_yeast 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '559292' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_yeast 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '559292' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

CREATE INDEX gy1 on go_bp_yeast(_id);
CREATE INDEX gy2 on go_bp_yeast(gene_id);
CREATE INDEX gy3 on go_mf_yeast(_id);
CREATE INDEX gy4 on go_mf_yeast(gene_id);
CREATE INDEX gy5 on go_cc_yeast(_id);
CREATE INDEX gy6 on go_cc_yeast(gene_id);

INSERT INTO go_bp_fish 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '7955' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_fish 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '7955' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_fish 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '7955' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

CREATE INDEX gf1 on go_bp_fish(_id);
CREATE INDEX gf2 on go_bp_fish(gene_id);
CREATE INDEX gf3 on go_mf_fish(_id);
CREATE INDEX gf4 on go_mf_fish(gene_id);
CREATE INDEX gf5 on go_cc_fish(_id);
CREATE INDEX gf6 on go_cc_fish(gene_id);


INSERT INTO go_bp_ecoliK12 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '511145' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_ecoliK12 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '511145' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_ecoliK12 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '511145' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;


INSERT INTO go_bp_ecoliSakai 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '386585' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_ecoliSakai 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '386585' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_ecoliSakai 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '386585' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;


CREATE INDEX geco1 on go_bp_ecoliK12(_id);
CREATE INDEX geco2 on go_bp_ecoliK12(gene_id);
CREATE INDEX geco3 on go_mf_ecoliK12(_id);
CREATE INDEX geco4 on go_mf_ecoliK12(gene_id);
CREATE INDEX geco5 on go_cc_ecoliK12(_id);
CREATE INDEX geco6 on go_cc_ecoliK12(gene_id);

CREATE INDEX gecos1 on go_bp_ecoliSakai(_id);
CREATE INDEX gecos2 on go_bp_ecoliSakai(gene_id);
CREATE INDEX gecos3 on go_mf_ecoliSakai(_id);
CREATE INDEX gecos4 on go_mf_ecoliSakai(gene_id);
CREATE INDEX gecos5 on go_cc_ecoliSakai(_id);
CREATE INDEX gecos6 on go_cc_ecoliSakai(gene_id);


INSERT INTO go_bp_fly 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '7227' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_fly 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '7227' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_fly 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '7227' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

CREATE INDEX gd1 on go_bp_fly(_id);
CREATE INDEX gd2 on go_bp_fly(gene_id);
CREATE INDEX gd3 on go_mf_fly(_id);
CREATE INDEX gd4 on go_mf_fly(gene_id);
CREATE INDEX gd5 on go_cc_fly(_id);
CREATE INDEX gd6 on go_cc_fly(gene_id);


--For Canine and Pigs we are assigning the evidence code of IEA
--because the way Uniprot gene to go did the match is inferred.
INSERT INTO go_bp_canine 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Canis_familiaris_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=2
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_mf_canine 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Canis_familiaris_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=3
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_cc_canine 
 SELECT DISTINCT go._id, e.evidence_id, 
  	g.eg_id
 FROM UPEG2GOsrc.Canis_familiaris_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=4
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

CREATE INDEX gcani1 on go_bp_canine(_id);
CREATE INDEX gcani2 on go_bp_canine(gene_id);
CREATE INDEX gcani3 on go_mf_canine(_id);
CREATE INDEX gcani4 on go_mf_canine(gene_id);
CREATE INDEX gcani5 on go_cc_canine(_id);
CREATE INDEX gcani6 on go_cc_canine(gene_id);


INSERT INTO go_bp_bovine 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '9913' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_bovine 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '9913' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_bovine 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '9913' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

CREATE INDEX gbovi1 on go_bp_bovine(_id);
CREATE INDEX gbovi2 on go_bp_bovine(gene_id);
CREATE INDEX gbovi3 on go_mf_bovine(_id);
CREATE INDEX gbovi4 on go_mf_bovine(gene_id);
CREATE INDEX gbovi5 on go_cc_bovine(_id);
CREATE INDEX gbovi6 on go_cc_bovine(gene_id);

--For Canine and Pigs we are assigning the evidence code of IEA
--because the way that uniprot gene to GO was inferred
INSERT INTO go_bp_pig 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Sus_Scrofa_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=2
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_mf_pig 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Sus_Scrofa_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=3
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_cc_pig 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Sus_Scrofa_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=4
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

CREATE INDEX gpigi1 on go_bp_pig(_id);
CREATE INDEX gpigi2 on go_bp_pig(gene_id);
CREATE INDEX gpigi3 on go_mf_pig(_id);
CREATE INDEX gpigi4 on go_mf_pig(gene_id);
CREATE INDEX gpigi5 on go_cc_pig(_id);
CREATE INDEX gpigi6 on go_cc_pig(gene_id);


INSERT INTO go_bp_chicken 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '9031' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_chicken 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '9031' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_chicken 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '9031' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

CREATE INDEX gchicki1 on go_bp_chicken(_id);
CREATE INDEX gchicki2 on go_bp_chicken(gene_id);
CREATE INDEX gchicki3 on go_mf_chicken(_id);
CREATE INDEX gchicki4 on go_mf_chicken(gene_id);
CREATE INDEX gchicki5 on go_cc_chicken(_id);
CREATE INDEX gchicki6 on go_cc_chicken(gene_id);


INSERT INTO go_bp_rhesus 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Macaca_mulatta_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=2
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_mf_rhesus 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Macaca_mulatta_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=3
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_cc_rhesus 
 SELECT DISTINCT go._id, e.evidence_id, 
  	g.eg_id
 FROM UPEG2GOsrc.Macaca_mulatta_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=4
	and g.go_id=go.go_id and e.relationship_type = 'IEA';


CREATE INDEX grhesusi1 on go_bp_rhesus(_id);
CREATE INDEX grhesusi2 on go_bp_rhesus(gene_id);
CREATE INDEX grhesusi3 on go_mf_rhesus(_id);
CREATE INDEX grhesusi4 on go_mf_rhesus(gene_id);
CREATE INDEX grhesusi5 on go_cc_rhesus(_id);
CREATE INDEX grhesusi6 on go_cc_rhesus(gene_id);


INSERT INTO go_bp_xenopus 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Xenopus_laevis_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=2
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_mf_xenopus 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Xenopus_laevis_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=3
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_cc_xenopus 
 SELECT DISTINCT go._id, e.evidence_id, 
  	g.eg_id
 FROM UPEG2GOsrc.Xenopus_laevis_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=4
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

CREATE INDEX gxenopusi1 on go_bp_xenopus(_id);
CREATE INDEX gxenopusi2 on go_bp_xenopus(gene_id);
CREATE INDEX gxenopusi3 on go_mf_xenopus(_id);
CREATE INDEX gxenopusi4 on go_mf_xenopus(gene_id);
CREATE INDEX gxenopusi5 on go_cc_xenopus(_id);
CREATE INDEX gxenopusi6 on go_cc_xenopus(gene_id);


INSERT INTO go_bp_arabidopsis 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '3702' and go.ontology_id=2
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_mf_arabidopsis 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '3702' and go.ontology_id=3
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

INSERT INTO go_cc_arabidopsis 
 SELECT DISTINCT go._id, e.evidence_id, g.gene_id
 FROM genesrc.gene2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE g.tax_id = '3702' and go.ontology_id=4
        AND g.go_qualifier NOT LIKE "NOT%"
	and g.go_id=go.go_id and g.evidence=e.relationship_type;

CREATE INDEX garabidopsisi1 on go_bp_arabidopsis(_id);
CREATE INDEX garabidopsisi2 on go_bp_arabidopsis(gene_id);
CREATE INDEX garabidopsisi3 on go_mf_arabidopsis(_id);
CREATE INDEX garabidopsisi4 on go_mf_arabidopsis(gene_id);
CREATE INDEX garabidopsisi5 on go_cc_arabidopsis(_id);
CREATE INDEX garabidopsisi6 on go_cc_arabidopsis(gene_id);



INSERT INTO go_bp_anopheles 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Anopheles_gambiae_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=2
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_mf_anopheles 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Anopheles_gambiae_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=3
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_cc_anopheles 
 SELECT DISTINCT go._id, e.evidence_id, 
  	g.eg_id
 FROM UPEG2GOsrc.Anopheles_gambiae_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=4
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

CREATE INDEX ganophelesi1 on go_bp_anopheles(_id);
CREATE INDEX ganophelesi2 on go_bp_anopheles(gene_id);
CREATE INDEX ganophelesi3 on go_mf_anopheles(_id);
CREATE INDEX ganophelesi4 on go_mf_anopheles(gene_id);
CREATE INDEX ganophelesi5 on go_cc_anopheles(_id);
CREATE INDEX ganophelesi6 on go_cc_anopheles(gene_id);



INSERT INTO go_bp_chimp 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Pan_troglodytes_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=2
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_mf_chimp 
 SELECT DISTINCT go._id, e.evidence_id, 
 	g.eg_id
 FROM UPEG2GOsrc.Pan_troglodytes_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=3
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

INSERT INTO go_cc_chimp 
 SELECT DISTINCT go._id, e.evidence_id, 
  	g.eg_id
 FROM UPEG2GOsrc.Pan_troglodytes_eg2go as g CROSS JOIN go_term as go 
	CROSS JOIN gene2go_evidence as e
 WHERE go.ontology_id=4
	and g.go_id=go.go_id and e.relationship_type = 'IEA';

CREATE INDEX gchimpi1 on go_bp_chimp(_id);
CREATE INDEX gchimpi2 on go_bp_chimp(gene_id);
CREATE INDEX gchimpi3 on go_mf_chimp(_id);
CREATE INDEX gchimpi4 on go_mf_chimp(gene_id);
CREATE INDEX gchimpi5 on go_cc_chimp(_id);
CREATE INDEX gchimpi6 on go_cc_chimp(gene_id);





CREATE TABLE map_counts (
 map_name TEXT,
 count INTEGER,
 UNIQUE(map_name)
);

BEGIN TRANSACTION;

INSERT INTO map_counts
 SELECT 'GOTERM', count(distinct _id)
 FROM go_term;

INSERT INTO map_counts
 SELECT 'GOOBSOLETE', count(DISTINCT go_id)
 FROM go_obsolete;

INSERT INTO map_counts
 SELECT 'GOBPPARENTS', count(DISTINCT _id)
 FROM go_bp_parents;

INSERT INTO map_counts
 SELECT 'GOBPCHILDREN', count(DISTINCT _parent_id)
 FROM go_bp_parents;

INSERT INTO map_counts
 SELECT 'GOBPANCESTOR', count(DISTINCT _offspring_id)
 FROM go_bp_offspring;

INSERT INTO map_counts
 SELECT 'GOBPOFFSPRING', count(DISTINCT _id)
 FROM go_bp_offspring;

INSERT INTO map_counts
 SELECT 'GOMFPARENTS', count(DISTINCT _id)
 FROM go_mf_parents;

INSERT INTO map_counts
 SELECT 'GOMFCHILDREN', count(DISTINCT _parent_id)
 FROM go_mf_parents;

INSERT INTO map_counts
 SELECT 'GOMFANCESTOR', count(DISTINCT _offspring_id)
 FROM go_mf_offspring;

INSERT INTO map_counts
 SELECT 'GOMFOFFSPRING', count(DISTINCT _id)
 FROM go_mf_offspring;

INSERT INTO map_counts
 SELECT 'GOCCPARENTS', count(DISTINCT _id)
 FROM go_cc_parents;

INSERT INTO map_counts
 SELECT 'GOCCCHILDREN', count(DISTINCT _parent_id)
 FROM go_cc_parents;

INSERT INTO map_counts
 SELECT 'GOCCANCESTOR', count(DISTINCT _offspring_id)
 FROM go_cc_offspring;

INSERT INTO map_counts
 SELECT 'GOCCOFFSPRING', count(DISTINCT _id)
 FROM go_cc_offspring;

COMMIT TRANSACTION;

-- VACUUM gh1;

ANALYZE;
