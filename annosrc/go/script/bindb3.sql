.echo ON
ATTACH DATABASE 'GO_ORGANISM_SPEC.sqlite' AS go;

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

INSERT INTO metadata
 SELECT DISTINCT * FROM go.metadata WHERE name LIKE "%SOURCE%";

CREATE TABLE go_bp_offspring (
 go_id TEXT,
 offspring_go_id TEXT
);

INSERT INTO go_bp_offspring
 SELECT DISTINCT t1.go_id, t2.go_id
 FROM go.go_bp_offspring as o, 
	go.go_term as t1, go.go_term as t2
 WHERE t1._id=o._id and o._offspring_id=t2._id;

CREATE INDEX bpo on go_bp_offspring(offspring_go_id);
 
CREATE TABLE go_mf_offspring (
 go_id TEXT,
 offspring_go_id TEXT
);

INSERT INTO go_mf_offspring
 SELECT DISTINCT t1.go_id, t2.go_id
 FROM go.go_mf_offspring as o, 
	go.go_term as t1, go.go_term as t2
 WHERE t1._id=o._id and o._offspring_id=t2._id;

CREATE INDEX mfo on go_mf_offspring(offspring_go_id);
 
CREATE TABLE go_cc_offspring (
 go_id TEXT,
 offspring_go_id TEXT
);

INSERT INTO go_cc_offspring
 SELECT DISTINCT t1.go_id, t2.go_id
 FROM go.go_cc_offspring as o, 
	go.go_term as t1, go.go_term as t2
 WHERE t1._id=o._id and o._offspring_id=t2._id;

CREATE INDEX cco on go_cc_offspring(offspring_go_id);
 
CREATE TABLE go_bp_human as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
 FROM go.go_bp_human as g, go.go_term as t,
	go.gene2go_evidence as e
 WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_human as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
 FROM go.go_mf_human as g, go.go_term as t,
	go.gene2go_evidence as e
 WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_human as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
 FROM go.go_cc_human as g, go.go_term as t,
	go.gene2go_evidence as e
 WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_bp_mouse as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
 FROM go.go_bp_mouse as g, go.go_term as t,
	go.gene2go_evidence as e
 WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_mouse as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
 FROM go.go_mf_mouse as g, go.go_term as t,
	go.gene2go_evidence as e
 WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_mouse as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
 FROM go.go_cc_mouse as g, go.go_term as t,
	go.gene2go_evidence as e
 WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_bp_rat as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
 FROM go.go_bp_rat as g, go.go_term as t,
	go.gene2go_evidence as e
 WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_rat as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
 FROM go.go_mf_rat as g, go.go_term as t,
	go.gene2go_evidence as e
 WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_rat as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
 FROM go.go_cc_rat as g, go.go_term as t,
	go.gene2go_evidence as e
 WHERE g._id=t._id and g.evidence_id=e.evidence_id;


	
CREATE TABLE go_bp_yeast as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_yeast as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_yeast as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_yeast as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_yeast as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_yeast as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	



CREATE TABLE go_bp_worm as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_worm as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_worm as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_worm as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_worm as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_worm as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_bp_fish as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_fish as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_fish as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_fish as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_fish as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_fish as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;

CREATE TABLE go_bp_ecoliK12 as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_ecoliK12 as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_ecoliK12 as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_ecoliK12 as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_ecoliK12 as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_ecoliK12 as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;

CREATE TABLE go_bp_ecoliSakai as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_ecoliSakai as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_ecoliSakai as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_ecoliSakai as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_ecoliSakai as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_ecoliSakai as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;

	
CREATE TABLE go_bp_fly as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_fly as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_fly as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_fly as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_fly as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_fly as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;

	
CREATE TABLE go_bp_canine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_canine as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_canine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_canine as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_canine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_canine as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;

	
CREATE TABLE go_bp_bovine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_bovine as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_bovine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_bovine as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_bovine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_bovine as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;


CREATE TABLE go_bp_pig as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_pig as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_pig as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_pig as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_pig as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_pig as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;


CREATE TABLE go_bp_chicken as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_chicken as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_chicken as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_chicken as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_chicken as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_chicken as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;



