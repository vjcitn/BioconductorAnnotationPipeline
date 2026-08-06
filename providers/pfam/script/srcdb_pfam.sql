.echo ON
.mode tabs

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);


CREATE TEMP TABLE tcazy (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 cazy VARCHAR(6) NOT NULL               --CAZY ID
);
.import CAZYs.tab tcazy

CREATE TABLE cazy (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 cazy VARCHAR(6) NOT NULL               --CAZY ID
);

INSERT INTO cazy
 SELECT substr(trim(ac),1,7), trim(cazy)
 FROM tcazy;

CREATE INDEX cazy_ac ON cazy(ac);


CREATE TEMP TABLE thomstrad (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 homstrad VARCHAR(20) NOT NULL          --HOMSTRAD ID
);
.import HOMSTRADs.tab thomstrad

CREATE TABLE homstrad (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 homstrad VARCHAR(20) NOT NULL          --HOMSTRAD ID
);

INSERT INTO homstrad
 SELECT substr(trim(ac),1,7), trim(homstrad)
 FROM thomstrad;

CREATE INDEX homstrad_ac ON homstrad(ac);


CREATE TEMP TABLE tinterpro (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 interpro VARCHAR(9) NOT NULL           --INTERPRO ID
);
.import INTERPROs.tab tinterpro

CREATE TABLE interpro (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 interpro VARCHAR(9) NOT NULL           --INTERPRO ID
);

INSERT INTO interpro
 SELECT substr(trim(ac),1,7), trim(interpro)
 FROM tinterpro;

CREATE INDEX interpro_ac ON interpro(ac);



CREATE TEMP TABLE tload (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 load VARCHAR(15) NOT NULL               --LOAD ID
);
.import LOADs.tab tload

CREATE TABLE load (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 load VARCHAR(15) NOT NULL               --LOAD ID
);

INSERT INTO load
 SELECT substr(trim(ac),1,7), trim(load)
 FROM tload;

CREATE INDEX load_ac ON load(ac);


CREATE TEMP TABLE tmerops (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 merops VARCHAR(3) NOT NULL             --MEROPS ID
);
.import MEROPSs.tab tmerops

CREATE TABLE merops (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 merops VARCHAR(3) NOT NULL             --MEROPS ID
);

INSERT INTO merops
 SELECT substr(trim(ac),1,7), trim(merops)
 FROM tmerops;

CREATE INDEX merops_ac ON merops(ac);


CREATE TEMP TABLE tmim (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 mim VARCHAR(6) NOT NULL                --MIM ID
);
.import MIMs.tab tmim

CREATE TABLE mim (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 mim VARCHAR(6) NOT NULL                --MIM ID
);

INSERT INTO mim
 SELECT substr(trim(ac),1,7), trim(mim)
 FROM tmim;

CREATE INDEX mim_ac ON mim(ac);


--Section to assemble the pdb table
-- CREATE TEMP TABLE ac_seq(
--  seq_id VARCHAR(25) NOT NULL,
--  tag CHAR(2),
--  ac VARCHAR(12)
-- );
-- .import GS_ACs.tab ac_seq

-- CREATE INDEX ac_seq_seq on ac_seq(seq_id);

-- CREATE TEMP TABLE pdb_seq(
--  seq_id VARCHAR(25) NOT NULL,
--  tag CHAR(2),
--  tag2 CHAR(3),
--  pdb VARCHAR(7),
--  start_point INTEGER,
--  end_point INTEGER
-- );
-- .import GS_DRs.tab pdb_seq

-- CREATE INDEX pdb_seq_seq on pdb_seq(seq_id);

-- CREATE TABLE pdb (
--  ac VARCHAR(12)  NOT NULL,		--AC ID
--  pdb VARCHAR(6) NOT NULL,            	--PDB ID
--  start_point INTEGER,			--start of alignment
--  end_point INTEGER			--end of alignment
-- );

-- -- INSERT INTO pdb
-- -- SELECT substr(trim(a.ac),1,7), 
-- -- trim(p.pdb), trim(p.start_point), trim(p.end_point)
-- -- FROM ac_seq as a INNER JOIN pdb_seq as p
-- -- WHERE a.seq_id=p.seq_id;

-- INSERT INTO pdb
-- SELECT trim(a.ac), 
-- trim(p.pdb), trim(p.start_point), trim(p.end_point)
-- FROM ac_seq as a INNER JOIN pdb_seq as p
-- WHERE a.seq_id=p.seq_id;


-- CREATE INDEX pdb_ac ON pdb(ac);

-- DROP TABLE ac_seq;
-- DROP TABLE pdb_seq;

CREATE TEMP TABLE tpdb (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 pdb VARCHAR(6) NOT NULL,            	--PDB ID
 start_point INTEGER,			--start of alignment
 end_point INTEGER			--end of alignment
);
.import PDBs.tab tpdb

CREATE TABLE pdb (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 pdb VARCHAR(6) NOT NULL,            	--PDB ID
 start_point INTEGER,			--start of alignment
 end_point INTEGER			--end of alignment
);

INSERT INTO pdb
 SELECT substr(trim(ac),1,7), trim(pdb), 
 trim(start_point), trim(end_point)
 FROM tpdb;

CREATE INDEX pdb_ac ON pdb(ac);



-- -- more simple tables follow
-- CREATE TEMP TABLE tpfamb (
--  ac VARCHAR(12)  NOT NULL,		--AC ID
--  pfamb VARCHAR(8) NOT NULL              --PFAMB ID
-- );
-- .import PFAMBs.tab tpfamb

-- CREATE TABLE pfamb (
--  ac VARCHAR(12)  NOT NULL,		--AC ID
--  pfamb VARCHAR(8) NOT NULL              --PFAMB ID
-- );

