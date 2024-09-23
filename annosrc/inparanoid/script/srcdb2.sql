.echo ON
.mode tabs

--Need to import the tables for the mapping data here

-- CREATE TABLE hs_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import HsIDs.tab hs_gene_prot_map
-- CREATE INDEX hgp ON hs_gene_prot_map(prot_id);


-- CREATE TABLE rn_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import RnIDs.tab rn_gene_prot_map
-- CREATE INDEX rgp ON rn_gene_prot_map(prot_id);

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);




--Fly IDs have some whitespace baggage to tidy up
CREATE TEMP TABLE tmpdm_gene_prot_map (
 gene_id VARCHAR(20) NOT NULL,
 trans_id VARCHAR(20) NOT NULL,
 prot_id VARCHAR(20) 
);
.import fbgn_fbtr_fbpp_purged.tsv tmpdm_gene_prot_map


CREATE TABLE dm_gene_prot_map (
 prot_id VARCHAR(20) NOT NULL,
 gene_id VARCHAR(20) NOT NULL
);

--using ltrim and rtrim with no 2nd argument will rm spaces
INSERT INTO dm_gene_prot_map
 SELECT DISTINCT ltrim(rtrim(prot_id)), ltrim(rtrim(gene_id)) 
 FROM tmpdm_gene_prot_map;


CREATE INDEX dgp ON dm_gene_prot_map(prot_id);
CREATE INDEX dgpGeneInd ON dm_gene_prot_map(gene_id);





-- --Make a master table for all the protein to gene map data:
-- CREATE TABLE prot_gene (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20)
-- );

-- --insert all the data from all the other tables into this one:
-- INSERT INTO prot_gene SELECT prot_id, gene_id FROM dm_gene_prot_map;
-- INSERT INTO prot_gene SELECT prot_id, gene_id FROM rn_gene_prot_map;
-- INSERT INTO prot_gene SELECT prot_id, gene_id FROM hs_gene_prot_map;

-- CREATE INDEX gp ON prot_gene(prot_id);


ANALYZE;