CREATE TABLE go_bp_rhesus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_rhesus as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_rhesus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_rhesus as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_rhesus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_rhesus as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;



CREATE TABLE go_bp_xenopus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_xenopus as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_xenopus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_xenopus as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_xenopus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_xenopus as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;



CREATE TABLE go_bp_arabidopsis as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_arabidopsis as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_arabidopsis as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_arabidopsis as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_arabidopsis as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_arabidopsis as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;



CREATE TABLE go_bp_anopheles as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_anopheles as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_anopheles as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_anopheles as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_anopheles as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_anopheles as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;


CREATE TABLE go_bp_chimp as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_bp_chimp as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_mf_chimp as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_mf_chimp as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;
	
CREATE TABLE go_cc_chimp as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id
FROM go.go_cc_chimp as g, go.go_term as t,
	go.gene2go_evidence as e
WHERE g._id=t._id and g.evidence_id=e.evidence_id;





CREATE INDEX gh1 on go_bp_human(gene_id);	
CREATE INDEX gh2 on go_mf_human(gene_id);	
CREATE INDEX gh3 on go_cc_human(gene_id);	
CREATE INDEX gm1 on go_bp_mouse(gene_id);	
CREATE INDEX gm2 on go_mf_mouse(gene_id);	
CREATE INDEX gm3 on go_cc_mouse(gene_id);	
CREATE INDEX gr1 on go_bp_rat(gene_id);	
CREATE INDEX gr2 on go_mf_rat(gene_id);	
CREATE INDEX gr3 on go_cc_rat(gene_id);	
CREATE INDEX gw1 on go_bp_worm(gene_id);	
CREATE INDEX gw2 on go_mf_worm(gene_id);	
CREATE INDEX gw3 on go_cc_worm(gene_id);	
CREATE INDEX gy1 on go_bp_yeast(gene_id);	
CREATE INDEX gy2 on go_mf_yeast(gene_id);	
CREATE INDEX gy3 on go_cc_yeast(gene_id);	
CREATE INDEX gf1 on go_bp_fish(gene_id);	
CREATE INDEX gf2 on go_mf_fish(gene_id);	
CREATE INDEX gf3 on go_cc_fish(gene_id);	
CREATE INDEX geco1 on go_bp_ecoliK12(gene_id);	
CREATE INDEX geco2 on go_mf_ecoliK12(gene_id);	
CREATE INDEX geco3 on go_cc_ecoliK12(gene_id);	
CREATE INDEX gecos1 on go_bp_ecoliSakai(gene_id);	
CREATE INDEX gecos2 on go_mf_ecoliSakai(gene_id);	
CREATE INDEX gecos3 on go_cc_ecoliSakai(gene_id);	
CREATE INDEX gfl1 on go_bp_fly(gene_id);	
CREATE INDEX gfl2 on go_mf_fly(gene_id);	
CREATE INDEX gfl3 on go_cc_fly(gene_id);	
CREATE INDEX gcan1 on go_bp_canine(gene_id);	
CREATE INDEX gcan2 on go_mf_canine(gene_id);	
CREATE INDEX gcan3 on go_cc_canine(gene_id);	
CREATE INDEX gbov1 on go_bp_bovine(gene_id);	
CREATE INDEX gbov2 on go_mf_bovine(gene_id);	
CREATE INDEX gbov3 on go_cc_bovine(gene_id);	
CREATE INDEX gpig1 on go_bp_pig(gene_id);	
CREATE INDEX gpig2 on go_mf_pig(gene_id);	
CREATE INDEX gpig3 on go_cc_pig(gene_id);	
CREATE INDEX gchick1 on go_bp_chicken(gene_id);	
CREATE INDEX gchick2 on go_mf_chicken(gene_id);	
CREATE INDEX gchick3 on go_cc_chicken(gene_id);	
CREATE INDEX grhesus1 on go_bp_rhesus(gene_id);	
CREATE INDEX grhesus2 on go_mf_rhesus(gene_id);	
CREATE INDEX grhesus3 on go_cc_rhesus(gene_id);	
CREATE INDEX gxenopus1 on go_bp_xenopus(gene_id);	
CREATE INDEX gxenopus2 on go_mf_xenopus(gene_id);	
CREATE INDEX gxenopus3 on go_cc_xenopus(gene_id);	
CREATE INDEX garabidopsis1 on go_bp_arabidopsis(gene_id);	
CREATE INDEX garabidopsis2 on go_mf_arabidopsis(gene_id);	
CREATE INDEX garabidopsis3 on go_cc_arabidopsis(gene_id);	
CREATE INDEX ganopheles1 on go_bp_anopheles(gene_id);	
CREATE INDEX ganopheles2 on go_mf_anopheles(gene_id);	
CREATE INDEX ganopheles3 on go_cc_anopheles(gene_id);	
CREATE INDEX gchimp1 on go_bp_chimp(gene_id);	
CREATE INDEX gchimp2 on go_mf_chimp(gene_id);	
CREATE INDEX gchimp3 on go_cc_chimp(gene_id);	


