.echo ON
DROP TABLE IF EXISTS hsa;
DROP TABLE IF EXISTS hsa_ec;

.separator "\tncbi-geneid:"

-- Metadata tables.
CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

CREATE TEMP TABLE gene_hsa (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import hsa_ncbi-geneid.list gene_hsa

.separator "\t"
CREATE TEMP TABLE pathway_hsa (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import hsa_gene_map2.txt pathway_hsa

.separator "\t"
CREATE TEMP TABLE ec_hsa (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import hsa_ec2.txt ec_hsa

CREATE INDEX h1 on gene_hsa(kegg_id);
CREATE INDEX h2 on pathway_hsa(kegg_id);
CREATE INDEX h3 on ec_hsa(kegg_id);

CREATE TABLE hsa AS
 SELECT pathway_id, gene_id
 FROM pathway_hsa, gene_hsa
 WHERE pathway_hsa.kegg_id=gene_hsa.kegg_id;

CREATE TABLE hsa_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_hsa, gene_hsa
 WHERE ec_hsa.kegg_id=gene_hsa.kegg_id;

DROP TABLE IF EXISTS mmu;
DROP TABLE IF EXISTS mmu_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_mmu (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import mmu_ncbi-geneid.list gene_mmu

.separator "\t"
CREATE TEMP TABLE pathway_mmu (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import mmu_gene_map2.txt pathway_mmu

.separator "\t"
CREATE TEMP TABLE ec_mmu (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import mmu_ec2.txt ec_mmu

CREATE INDEX m1 on gene_mmu(kegg_id);
CREATE INDEX m2 on pathway_mmu(kegg_id);
CREATE INDEX m3 on ec_mmu(kegg_id);

CREATE TABLE mmu AS
 SELECT pathway_id, gene_id
 FROM pathway_mmu, gene_mmu
 WHERE pathway_mmu.kegg_id=gene_mmu.kegg_id;

CREATE TABLE mmu_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_mmu, gene_mmu
 WHERE ec_mmu.kegg_id=gene_mmu.kegg_id;

DROP TABLE IF EXISTS rno;
DROP TABLE IF EXISTS rno_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_rno (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import rno_ncbi-geneid.list gene_rno

.separator "\t"
CREATE TEMP TABLE pathway_rno (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import rno_gene_map2.txt pathway_rno

.separator "\t"
CREATE TEMP TABLE ec_rno (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import rno_ec2.txt ec_rno

CREATE INDEX r1 on gene_rno(kegg_id);
CREATE INDEX r2 on pathway_rno(kegg_id);
CREATE INDEX r3 on ec_rno(kegg_id);

CREATE TABLE rno AS
 SELECT pathway_id, gene_id
 FROM pathway_rno, gene_rno
 WHERE pathway_rno.kegg_id=gene_rno.kegg_id;

CREATE TABLE rno_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_rno, gene_rno
 WHERE ec_rno.kegg_id=gene_rno.kegg_id;

DROP TABLE IF EXISTS sce;
DROP TABLE IF EXISTS sce_ec;

.separator "\tmips-sce:"
CREATE TEMP TABLE gene_sce (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import sce_mips-sce.list gene_sce

.separator "\t"
CREATE TEMP TABLE pathway_sce (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import sce_gene_map2.txt pathway_sce

.separator "\t"
CREATE TEMP TABLE ec_sce (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import sce_ec2.txt ec_sce

CREATE INDEX s1 on gene_sce(kegg_id);
CREATE INDEX s2 on pathway_sce(kegg_id);
CREATE INDEX s3 on ec_sce(kegg_id);

CREATE TABLE sce AS
 SELECT pathway_id, gene_id
 FROM pathway_sce, gene_sce
 WHERE pathway_sce.kegg_id=gene_sce.kegg_id;

CREATE TABLE sce_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_sce, gene_sce
 WHERE ec_sce.kegg_id=gene_sce.kegg_id;



DROP TABLE IF EXISTS ath;
DROP TABLE IF EXISTS ath_ec;

.separator "\ttigr-ath:"
CREATE TEMP TABLE gene_ath (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import ath_tigr-ath.list gene_ath

.separator "\t"
CREATE TEMP TABLE pathway_ath (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import ath_gene_map2.txt pathway_ath

.separator "\t"
CREATE TEMP TABLE ec_ath (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import ath_ec2.txt ec_ath

CREATE INDEX a1 on gene_ath(kegg_id);
CREATE INDEX a2 on pathway_ath(kegg_id);
CREATE INDEX a3 on ec_ath(kegg_id);

CREATE TABLE ath AS
 SELECT pathway_id, gene_id
 FROM pathway_ath, gene_ath
 WHERE pathway_ath.kegg_id=gene_ath.kegg_id;

CREATE TABLE ath_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_ath, gene_ath
 WHERE ec_ath.kegg_id=gene_ath.kegg_id;

DROP TABLE gene_ath;
DROP TABLE pathway_ath;
DROP TABLE ec_ath;



DROP TABLE IF EXISTS ath_ncbi;
DROP TABLE IF EXISTS ath_ncbi_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_ath (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import ath_ncbi-geneid.list gene_ath

.separator "\t"
CREATE TEMP TABLE pathway_ath (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import ath_gene_map2.txt pathway_ath

.separator "\t"
CREATE TEMP TABLE ec_ath (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import ath_ec2.txt ec_ath

CREATE INDEX athn1 on gene_ath(kegg_id);
CREATE INDEX athn2 on pathway_ath(kegg_id);
CREATE INDEX athn3 on ec_ath(kegg_id);

CREATE TABLE ath_ncbi AS
 SELECT pathway_id, gene_id
 FROM pathway_ath, gene_ath
 WHERE pathway_ath.kegg_id=gene_ath.kegg_id;

CREATE TABLE ath_ncbi_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_ath, gene_ath
 WHERE ec_ath.kegg_id=gene_ath.kegg_id;








DROP TABLE IF EXISTS dme;
DROP TABLE IF EXISTS dme_ec;

.separator "\tflybase-dme:"
CREATE TEMP TABLE gene_dme (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import dme_flybase-dme.list gene_dme

.separator "\t"
CREATE TEMP TABLE pathway_dme (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import dme_gene_map2.txt pathway_dme

.separator "\t"
CREATE TEMP TABLE ec_dme (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import dme_ec2.txt ec_dme

CREATE INDEX d1 on gene_dme(kegg_id);
CREATE INDEX d2 on pathway_dme(kegg_id);
CREATE INDEX d3 on ec_dme(kegg_id);

CREATE TABLE dme AS
 SELECT pathway_id, gene_id
 FROM pathway_dme, gene_dme
 WHERE pathway_dme.kegg_id=gene_dme.kegg_id;

CREATE TABLE dme_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_dme, gene_dme
 WHERE ec_dme.kegg_id=gene_dme.kegg_id;



DROP TABLE IF EXISTS pfa;
DROP TABLE IF EXISTS pfa_ec;

.separator "\tplasmodb-pfa:"
CREATE TEMP TABLE gene_pfa (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import pfa_plasmodb-pfa.list gene_pfa

.separator "\t"
CREATE TEMP TABLE pathway_pfa (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import pfa_gene_map2.txt pathway_pfa

.separator "\t"
CREATE TEMP TABLE ec_pfa (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import pfa_ec2.txt ec_pfa

CREATE INDEX pfa1 on gene_pfa(kegg_id);
CREATE INDEX pfa2 on pathway_pfa(kegg_id);
CREATE INDEX pfa3 on ec_pfa(kegg_id);

CREATE TABLE pfa AS
 SELECT pathway_id, gene_id
 FROM pathway_pfa, gene_pfa
 WHERE pathway_pfa.kegg_id=gene_pfa.kegg_id;

CREATE TABLE pfa_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_pfa, gene_pfa
 WHERE ec_pfa.kegg_id=gene_pfa.kegg_id;



DROP TABLE IF EXISTS dre;
DROP TABLE IF EXISTS dre_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_dre (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import dre_ncbi-geneid.list gene_dre

.separator "\t"
CREATE TEMP TABLE pathway_dre (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import dre_gene_map2.txt pathway_dre

.separator "\t"
CREATE TEMP TABLE ec_dre (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import dre_ec2.txt ec_dre

CREATE INDEX dre1 on gene_dre(kegg_id);
CREATE INDEX dre2 on pathway_dre(kegg_id);
CREATE INDEX dre3 on ec_dre(kegg_id);

CREATE TABLE dre AS
 SELECT pathway_id, gene_id
 FROM pathway_dre, gene_dre
 WHERE pathway_dre.kegg_id=gene_dre.kegg_id;

CREATE TABLE dre_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_dre, gene_dre
 WHERE ec_dre.kegg_id=gene_dre.kegg_id;


DROP TABLE IF EXISTS eco;
DROP TABLE IF EXISTS eco_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_eco (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import eco_ncbi-geneid.list gene_eco

.separator "\t"
CREATE TEMP TABLE pathway_eco (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import eco_gene_map2.txt pathway_eco

.separator "\t"
CREATE TEMP TABLE ec_eco (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import eco_ec2.txt ec_eco

CREATE INDEX eco1 on gene_eco(kegg_id);
CREATE INDEX eco2 on pathway_eco(kegg_id);
CREATE INDEX eco3 on ec_eco(kegg_id);

CREATE TABLE eco AS
 SELECT pathway_id, gene_id
 FROM pathway_eco, gene_eco
 WHERE pathway_eco.kegg_id=gene_eco.kegg_id;

CREATE TABLE eco_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_eco, gene_eco
 WHERE ec_eco.kegg_id=gene_eco.kegg_id;



DROP TABLE IF EXISTS ecs;
DROP TABLE IF EXISTS ecs_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_ecs (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import ecs_ncbi-geneid.list gene_ecs

.separator "\t"
CREATE TEMP TABLE pathway_ecs (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import ecs_gene_map2.txt pathway_ecs

.separator "\t"
CREATE TEMP TABLE ec_ecs (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import ecs_ec2.txt ec_ecs

CREATE INDEX ecs1 on gene_ecs(kegg_id);
CREATE INDEX ecs2 on pathway_ecs(kegg_id);
CREATE INDEX ecs3 on ec_ecs(kegg_id);

CREATE TABLE ecs AS
 SELECT pathway_id, gene_id
 FROM pathway_ecs, gene_ecs
 WHERE pathway_ecs.kegg_id=gene_ecs.kegg_id;

CREATE TABLE ecs_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_ecs, gene_ecs
 WHERE ec_ecs.kegg_id=gene_ecs.kegg_id;


DROP TABLE IF EXISTS cfa;
DROP TABLE IF EXISTS cfa_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_cfa (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import cfa_ncbi-geneid.list gene_cfa

.separator "\t"
CREATE TEMP TABLE pathway_cfa (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import cfa_gene_map2.txt pathway_cfa

.separator "\t"
CREATE TEMP TABLE ec_cfa (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import cfa_ec2.txt ec_cfa

CREATE INDEX cfa1 on gene_cfa(kegg_id);
CREATE INDEX cfa2 on pathway_cfa(kegg_id);
CREATE INDEX cfa3 on ec_cfa(kegg_id);

CREATE TABLE cfa AS
 SELECT pathway_id, gene_id
 FROM pathway_cfa, gene_cfa
 WHERE pathway_cfa.kegg_id=gene_cfa.kegg_id;

CREATE TABLE cfa_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_cfa, gene_cfa
 WHERE ec_cfa.kegg_id=gene_cfa.kegg_id;


DROP TABLE IF EXISTS bta;
DROP TABLE IF EXISTS bta_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_bta (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import bta_ncbi-geneid.list gene_bta

.separator "\t"
CREATE TEMP TABLE pathway_bta (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import bta_gene_map2.txt pathway_bta

.separator "\t"
CREATE TEMP TABLE ec_bta (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import bta_ec2.txt ec_bta

CREATE INDEX bta1 on gene_bta(kegg_id);
CREATE INDEX bta2 on pathway_bta(kegg_id);
CREATE INDEX bta3 on ec_bta(kegg_id);

CREATE TABLE bta AS
 SELECT pathway_id, gene_id
 FROM pathway_bta, gene_bta
 WHERE pathway_bta.kegg_id=gene_bta.kegg_id;

CREATE TABLE bta_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_bta, gene_bta
 WHERE ec_bta.kegg_id=gene_bta.kegg_id;


DROP TABLE IF EXISTS cel;
DROP TABLE IF EXISTS cel_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_cel (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import cel_ncbi-geneid.list gene_cel

.separator "\t"
CREATE TEMP TABLE pathway_cel (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import cel_gene_map2.txt pathway_cel

.separator "\t"
CREATE TEMP TABLE ec_cel (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import cel_ec2.txt ec_cel

CREATE INDEX cel1 on gene_cel(kegg_id);
CREATE INDEX cel2 on pathway_cel(kegg_id);
CREATE INDEX cel3 on ec_cel(kegg_id);

CREATE TABLE cel AS
 SELECT pathway_id, gene_id
 FROM pathway_cel, gene_cel
 WHERE pathway_cel.kegg_id=gene_cel.kegg_id;

CREATE TABLE cel_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_cel, gene_cel
 WHERE ec_cel.kegg_id=gene_cel.kegg_id;



DROP TABLE IF EXISTS ssc;
DROP TABLE IF EXISTS ssc_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_ssc (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import ssc_ncbi-geneid.list gene_ssc

.separator "\t"
CREATE TEMP TABLE pathway_ssc (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import ssc_gene_map2.txt pathway_ssc

.separator "\t"
CREATE TEMP TABLE ec_ssc (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import ssc_ec2.txt ec_ssc

CREATE INDEX ssc1 on gene_ssc(kegg_id);
CREATE INDEX ssc2 on pathway_ssc(kegg_id);
CREATE INDEX ssc3 on ec_ssc(kegg_id);

CREATE TABLE ssc AS
 SELECT pathway_id, gene_id
 FROM pathway_ssc, gene_ssc
 WHERE pathway_ssc.kegg_id=gene_ssc.kegg_id;

CREATE TABLE ssc_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_ssc, gene_ssc
 WHERE ec_ssc.kegg_id=gene_ssc.kegg_id;



DROP TABLE IF EXISTS gga;
DROP TABLE IF EXISTS gga_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_gga (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import gga_ncbi-geneid.list gene_gga

.separator "\t"
CREATE TEMP TABLE pathway_gga (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import gga_gene_map2.txt pathway_gga

.separator "\t"
CREATE TEMP TABLE ec_gga (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import gga_ec2.txt ec_gga

CREATE INDEX gga1 on gene_gga(kegg_id);
CREATE INDEX gga2 on pathway_gga(kegg_id);
CREATE INDEX gga3 on ec_gga(kegg_id);

CREATE TABLE gga AS
 SELECT pathway_id, gene_id
 FROM pathway_gga, gene_gga
 WHERE pathway_gga.kegg_id=gene_gga.kegg_id;

CREATE TABLE gga_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_gga, gene_gga
 WHERE ec_gga.kegg_id=gene_gga.kegg_id;



DROP TABLE IF EXISTS mcc;
DROP TABLE IF EXISTS mcc_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_mcc (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import mcc_ncbi-geneid.list gene_mcc

.separator "\t"
CREATE TEMP TABLE pathway_mcc (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import mcc_gene_map2.txt pathway_mcc

.separator "\t"
CREATE TEMP TABLE ec_mcc (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import mcc_ec2.txt ec_mcc

CREATE INDEX mcc1 on gene_mcc(kegg_id);
CREATE INDEX mcc2 on pathway_mcc(kegg_id);
CREATE INDEX mcc3 on ec_mcc(kegg_id);

CREATE TABLE mcc AS
 SELECT pathway_id, gene_id
 FROM pathway_mcc, gene_mcc
 WHERE pathway_mcc.kegg_id=gene_mcc.kegg_id;

CREATE TABLE mcc_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_mcc, gene_mcc
 WHERE ec_mcc.kegg_id=gene_mcc.kegg_id;




DROP TABLE IF EXISTS xla;
DROP TABLE IF EXISTS xla_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_xla (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import xla_ncbi-geneid.list gene_xla

.separator "\t"
CREATE TEMP TABLE pathway_xla (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import xla_gene_map2.txt pathway_xla

.separator "\t"
CREATE TEMP TABLE ec_xla (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import xla_ec2.txt ec_xla

CREATE INDEX xla1 on gene_xla(kegg_id);
CREATE INDEX xla2 on pathway_xla(kegg_id);
CREATE INDEX xla3 on ec_xla(kegg_id);

CREATE TABLE xla AS
 SELECT pathway_id, gene_id
 FROM pathway_xla, gene_xla
 WHERE pathway_xla.kegg_id=gene_xla.kegg_id;

CREATE TABLE xla_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_xla, gene_xla
 WHERE ec_xla.kegg_id=gene_xla.kegg_id;





DROP TABLE IF EXISTS aga;
DROP TABLE IF EXISTS aga_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_aga (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import aga_ncbi-geneid.list gene_aga

.separator "\t"
CREATE TEMP TABLE pathway_aga (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import aga_gene_map2.txt pathway_aga

.separator "\t"
CREATE TEMP TABLE ec_aga (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import aga_ec2.txt ec_aga

CREATE INDEX aga1 on gene_aga(kegg_id);
CREATE INDEX aga2 on pathway_aga(kegg_id);
CREATE INDEX aga3 on ec_aga(kegg_id);

CREATE TABLE aga AS
 SELECT pathway_id, gene_id
 FROM pathway_aga, gene_aga
 WHERE pathway_aga.kegg_id=gene_aga.kegg_id;

CREATE TABLE aga_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_aga, gene_aga
 WHERE ec_aga.kegg_id=gene_aga.kegg_id;






DROP TABLE IF EXISTS ptr;
DROP TABLE IF EXISTS ptr_ec;

.separator "\tncbi-geneid:"
CREATE TEMP TABLE gene_ptr (
  kegg_id TEXT NOT NULL,
  gene_id TEXT NOT NULL
) ;
.import ptr_ncbi-geneid.list gene_ptr

.separator "\t"
CREATE TEMP TABLE pathway_ptr (
  kegg_id TEXT NOT NULL,
  pathway_id TEXT NOT NULL
) ;
.import ptr_gene_map2.txt pathway_ptr

.separator "\t"
CREATE TEMP TABLE ec_ptr (
  kegg_id TEXT NOT NULL,
  ec_id TEXT NOT NULL
) ;
.import ptr_ec2.txt ec_ptr

CREATE INDEX ptr1 on gene_ptr(kegg_id);
CREATE INDEX ptr2 on pathway_ptr(kegg_id);
CREATE INDEX ptr3 on ec_ptr(kegg_id);

CREATE TABLE ptr AS
 SELECT pathway_id, gene_id
 FROM pathway_ptr, gene_ptr
 WHERE pathway_ptr.kegg_id=gene_ptr.kegg_id;

CREATE TABLE ptr_ec AS
 SELECT DISTINCT ec_id, gene_id
 FROM ec_ptr, gene_ptr
 WHERE ec_ptr.kegg_id=gene_ptr.kegg_id;