-- INSERT INTO pfamb
--  SELECT substr(trim(ac),1,7), trim(pfamb)
--  FROM tpfamb;

-- CREATE INDEX pfamb_ac ON pfamb(ac);


CREATE TEMP TABLE tprints (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 prints VARCHAR(7) NOT NULL             --PRINTS ID
);
.import PRINTSs.tab tprints

CREATE TABLE prints (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 prints VARCHAR(7) NOT NULL             --PRINTS ID
);

INSERT INTO prints
 SELECT substr(trim(ac),1,7), trim(prints)
 FROM tprints;

CREATE INDEX prints_ac ON prints(ac);


CREATE TEMP TABLE tprosite (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 prosite VARCHAR(9) NOT NULL            --PROSITE ID
);
.import PROSITEs.tab tprosite

CREATE TABLE prosite (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 prosite VARCHAR(9) NOT NULL            --PROSITE ID
);

INSERT INTO prosite
 SELECT substr(trim(ac),1,7), trim(prosite)
 FROM tprosite;

CREATE INDEX prosite_ac ON prosite(ac);


CREATE TEMP TABLE tprosite_profile (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 prosite_profile VARCHAR(7) NOT NULL    --PROSITE_PROFILE ID
);
.import PROSITE_PROFILEs.tab tprosite_profile

CREATE TABLE prosite_profile (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 prosite_profile VARCHAR(7) NOT NULL    --PROSITE_PROFILE ID
);

INSERT INTO prosite_profile
 SELECT substr(trim(ac),1,7), trim(prosite_profile)
 FROM tprosite_profile;

CREATE INDEX prosite_profile_ac ON prosite_profile(ac);


CREATE TEMP TABLE trm (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 rm VARCHAR(8) NOT NULL                 --RM ID
);
.import RMs.tab trm

CREATE TABLE rm (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 rm VARCHAR(8) NOT NULL                 --RM ID
);

INSERT INTO rm
 SELECT substr(trim(ac),1,7), trim(rm)
 FROM trm;

CREATE INDEX rm_ac ON rm(ac);


CREATE TEMP TABLE tscop (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 scop VARCHAR(4) NOT NULL,              --SCOP ID
 placement VARCHAR(2) NOT NULL		--SCOP placement
);
.import SCOPs.tab tscop

CREATE TABLE scop (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 scop VARCHAR(4) NOT NULL,              --SCOP ID
 placement VARCHAR(2) NOT NULL		--SCOP placement
);

INSERT INTO scop
 SELECT substr(trim(ac),1,7), trim(scop), trim(placement)
 FROM tscop;

CREATE INDEX scop_ac ON scop(ac);


CREATE TEMP TABLE tsmart (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 smart VARCHAR(9) NOT NULL              --SMART ID
);
.import SMARTs.tab tsmart

CREATE TABLE smart (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 smart VARCHAR(9) NOT NULL              --SMART ID
);

INSERT INTO smart
 SELECT substr(trim(ac),1,7), trim(smart)
 FROM tsmart;

CREATE INDEX smart_ac ON smart(ac);


CREATE TEMP TABLE ttc (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 tc VARCHAR(6) NOT NULL                 --TC ID
);
.import TCs.tab ttc

CREATE TABLE tc (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 tc VARCHAR(6) NOT NULL                 --TC ID
);

INSERT INTO tc
 SELECT substr(trim(ac),1,7), trim(tc)
 FROM ttc;

CREATE INDEX tc_ac ON tc(ac);


CREATE TEMP TABLE turl (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 url VARCHAR(80) NOT NULL      		--URL ID
);
.import URLs.tab turl

CREATE TABLE url (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 url VARCHAR(80) NOT NULL      		--URL ID
);

INSERT INTO url
 SELECT substr(trim(ac),1,7), trim(url)
 FROM turl;

CREATE INDEX url_ac ON url(ac);




--I also need tables for the ID, DE and TP data

CREATE TEMP TABLE tid (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 id VARCHAR(15) NOT NULL                --ID ID
);
.import IDs.tab tid

CREATE TABLE id (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 id VARCHAR(15) NOT NULL                --ID ID
);

INSERT INTO id
 SELECT substr(trim(ac),1,7), trim(id)
 FROM tid;

CREATE INDEX id_ac ON id(ac);


CREATE TEMP TABLE tde (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 de VARCHAR(80) NOT NULL                --DE ID
);
.import DEs.tab tde

CREATE TABLE de (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 de VARCHAR(80) NOT NULL                --DE ID
);

INSERT INTO de
 SELECT substr(trim(ac),1,7), trim(de)
 FROM tde;

CREATE INDEX de_ac ON de(ac);


CREATE TEMP TABLE ttp (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 tp VARCHAR(6) NOT NULL                 --TP ID
);
.import TPs.tab ttp

CREATE TABLE tp (
 ac VARCHAR(12)  NOT NULL,		--AC ID
 tp VARCHAR(6) NOT NULL                 --TP ID
);

INSERT INTO tp
 SELECT substr(trim(ac),1,7), trim(tp)
 FROM ttp;

CREATE INDEX tp_ac ON tp(ac);



--OLD STYLE way was to jam these into one table 
--(I don't know why since there is not a compond map on offer)
-- CREATE TABLE basic_info (
--  ac VARCHAR(12)  NOT NULL,     	--AC ID
--  id VARCHAR(15),               	--ID
--  de VARCHAR(80),    			--AC Definition
--  tp VARCHAR(6),			--Type Field
-- );
-- .import BASIC_INFOs.tab basic_info

-- CREATE INDEX basic_info_ac ON basic_info(ac);