CREATE TABLE go_bpall_human as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
 FROM	go.go_bp_human as g CROSS JOIN 
	go.go_bp_offspring as o CROSS JOIN
 	go.go_term as t CROSS JOIN 
	go.gene2go_evidence as e 
 WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
 SELECT go_id, relationship_type, gene_id
 FROM go_bp_human;

CREATE TABLE go_mfall_human as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
 FROM	go.go_mf_human as g CROSS JOIN 
	go.go_mf_offspring as o CROSS JOIN
 	go.go_term as t CROSS JOIN 
	go.gene2go_evidence as e 
 WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
 SELECT go_id, relationship_type, gene_id
 FROM go_mf_human;

CREATE TABLE go_ccall_human as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
 FROM	go.go_cc_human as g CROSS JOIN 
	go.go_cc_offspring as o CROSS JOIN
 	go.go_term as t CROSS JOIN 
	go.gene2go_evidence as e 
 WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
 SELECT go_id, relationship_type, gene_id
 FROM go_cc_human;

CREATE TABLE go_bpall_mouse as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
 FROM	go.go_bp_mouse as g CROSS JOIN 
	go.go_bp_offspring as o CROSS JOIN
 	go.go_term as t CROSS JOIN 
	go.gene2go_evidence as e 
 WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
 SELECT go_id, relationship_type, gene_id
 FROM go_bp_mouse; 

CREATE TABLE go_mfall_mouse as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
 FROM	go.go_mf_mouse as g CROSS JOIN 
	go.go_mf_offspring as o CROSS JOIN
 	go.go_term as t CROSS JOIN 
	go.gene2go_evidence as e 
 WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
 SELECT go_id, relationship_type, gene_id
 FROM go_mf_mouse;

CREATE TABLE go_ccall_mouse as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
 FROM	go.go_cc_mouse as g CROSS JOIN 
	go.go_cc_offspring as o CROSS JOIN
 	go.go_term as t CROSS JOIN 
	go.gene2go_evidence as e 
 WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
 SELECT go_id, relationship_type, gene_id
 FROM go_cc_mouse;

CREATE TABLE go_bpall_rat as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
 FROM	go.go_bp_rat as g CROSS JOIN 
	go.go_bp_offspring as o CROSS JOIN
 	go.go_term as t CROSS JOIN 
	go.gene2go_evidence as e 
 WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
 SELECT go_id, relationship_type, gene_id
 FROM go_bp_rat;

CREATE TABLE go_mfall_rat as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
 FROM	go.go_mf_rat as g CROSS JOIN 
	go.go_mf_offspring as o CROSS JOIN
 	go.go_term as t CROSS JOIN 
	go.gene2go_evidence as e 
 WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
 SELECT go_id, relationship_type, gene_id
 FROM go_mf_rat;

CREATE TABLE go_ccall_rat as
 SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
 FROM	go.go_cc_rat as g CROSS JOIN 
	go.go_cc_offspring as o CROSS JOIN
 	go.go_term as t CROSS JOIN 
	go.gene2go_evidence as e 
 WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
 SELECT go_id, relationship_type, gene_id
 FROM go_cc_rat;

CREATE TABLE go_bpall_worm as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_worm as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_worm;

CREATE TABLE go_mfall_worm as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_worm as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_worm;

CREATE TABLE go_ccall_worm as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_worm as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_worm;



