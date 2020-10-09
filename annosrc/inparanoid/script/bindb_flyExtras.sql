.echo ON
ATTACH DATABASE "inparanoid.sqlite" AS inp;

DROP TABLE IF EXISTS flybase_prot;
CREATE TABLE flybase_prot (
 _id VARCHAR(20) NOT NULL,
 prot_id VARCHAR(20) NOT NULL
);
CREATE INDEX IF NOT EXISTS FBidInd ON flybase(FBid);

INSERT INTO flybase_prot
 SELECT f._id as _id, i.prot_id as prot_id 
 FROM flybase as f INNER JOIN 
 inp.dm_gene_prot_map as i 
 WHERE f.Fbid=i.gene_id AND i.prot_id <> '';

CREATE INDEX IF NOT EXISTS fbgp1 ON flybase_prot(_id);


--Nuke any ensemble entries (remove this line later since it is just to help us re-run this code here without running all of the code, but is somewhat unsafe...
DELETE  FROM metadata WHERE name LIKE 'FB%';

INSERT INTO metadata
 SELECT * FROM inp.metadata
 WHERE name LIKE "FB%";

DETACH DATABASE inp;

ANALYZE;
