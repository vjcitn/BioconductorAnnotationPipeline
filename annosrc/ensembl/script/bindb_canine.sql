.echo ON
ATTACH DATABASE "ensembl.sqlite" AS ens;


DROP TABLE IF EXISTS ensembl_prot;
CREATE TABLE ensembl_prot (
 _id VARCHAR(20) NOT NULL,
 prot_id VARCHAR(20) NOT NULL
);

INSERT INTO ensembl_prot
 SELECT e._id as _id, i.prot_id as prot_id 
 FROM ensembl as e INNER JOIN 
 ens.cf_gene_prot_map as i 
 WHERE e.ensid=i.gene_id;

CREATE INDEX ensgp1 ON ensembl_prot(_id);
CREATE INDEX ensgp2 ON ensembl_prot(prot_id);


DROP TABLE IF EXISTS ensembl_trans;
CREATE TABLE ensembl_trans (
 _id VARCHAR(20) NOT NULL,
 trans_id VARCHAR(20) NOT NULL
);

INSERT INTO ensembl_trans
 SELECT e._id as _id, i.trans_id as trans_id 
 FROM ensembl as e INNER JOIN 
 ens.cf_gene_trans_map as i 
 WHERE e.ensid=i.gene_id;

CREATE INDEX ensgt1 ON ensembl_trans(_id);
CREATE INDEX ensgt2 ON ensembl_trans(trans_id);


--Nuke any ensemble entries (remove this line later since it is just to help us re-run this code here without running all of the code, but is somewhat unsafe...
DELETE  FROM metadata WHERE name LIKE 'ENS%';

--Insert metadata.
INSERT INTO metadata
 SELECT * FROM ens.metadata
 WHERE name LIKE "ENS%";


DETACH DATABASE ens;

ANALYZE;