CREATE TABLE go_bpall_yeast as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_yeast as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_yeast;

CREATE TABLE go_mfall_yeast as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_yeast as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_yeast;

CREATE TABLE go_ccall_yeast as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_yeast as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_yeast;



CREATE TABLE go_bpall_fish as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_fish as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_fish; 

CREATE TABLE go_mfall_fish as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_fish as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_fish;

CREATE TABLE go_ccall_fish as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_fish as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_fish;

CREATE TABLE go_bpall_ecoliK12 as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_ecoliK12 as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_ecoliK12;

CREATE TABLE go_mfall_ecoliK12 as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_ecoliK12 as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_ecoliK12;

CREATE TABLE go_ccall_ecoliK12 as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_ecoliK12 as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_ecoliK12;

CREATE TABLE go_bpall_ecoliSakai as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_ecoliSakai as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_ecoliSakai;

CREATE TABLE go_mfall_ecoliSakai as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_ecoliSakai as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_ecoliSakai;

CREATE TABLE go_ccall_ecoliSakai as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_ecoliSakai as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_ecoliSakai;


CREATE TABLE go_bpall_fly as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_fly as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_fly;

CREATE TABLE go_mfall_fly as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_fly as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_fly;

CREATE TABLE go_ccall_fly as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_fly as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_fly;


CREATE TABLE go_bpall_canine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_canine as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_canine;

CREATE TABLE go_mfall_canine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_canine as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_canine;

CREATE TABLE go_ccall_canine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_canine as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_canine;


CREATE TABLE go_bpall_bovine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_bovine as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_bovine;

CREATE TABLE go_mfall_bovine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_bovine as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_bovine;

CREATE TABLE go_ccall_bovine as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_bovine as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_bovine;


CREATE TABLE go_bpall_pig as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_pig as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_pig;

CREATE TABLE go_mfall_pig as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_pig as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_pig;

CREATE TABLE go_ccall_pig as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_pig as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_pig;


CREATE TABLE go_bpall_chicken as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_chicken as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_chicken;

CREATE TABLE go_mfall_chicken as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_chicken as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_chicken;

CREATE TABLE go_ccall_chicken as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_chicken as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_chicken;



CREATE TABLE go_bpall_rhesus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_rhesus as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_rhesus;

CREATE TABLE go_mfall_rhesus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_rhesus as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_rhesus;

CREATE TABLE go_ccall_rhesus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_rhesus as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_rhesus;



CREATE TABLE go_bpall_xenopus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_xenopus as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_xenopus;

CREATE TABLE go_mfall_xenopus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_xenopus as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_xenopus;

CREATE TABLE go_ccall_xenopus as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_xenopus as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_xenopus;



CREATE TABLE go_bpall_arabidopsis as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_arabidopsis as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_arabidopsis;

CREATE TABLE go_mfall_arabidopsis as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_arabidopsis as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_arabidopsis;

CREATE TABLE go_ccall_arabidopsis as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_arabidopsis as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_arabidopsis;



CREATE TABLE go_bpall_anopheles as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_anopheles as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_anopheles;

CREATE TABLE go_mfall_anopheles as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_anopheles as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_anopheles;

CREATE TABLE go_ccall_anopheles as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_anopheles as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_anopheles;



CREATE TABLE go_bpall_chimp as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_bp_chimp as g, 
	go.gene2go_evidence as e, go.go_bp_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_bp_chimp;

CREATE TABLE go_mfall_chimp as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_mf_chimp as g, 
	go.gene2go_evidence as e, go.go_mf_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_mf_chimp;

CREATE TABLE go_ccall_chimp as
SELECT t.go_id as go_id, e.relationship_type as relationship_type,
	g.gene_id as gene_id 
FROM go.go_term as t, go.go_cc_chimp as g, 
	go.gene2go_evidence as e, go.go_cc_offspring as o
WHERE o._id=t._id and o._offspring_id=g._id and
	g.evidence_id=e.evidence_id
UNION
SELECT go_id, relationship_type, gene_id
FROM go_cc_chimp;




