.echo ON
ATTACH DATABASE "genome_src.sqlite" AS genome;

CREATE TABLE hsa_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.hsa_ec;
CREATE INDEX h1 on hsa_ec(gene_or_orf_id);

CREATE TABLE mmu_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.mmu_ec;
CREATE INDEX m1 on mmu_ec(gene_or_orf_id);

CREATE TABLE rno_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.rno_ec;
CREATE INDEX r1 on rno_ec(gene_or_orf_id);

CREATE TABLE sce_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.sce_ec;
CREATE INDEX s1 on sce_ec(gene_or_orf_id);

CREATE TABLE ath_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.ath_ec;
CREATE INDEX a1 on ath_ec(gene_or_orf_id);

CREATE TABLE ath_ncbi_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.ath_ncbi_ec;
CREATE INDEX athNCBI1 on ath_ncbi_ec(gene_or_orf_id);

CREATE TABLE dme_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.dme_ec;
CREATE INDEX d1 on dme_ec(gene_or_orf_id);

CREATE TABLE pfa_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.pfa_ec;
CREATE INDEX pfa1 on pfa_ec(gene_or_orf_id);

CREATE TABLE dre_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.dre_ec;
CREATE INDEX dre1 on dre_ec(gene_or_orf_id);

CREATE TABLE eco_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.eco_ec;
CREATE INDEX eco1 on eco_ec(gene_or_orf_id);

CREATE TABLE ecs_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.ecs_ec;
CREATE INDEX ecs1 on ecs_ec(gene_or_orf_id);

CREATE TABLE cfa_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.cfa_ec;
CREATE INDEX cfa1 on cfa_ec(gene_or_orf_id);

CREATE TABLE bta_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.bta_ec;
CREATE INDEX bta1 on bta_ec(gene_or_orf_id);

CREATE TABLE cel_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.cel_ec;
CREATE INDEX cel1 on cel_ec(gene_or_orf_id);

CREATE TABLE ssc_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.ssc_ec;
CREATE INDEX ssc1 on ssc_ec(gene_or_orf_id);

CREATE TABLE gga_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.gga_ec;
CREATE INDEX gga1 on gga_ec(gene_or_orf_id);

CREATE TABLE mcc_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.mcc_ec;
CREATE INDEX mcc1 on mcc_ec(gene_or_orf_id);

CREATE TABLE xla_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.xla_ec;
CREATE INDEX xla1 on xla_ec(gene_or_orf_id);

CREATE TABLE aga_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.aga_ec;
CREATE INDEX aga1 on aga_ec(gene_or_orf_id);

CREATE TABLE ptr_ec AS
 SELECT ec_id, gene_id as gene_or_orf_id
 FROM genome.ptr_ec;
CREATE INDEX ptr1 on ptr_ec(gene_or_orf_id);

DETACH DATABASE genome;
