.echo ON
.separator \t

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);


-- CREATE TABLE hs_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import HsIDs_prot.tab hs_gene_prot_map
-- CREATE INDEX hgp ON hs_gene_prot_map(prot_id);
-- CREATE INDEX hgg ON hs_gene_prot_map(gene_id);


-- CREATE TABLE rn_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import RnIDs_prot.tab rn_gene_prot_map
-- CREATE INDEX rgp ON rn_gene_prot_map(prot_id);
-- CREATE INDEX rgg ON rn_gene_prot_map(gene_id);


-- CREATE TABLE mm_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import MmIDs_prot.tab mm_gene_prot_map
-- CREATE INDEX mgp ON mm_gene_prot_map(prot_id);
-- CREATE INDEX mgg ON mm_gene_prot_map(gene_id);


-- CREATE TABLE dr_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import DrIDs_prot.tab dr_gene_prot_map
-- CREATE INDEX dgp ON dr_gene_prot_map(prot_id);
-- CREATE INDEX dgg ON dr_gene_prot_map(gene_id);


-- CREATE TABLE cf_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import CfIDs_prot.tab cf_gene_prot_map
-- CREATE INDEX cangp ON cf_gene_prot_map(prot_id);
-- CREATE INDEX cangg ON cf_gene_prot_map(gene_id);


-- CREATE TABLE bt_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import BtIDs_prot.tab bt_gene_prot_map
-- CREATE INDEX bovgp ON bt_gene_prot_map(prot_id);
-- CREATE INDEX bovgg ON bt_gene_prot_map(gene_id);


-- CREATE TABLE cel_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import CelIDs_prot.tab cel_gene_prot_map
-- CREATE INDEX wormgp ON cel_gene_prot_map(prot_id);
-- CREATE INDEX wormgg ON cel_gene_prot_map(gene_id);


-- -- CREATE TABLE ssc_gene_prot_map (
-- --  prot_id VARCHAR(20) NOT NULL,
-- --  gene_id VARCHAR(20) NOT NULL
-- -- );

-- -- .import SscIDs_prot.tab ssc_gene_prot_map
-- -- CREATE INDEX piggp ON ssc_gene_prot_map(prot_id);
-- -- CREATE INDEX piggg ON ssc_gene_prot_map(gene_id);


-- CREATE TABLE gga_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import GgaIDs_prot.tab gga_gene_prot_map
-- CREATE INDEX chickgp ON gga_gene_prot_map(prot_id);
-- CREATE INDEX chickgg ON gga_gene_prot_map(gene_id);


-- CREATE TABLE mmu_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import MmuIDs_prot.tab mmu_gene_prot_map
-- CREATE INDEX rhesusgp ON mmu_gene_prot_map(prot_id);
-- CREATE INDEX rhesusgg ON mmu_gene_prot_map(gene_id);


-- CREATE TABLE aga_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import AgaIDs_prot.tab aga_gene_prot_map
-- CREATE INDEX anophelesgp ON aga_gene_prot_map(prot_id);
-- CREATE INDEX anophelesgg ON aga_gene_prot_map(gene_id);


-- CREATE TABLE ptr_gene_prot_map (
--  prot_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import PtrIDs_prot.tab ptr_gene_prot_map
-- CREATE INDEX chimpgp ON ptr_gene_prot_map(prot_id);
-- CREATE INDEX chimpgg ON ptr_gene_prot_map(gene_id);





-- CREATE TABLE hs_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import HsIDs_trans.tab hs_gene_trans_map
-- CREATE INDEX hgt ON hs_gene_trans_map(trans_id);
-- CREATE INDEX hgtg ON hs_gene_trans_map(gene_id);



-- CREATE TABLE rn_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import RnIDs_trans.tab rn_gene_trans_map
-- CREATE INDEX rgt ON rn_gene_trans_map(trans_id);
-- CREATE INDEX rgtg ON rn_gene_trans_map(gene_id);


-- CREATE TABLE mm_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import MmIDs_trans.tab mm_gene_trans_map
-- CREATE INDEX mgt ON mm_gene_trans_map(trans_id);
-- CREATE INDEX mgtg ON mm_gene_trans_map(gene_id);


-- CREATE TABLE dr_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import DrIDs_trans.tab dr_gene_trans_map
-- CREATE INDEX dgt ON dr_gene_trans_map(trans_id);
-- CREATE INDEX dgtg ON dr_gene_trans_map(gene_id);


-- CREATE TABLE cf_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import CfIDs_trans.tab cf_gene_trans_map
-- CREATE INDEX cangt ON cf_gene_trans_map(trans_id);
-- CREATE INDEX cangtg ON cf_gene_trans_map(gene_id);


-- CREATE TABLE bt_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import BtIDs_trans.tab bt_gene_trans_map
-- CREATE INDEX bovgt ON bt_gene_trans_map(trans_id);
-- CREATE INDEX bovgtg ON bt_gene_trans_map(gene_id);


-- CREATE TABLE cel_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import CelIDs_trans.tab cel_gene_trans_map
-- CREATE INDEX wormgt ON cel_gene_trans_map(trans_id);
-- CREATE INDEX wormgtg ON cel_gene_trans_map(gene_id);


-- -- CREATE TABLE ssc_gene_trans_map (
-- --  trans_id VARCHAR(20) NOT NULL,
-- --  gene_id VARCHAR(20) NOT NULL
-- -- );

-- -- .import SscIDs_trans.tab ssc_gene_trans_map
-- -- CREATE INDEX piggt ON ssc_gene_trans_map(trans_id);
-- -- CREATE INDEX piggtg ON ssc_gene_trans_map(gene_id);


-- CREATE TABLE gga_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import GgaIDs_trans.tab gga_gene_trans_map
-- CREATE INDEX chickgt ON gga_gene_trans_map(trans_id);
-- CREATE INDEX chickgtg ON gga_gene_trans_map(gene_id);


-- CREATE TABLE mmu_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import MmuIDs_trans.tab mmu_gene_trans_map
-- CREATE INDEX rhesusgt ON mmu_gene_trans_map(trans_id);
-- CREATE INDEX rhesusgtg ON mmu_gene_trans_map(gene_id);


-- CREATE TABLE aga_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import AgaIDs_trans.tab aga_gene_trans_map
-- CREATE INDEX anophelest ON aga_gene_trans_map(trans_id);
-- CREATE INDEX anophelestg ON aga_gene_trans_map(gene_id);


-- CREATE TABLE ptr_gene_trans_map (
--  trans_id VARCHAR(20) NOT NULL,
--  gene_id VARCHAR(20) NOT NULL
-- );

-- .import PtrIDs_trans.tab ptr_gene_trans_map
-- CREATE INDEX chimpt ON ptr_gene_trans_map(trans_id);
-- CREATE INDEX chimptg ON ptr_gene_trans_map(gene_id);


ANALYZE;