CREATE INDEX gah1 on go_bpall_human(gene_id);	
CREATE INDEX gah2 on go_mfall_human(gene_id);	
CREATE INDEX gah3 on go_ccall_human(gene_id);	
CREATE INDEX gam1 on go_bpall_mouse(gene_id);	
CREATE INDEX gam2 on go_mfall_mouse(gene_id);	
CREATE INDEX gam3 on go_ccall_mouse(gene_id);	
CREATE INDEX gar1 on go_bpall_rat(gene_id);	
CREATE INDEX gar2 on go_mfall_rat(gene_id);	
CREATE INDEX gar3 on go_ccall_rat(gene_id);	
CREATE INDEX gaw1 on go_bpall_worm(gene_id);	
CREATE INDEX gaw2 on go_mfall_worm(gene_id);	
CREATE INDEX gaw3 on go_ccall_worm(gene_id);	
CREATE INDEX gay1 on go_bpall_yeast(gene_id);	
CREATE INDEX gay2 on go_mfall_yeast(gene_id);	
CREATE INDEX gay3 on go_ccall_yeast(gene_id);	
CREATE INDEX gaf1 on go_bpall_fish(gene_id);	
CREATE INDEX gaf2 on go_mfall_fish(gene_id);	
CREATE INDEX gaf3 on go_ccall_fish(gene_id);	
CREATE INDEX gaeco1 on go_bpall_ecoliK12(gene_id);	
CREATE INDEX gaeco2 on go_mfall_ecoliK12(gene_id);	
CREATE INDEX gaeco3 on go_ccall_ecoliK12(gene_id);	
CREATE INDEX gaecos1 on go_bpall_ecoliSakai(gene_id);	
CREATE INDEX gaecos2 on go_mfall_ecoliSakai(gene_id);	
CREATE INDEX gaecos3 on go_ccall_ecoliSakai(gene_id);	
CREATE INDEX gafl1 on go_bpall_fly(gene_id);	
CREATE INDEX gafl2 on go_mfall_fly(gene_id);	
CREATE INDEX gafl3 on go_ccall_fly(gene_id);	
CREATE INDEX gacan1 on go_bpall_canine(gene_id);	
CREATE INDEX gacan2 on go_mfall_canine(gene_id);	
CREATE INDEX gacan3 on go_ccall_canine(gene_id);	
CREATE INDEX gabov1 on go_bpall_bovine(gene_id);	
CREATE INDEX gabov2 on go_mfall_bovine(gene_id);	
CREATE INDEX gabov3 on go_ccall_bovine(gene_id);	
CREATE INDEX gapig1 on go_bpall_pig(gene_id);	
CREATE INDEX gapig2 on go_mfall_pig(gene_id);	
CREATE INDEX gapig3 on go_ccall_pig(gene_id);	
CREATE INDEX gachick1 on go_bpall_chicken(gene_id);	
CREATE INDEX gachick2 on go_mfall_chicken(gene_id);	
CREATE INDEX gachick3 on go_ccall_chicken(gene_id);	
CREATE INDEX garhesus1 on go_bpall_rhesus(gene_id);	
CREATE INDEX garhesus2 on go_mfall_rhesus(gene_id);	
CREATE INDEX garhesus3 on go_ccall_rhesus(gene_id);	
CREATE INDEX gaxenopus1 on go_bpall_xenopus(gene_id);	
CREATE INDEX gaxenopus2 on go_mfall_xenopus(gene_id);	
CREATE INDEX gaxenopus3 on go_ccall_xenopus(gene_id);	
CREATE INDEX gaarabidopsis1 on go_bpall_arabidopsis(gene_id);	
CREATE INDEX gaarabidopsis2 on go_mfall_arabidopsis(gene_id);	
CREATE INDEX gaarabidopsis3 on go_ccall_arabidopsis(gene_id);
CREATE INDEX gaanopheles1 on go_bpall_anopheles(gene_id);	
CREATE INDEX gaanopheles2 on go_mfall_anopheles(gene_id);	
CREATE INDEX gaanopheles3 on go_ccall_anopheles(gene_id);	
CREATE INDEX gachimp1 on go_bpall_chimp(gene_id);	
CREATE INDEX gachimp2 on go_mfall_chimp(gene_id);	
CREATE INDEX gachimp3 on go_ccall_chimp(gene_id);	

ANALYZE;
