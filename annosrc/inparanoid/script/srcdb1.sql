.echo ON
.separator \t

-- a single inparanoid DB with all needed tables inside...

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);


CREATE TABLE homsa_aedae (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensAEDAE.fa-ensHOMSA.fa homsa_aedae
CREATE INDEX homsaaedae ON homsa_aedae(clust_id);

CREATE TABLE homsa_anoga (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensANOGA.fa-ensHOMSA.fa homsa_anoga
CREATE INDEX homsaanoga ON homsa_anoga(clust_id);

CREATE TABLE homsa_apime (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensAPIME.fa-ensHOMSA.fa homsa_apime
CREATE INDEX homsaapime ON homsa_apime(clust_id);

CREATE TABLE homsa_arath (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-modARATH.fa homsa_arath
CREATE INDEX homsaarath ON homsa_arath(clust_id);

CREATE TABLE homsa_bosta (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensBOSTA.fa-ensHOMSA.fa homsa_bosta
CREATE INDEX homsabosta ON homsa_bosta(clust_id);

CREATE TABLE homsa_caebr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAEBR.fa-ensHOMSA.fa homsa_caebr
CREATE INDEX homsacaebr ON homsa_caebr(clust_id);

CREATE TABLE homsa_caeel (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-modCAEEL.fa homsa_caeel
CREATE INDEX homsacaeel ON homsa_caeel(clust_id);

CREATE TABLE homsa_caere (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-modCAERE.fa homsa_caere
CREATE INDEX homsacaere ON homsa_caere(clust_id);

CREATE TABLE homsa_cangl (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ncbiCANGL.fa  homsa_cangl
CREATE INDEX homsacangl ON homsa_cangl(clust_id);

CREATE TABLE homsa_canfa (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensCANFA.fa-ensHOMSA.fa homsa_canfa
CREATE INDEX homsacanfa ON homsa_canfa(clust_id);

CREATE TABLE homsa_cioin (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensCIOIN.fa-ensHOMSA.fa homsa_cioin		
CREATE INDEX homsacioin ON homsa_cioin(clust_id);

CREATE TABLE homsa_cryne (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ncbiCRYNE.fa homsa_cryne
CREATE INDEX homsacryne ON homsa_cryne(clust_id);

CREATE TABLE homsa_danre (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-modDANRE.fa  homsa_danre
CREATE INDEX homsadanre ON homsa_danre(clust_id);

CREATE TABLE homsa_debha (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ncbiDEBHA.fa homsa_debha
CREATE INDEX homsadebha ON homsa_debha(clust_id);

CREATE TABLE homsa_dicdi (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-modDICDI.fa  homsa_dicdi
CREATE INDEX homsadicdi ON homsa_dicdi(clust_id);

CREATE TABLE homsa_drome (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30)UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-modDROME.fa homsa_drome
CREATE INDEX homsadrome ON homsa_drome(clust_id);

CREATE TABLE homsa_drops (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-flyDROPS.fa homsa_drops
CREATE INDEX homsadrops ON homsa_drops(clust_id);

CREATE TABLE homsa_enthi (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ncbiENTHI.fa homsa_enthi
CREATE INDEX homsaenthi ON homsa_enthi(clust_id);

CREATE TABLE homsa_escco (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ncbiESCCO.fa homsa_escco
CREATE INDEX homsaescco ON homsa_escco(clust_id);

CREATE TABLE homsa_galga (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensGALGA.fa-ensHOMSA.fa homsa_galga
CREATE INDEX homsagalga ON homsa_galga(clust_id);

CREATE TABLE homsa_gasac (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensGASAC.fa-ensHOMSA.fa homsa_gasac
CREATE INDEX homsagasac ON homsa_gasac(clust_id);

CREATE TABLE homsa_klula (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ncbiKLULA.fa homsa_klula
CREATE INDEX homsaklula ON homsa_klula(clust_id);

CREATE TABLE homsa_macmu (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ensMACMU.fa homsa_macmu
CREATE INDEX homsamacmu ON homsa_macmu(clust_id);

CREATE TABLE homsa_mondo (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ensMONDO.fa homsa_mondo
CREATE INDEX homsamondo ON homsa_mondo(clust_id);

CREATE TABLE homsa_musmu (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-modMUSMU.fa homsa_musmu
CREATE INDEX homsamusmu ON homsa_musmu(clust_id);

CREATE TABLE homsa_orysa (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-graORYSA.fa homsa_orysa
CREATE INDEX homsaorysa ON homsa_orysa(clust_id);

CREATE TABLE homsa_pantr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ensPANTR.fa homsa_pantr
CREATE INDEX homsapantr ON homsa_pantr(clust_id);

CREATE TABLE homsa_ratno (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ensRATNO.fa homsa_ratno
CREATE INDEX homsaratno ON homsa_ratno(clust_id);

CREATE TABLE homsa_sacce (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-modSACCE.fa homsa_sacce
CREATE INDEX homsasacce ON homsa_sacce(clust_id);

CREATE TABLE homsa_schpo (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-sanSCHPO.fa  homsa_schpo
CREATE INDEX homsaschpo ON homsa_schpo(clust_id);

CREATE TABLE homsa_fugru (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ensFUGRU.fa  homsa_fugru
CREATE INDEX homsafugru ON homsa_fugru(clust_id);

CREATE TABLE homsa_tetni (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ensTETNI.fa homsa_tetni
CREATE INDEX homsatetni ON homsa_tetni(clust_id);

CREATE TABLE homsa_xentr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ensXENTR.fa homsa_xentr
CREATE INDEX homsaxentr ON homsa_xentr(clust_id);

CREATE TABLE homsa_yarli (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensHOMSA.fa-ncbiYARLI.fa homsa_yarli
CREATE INDEX homsayarli ON homsa_yarli(clust_id);

--End Human maps


--Start Mouse maps

CREATE TABLE musmu_aedae (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensAEDAE.fa-modMUSMU.fa musmu_aedae
CREATE INDEX musmuaedae ON musmu_aedae(clust_id);

CREATE TABLE musmu_anoga (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensANOGA.fa-modMUSMU.fa musmu_anoga
CREATE INDEX musmuanoga ON musmu_anoga(clust_id);

CREATE TABLE musmu_apime (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensAPIME.fa-modMUSMU.fa musmu_apime
CREATE INDEX musmuapime ON musmu_apime(clust_id);

CREATE TABLE musmu_arath (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modARATH.fa-modMUSMU.fa musmu_arath
CREATE INDEX musmuarath ON musmu_arath(clust_id);

CREATE TABLE musmu_bosta (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensBOSTA.fa-modMUSMU.fa musmu_bosta
CREATE INDEX musmubosta ON musmu_bosta(clust_id);

CREATE TABLE musmu_caebr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAEBR.fa-modMUSMU.fa musmu_caebr
CREATE INDEX musmucaebr ON musmu_caebr(clust_id);

CREATE TABLE musmu_caeel (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAEEL.fa-modMUSMU.fa musmu_caeel
CREATE INDEX musmucaeel ON musmu_caeel(clust_id);

CREATE TABLE musmu_caere (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAERE.fa-modMUSMU.fa musmu_caere
CREATE INDEX musmucaere ON musmu_caere(clust_id);

CREATE TABLE musmu_cangl (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modMUSMU.fa-ncbiCANGL.fa  musmu_cangl
CREATE INDEX musmucangl ON musmu_cangl(clust_id);

CREATE TABLE musmu_canfa (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensCANFA.fa-modMUSMU.fa musmu_canfa
CREATE INDEX musmucanfa ON musmu_canfa(clust_id);

CREATE TABLE musmu_cioin (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensCIOIN.fa-modMUSMU.fa musmu_cioin		
CREATE INDEX musmucioin ON musmu_cioin(clust_id);

CREATE TABLE musmu_cryne (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modMUSMU.fa-ncbiCRYNE.fa musmu_cryne
CREATE INDEX musmucryne ON musmu_cryne(clust_id);

CREATE TABLE musmu_danre (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDANRE.fa-modMUSMU.fa  musmu_danre
CREATE INDEX musmudanre ON musmu_danre(clust_id);

CREATE TABLE musmu_debha (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modMUSMU.fa-ncbiDEBHA.fa musmu_debha
CREATE INDEX musmudebha ON musmu_debha(clust_id);

CREATE TABLE musmu_dicdi (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDICDI.fa-modMUSMU.fa  musmu_dicdi
CREATE INDEX musmudicdi ON musmu_dicdi(clust_id);

CREATE TABLE musmu_drome (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30)UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDROME.fa-modMUSMU.fa  musmu_drome
CREATE INDEX musmudrome ON musmu_drome(clust_id);

CREATE TABLE musmu_drops (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.flyDROPS.fa-modMUSMU.fa musmu_drops
CREATE INDEX musmudrops ON musmu_drops(clust_id);

CREATE TABLE musmu_enthi (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modMUSMU.fa-ncbiENTHI.fa musmu_enthi
CREATE INDEX musmuenthi ON musmu_enthi(clust_id);

CREATE TABLE musmu_escco (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modMUSMU.fa-ncbiESCCO.fa musmu_escco
CREATE INDEX musmuescco ON musmu_escco(clust_id);

CREATE TABLE musmu_galga (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensGALGA.fa-modMUSMU.fa musmu_galga
CREATE INDEX musmugalga ON musmu_galga(clust_id);

CREATE TABLE musmu_gasac (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensGASAC.fa-modMUSMU.fa musmu_gasac
CREATE INDEX musmugasac ON musmu_gasac(clust_id);

CREATE TABLE musmu_klula (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modMUSMU.fa-ncbiKLULA.fa musmu_klula
CREATE INDEX musmuklula ON musmu_klula(clust_id);

CREATE TABLE musmu_macmu (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensMACMU.fa-modMUSMU.fa musmu_macmu
CREATE INDEX musmumacmu ON musmu_macmu(clust_id);

CREATE TABLE musmu_mondo (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensMONDO.fa-modMUSMU.fa musmu_mondo
CREATE INDEX musmumondo ON musmu_mondo(clust_id);

CREATE TABLE musmu_orysa (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.graORYSA.fa-modMUSMU.fa musmu_orysa
CREATE INDEX musmuorysa ON musmu_orysa(clust_id);

CREATE TABLE musmu_pantr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensPANTR.fa-modMUSMU.fa musmu_pantr
CREATE INDEX musmupantr ON musmu_pantr(clust_id);

CREATE TABLE musmu_ratno (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-modMUSMU.fa musmu_ratno
CREATE INDEX musmuratno ON musmu_ratno(clust_id);

CREATE TABLE musmu_sacce (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modMUSMU.fa-modSACCE.fa musmu_sacce
CREATE INDEX musmusacce ON musmu_sacce(clust_id);

CREATE TABLE musmu_schpo (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modMUSMU.fa-sanSCHPO.fa musmu_schpo
CREATE INDEX musmuschpo ON musmu_schpo(clust_id);

CREATE TABLE musmu_fugru (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensFUGRU.fa-modMUSMU.fa  musmu_fugru
CREATE INDEX musmufugru ON musmu_fugru(clust_id);

CREATE TABLE musmu_tetni (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensTETNI.fa-modMUSMU.fa musmu_tetni
CREATE INDEX musmutetni ON musmu_tetni(clust_id);

CREATE TABLE musmu_xentr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensXENTR.fa-modMUSMU.fa  musmu_xentr
CREATE INDEX musmuxentr ON musmu_xentr(clust_id);

CREATE TABLE musmu_yarli (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modMUSMU.fa-ncbiYARLI.fa musmu_yarli
CREATE INDEX musmuyarli ON musmu_yarli(clust_id);

--End Mouse maps


--Start Rat maps

CREATE TABLE ratno_aedae (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensAEDAE.fa-ensRATNO.fa ratno_aedae
CREATE INDEX ratnoaedae ON ratno_aedae(clust_id);

CREATE TABLE ratno_anoga (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensANOGA.fa-ensRATNO.fa ratno_anoga
CREATE INDEX ratnoanoga ON ratno_anoga(clust_id);

CREATE TABLE ratno_apime (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensAPIME.fa-ensRATNO.fa ratno_apime
CREATE INDEX ratnoapime ON ratno_apime(clust_id);

CREATE TABLE ratno_arath (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-modARATH.fa ratno_arath
CREATE INDEX ratnoarath ON ratno_arath(clust_id);

CREATE TABLE ratno_bosta (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensBOSTA.fa-ensRATNO.fa ratno_bosta
CREATE INDEX ratnobosta ON ratno_bosta(clust_id);

CREATE TABLE ratno_caebr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAEBR.fa-ensRATNO.fa ratno_caebr
CREATE INDEX ratnocaebr ON ratno_caebr(clust_id);

CREATE TABLE ratno_caeel (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-modCAEEL.fa ratno_caeel
CREATE INDEX ratnocaeel ON ratno_caeel(clust_id);

CREATE TABLE ratno_caere (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-modCAERE.fa ratno_caere
CREATE INDEX ratnocaere ON ratno_caere(clust_id);

CREATE TABLE ratno_cangl (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-ncbiCANGL.fa  ratno_cangl
CREATE INDEX ratnocangl ON ratno_cangl(clust_id);

CREATE TABLE ratno_canfa (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensCANFA.fa-ensRATNO.fa ratno_canfa
CREATE INDEX ratnocanfa ON ratno_canfa(clust_id);

CREATE TABLE ratno_cioin (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensCIOIN.fa-ensRATNO.fa ratno_cioin		
CREATE INDEX ratnocioin ON ratno_cioin(clust_id);

CREATE TABLE ratno_cryne (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-ncbiCRYNE.fa ratno_cryne
CREATE INDEX ratnocryne ON ratno_cryne(clust_id);

CREATE TABLE ratno_danre (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-modDANRE.fa  ratno_danre
CREATE INDEX ratnodanre ON ratno_danre(clust_id);

CREATE TABLE ratno_debha (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-ncbiDEBHA.fa ratno_debha
CREATE INDEX ratnodebha ON ratno_debha(clust_id);

CREATE TABLE ratno_dicdi (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-modDICDI.fa  ratno_dicdi
CREATE INDEX ratnodicdi ON ratno_dicdi(clust_id);

CREATE TABLE ratno_drome (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30)UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-modDROME.fa ratno_drome
CREATE INDEX ratnodrome ON ratno_drome(clust_id);

CREATE TABLE ratno_drops (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-flyDROPS.fa ratno_drops
CREATE INDEX ratnodrops ON ratno_drops(clust_id);

CREATE TABLE ratno_enthi (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-ncbiENTHI.fa ratno_enthi
CREATE INDEX ratnoenthi ON ratno_enthi(clust_id);

CREATE TABLE ratno_escco (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-ncbiESCCO.fa ratno_escco
CREATE INDEX ratnoescco ON ratno_escco(clust_id);

CREATE TABLE ratno_galga (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensGALGA.fa-ensRATNO.fa ratno_galga
CREATE INDEX ratnogalga ON ratno_galga(clust_id);

CREATE TABLE ratno_gasac (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensGASAC.fa-ensRATNO.fa ratno_gasac
CREATE INDEX ratnogasac ON ratno_gasac(clust_id);

CREATE TABLE ratno_klula (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-ncbiKLULA.fa ratno_klula
CREATE INDEX ratnoklula ON ratno_klula(clust_id);

CREATE TABLE ratno_macmu (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensMACMU.fa-ensRATNO.fa ratno_macmu
CREATE INDEX ratnomacmu ON ratno_macmu(clust_id);

CREATE TABLE ratno_mondo (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensMONDO.fa-ensRATNO.fa ratno_mondo
CREATE INDEX ratnomondo ON ratno_mondo(clust_id);

CREATE TABLE ratno_orysa (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-graORYSA.fa ratno_orysa
CREATE INDEX ratnoorysa ON ratno_orysa(clust_id);

CREATE TABLE ratno_pantr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensPANTR.fa-ensRATNO.fa ratno_pantr
CREATE INDEX ratnopantr ON ratno_pantr(clust_id);

CREATE TABLE ratno_sacce (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-modSACCE.fa ratno_sacce
CREATE INDEX ratnosacce ON ratno_sacce(clust_id);

CREATE TABLE ratno_schpo (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-sanSCHPO.fa ratno_schpo
CREATE INDEX ratnoschpo ON ratno_schpo(clust_id);

CREATE TABLE ratno_fugru (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-ensFUGRU.fa  ratno_fugru
CREATE INDEX ratnofugru ON ratno_fugru(clust_id);

CREATE TABLE ratno_tetni (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-ensTETNI.fa ratno_tetni
CREATE INDEX ratnotetni ON ratno_tetni(clust_id);

CREATE TABLE ratno_xentr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-ensXENTR.fa ratno_xentr
CREATE INDEX ratnoxentr ON ratno_xentr(clust_id);

CREATE TABLE ratno_yarli (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensRATNO.fa-ncbiYARLI.fa ratno_yarli
CREATE INDEX ratnoyarli ON ratno_yarli(clust_id);

--End Rat maps


--Start Fly maps

CREATE TABLE drome_aedae (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensAEDAE.fa-modDROME.fa drome_aedae
CREATE INDEX dromeaedae ON drome_aedae(clust_id);

CREATE TABLE drome_anoga (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensANOGA.fa-modDROME.fa drome_anoga
CREATE INDEX dromeanoga ON drome_anoga(clust_id);

CREATE TABLE drome_apime (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensAPIME.fa-modDROME.fa drome_apime
CREATE INDEX dromeapime ON drome_apime(clust_id);

CREATE TABLE drome_arath (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modARATH.fa-modDROME.fa drome_arath
CREATE INDEX dromearath ON drome_arath(clust_id);

CREATE TABLE drome_bosta (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensBOSTA.fa-modDROME.fa drome_bosta
CREATE INDEX dromebosta ON drome_bosta(clust_id);

CREATE TABLE drome_caebr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAEBR.fa-modDROME.fa drome_caebr
CREATE INDEX dromecaebr ON drome_caebr(clust_id);

CREATE TABLE drome_caeel (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAEEL.fa-modDROME.fa drome_caeel
CREATE INDEX dromecaeel ON drome_caeel(clust_id);

CREATE TABLE drome_caere (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAERE.fa-modDROME.fa drome_caere
CREATE INDEX dromecaere ON drome_caere(clust_id);

CREATE TABLE drome_cangl (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDROME.fa-ncbiCANGL.fa  drome_cangl
CREATE INDEX dromecangl ON drome_cangl(clust_id);

CREATE TABLE drome_canfa (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensCANFA.fa-modDROME.fa drome_canfa
CREATE INDEX dromecanfa ON drome_canfa(clust_id);

CREATE TABLE drome_cioin (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensCIOIN.fa-modDROME.fa drome_cioin		
CREATE INDEX dromecioin ON drome_cioin(clust_id);

CREATE TABLE drome_cryne (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDROME.fa-ncbiCRYNE.fa drome_cryne
CREATE INDEX dromecryne ON drome_cryne(clust_id);

CREATE TABLE drome_danre (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDANRE.fa-modDROME.fa drome_danre
CREATE INDEX dromedanre ON drome_danre(clust_id);

CREATE TABLE drome_debha (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDROME.fa-ncbiDEBHA.fa drome_debha
CREATE INDEX dromedebha ON drome_debha(clust_id);

CREATE TABLE drome_dicdi (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDICDI.fa-modDROME.fa drome_dicdi
CREATE INDEX dromedicdi ON drome_dicdi(clust_id);

CREATE TABLE drome_drops (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.flyDROPS.fa-modDROME.fa drome_drops
CREATE INDEX dromedrops ON drome_drops(clust_id);

CREATE TABLE drome_enthi (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDROME.fa-ncbiENTHI.fa drome_enthi
CREATE INDEX dromeenthi ON drome_enthi(clust_id);

CREATE TABLE drome_escco (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDROME.fa-ncbiESCCO.fa drome_escco
CREATE INDEX dromeescco ON drome_escco(clust_id);

CREATE TABLE drome_galga (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensGALGA.fa-modDROME.fa drome_galga
CREATE INDEX dromegalga ON drome_galga(clust_id);

CREATE TABLE drome_gasac (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensGASAC.fa-modDROME.fa drome_gasac
CREATE INDEX dromegasac ON drome_gasac(clust_id);

CREATE TABLE drome_klula (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDROME.fa-ncbiKLULA.fa drome_klula
CREATE INDEX dromeklula ON drome_klula(clust_id);

CREATE TABLE drome_macmu (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensMACMU.fa-modDROME.fa drome_macmu
CREATE INDEX dromemacmu ON drome_macmu(clust_id);

CREATE TABLE drome_mondo (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensMONDO.fa-modDROME.fa drome_mondo
CREATE INDEX dromemondo ON drome_mondo(clust_id);

CREATE TABLE drome_orysa (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.graORYSA.fa-modDROME.fa drome_orysa
CREATE INDEX dromeorysa ON drome_orysa(clust_id);

CREATE TABLE drome_pantr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensPANTR.fa-modDROME.fa drome_pantr
CREATE INDEX dromepantr ON drome_pantr(clust_id);

CREATE TABLE drome_sacce (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDROME.fa-modSACCE.fa drome_sacce
CREATE INDEX dromesacce ON drome_sacce(clust_id);

CREATE TABLE drome_schpo (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDROME.fa-sanSCHPO.fa drome_schpo
CREATE INDEX dromeschpo ON drome_schpo(clust_id);

CREATE TABLE drome_fugru (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensFUGRU.fa-modDROME.fa drome_fugru
CREATE INDEX dromefugru ON drome_fugru(clust_id);

CREATE TABLE drome_tetni (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensTETNI.fa-modDROME.fa drome_tetni
CREATE INDEX drometetni ON drome_tetni(clust_id);

CREATE TABLE drome_xentr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensXENTR.fa-modDROME.fa drome_xentr
CREATE INDEX dromexentr ON drome_xentr(clust_id);

CREATE TABLE drome_yarli (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDROME.fa-ncbiYARLI.fa drome_yarli
CREATE INDEX dromeyarli ON drome_yarli(clust_id);

--End Fly Maps
 

--Start Yeast maps

CREATE TABLE sacce_aedae (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensAEDAE.fa-modSACCE.fa sacce_aedae
CREATE INDEX sacceaedae ON sacce_aedae(clust_id);

CREATE TABLE sacce_anoga (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensANOGA.fa-modSACCE.fa sacce_anoga
CREATE INDEX sacceanoga ON sacce_anoga(clust_id);

CREATE TABLE sacce_apime (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensAPIME.fa-modSACCE.fa sacce_apime
CREATE INDEX sacceapime ON sacce_apime(clust_id);

CREATE TABLE sacce_arath (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modARATH.fa-modSACCE.fa sacce_arath
CREATE INDEX saccearath ON sacce_arath(clust_id);

CREATE TABLE sacce_bosta (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensBOSTA.fa-modSACCE.fa sacce_bosta
CREATE INDEX saccebosta ON sacce_bosta(clust_id);

CREATE TABLE sacce_caebr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAEBR.fa-modSACCE.fa sacce_caebr
CREATE INDEX saccecaebr ON sacce_caebr(clust_id);

CREATE TABLE sacce_caeel (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAEEL.fa-modSACCE.fa sacce_caeel
CREATE INDEX saccecaeel ON sacce_caeel(clust_id);

CREATE TABLE sacce_caere (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modCAERE.fa-modSACCE.fa sacce_caere
CREATE INDEX saccecaere ON sacce_caere(clust_id);

CREATE TABLE sacce_cangl (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modSACCE.fa-ncbiCANGL.fa  sacce_cangl
CREATE INDEX saccecangl ON sacce_cangl(clust_id);

CREATE TABLE sacce_canfa (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensCANFA.fa-modSACCE.fa sacce_canfa
CREATE INDEX saccecanfa ON sacce_canfa(clust_id);

CREATE TABLE sacce_cioin (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensCIOIN.fa-modSACCE.fa sacce_cioin		
CREATE INDEX saccecioin ON sacce_cioin(clust_id);

CREATE TABLE sacce_cryne (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modSACCE.fa-ncbiCRYNE.fa sacce_cryne
CREATE INDEX saccecryne ON sacce_cryne(clust_id);

CREATE TABLE sacce_danre (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDANRE.fa-modSACCE.fa sacce_danre
CREATE INDEX saccedanre ON sacce_danre(clust_id);

CREATE TABLE sacce_debha (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modSACCE.fa-ncbiDEBHA.fa sacce_debha
CREATE INDEX saccedebha ON sacce_debha(clust_id);

CREATE TABLE sacce_dicdi (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modDICDI.fa-modSACCE.fa sacce_dicdi
CREATE INDEX saccedicdi ON sacce_dicdi(clust_id);

CREATE TABLE sacce_drops (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.flyDROPS.fa-modSACCE.fa sacce_drops
CREATE INDEX saccedrops ON sacce_drops(clust_id);

CREATE TABLE sacce_enthi (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modSACCE.fa-ncbiENTHI.fa sacce_enthi
CREATE INDEX sacceenthi ON sacce_enthi(clust_id);

CREATE TABLE sacce_escco (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modSACCE.fa-ncbiESCCO.fa sacce_escco
CREATE INDEX sacceescco ON sacce_escco(clust_id);

CREATE TABLE sacce_galga (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensGALGA.fa-modSACCE.fa sacce_galga
CREATE INDEX saccegalga ON sacce_galga(clust_id);

CREATE TABLE sacce_gasac (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensGASAC.fa-modSACCE.fa sacce_gasac
CREATE INDEX saccegasac ON sacce_gasac(clust_id);

CREATE TABLE sacce_klula (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modSACCE.fa-ncbiKLULA.fa sacce_klula
CREATE INDEX sacceklula ON sacce_klula(clust_id);

CREATE TABLE sacce_macmu (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensMACMU.fa-modSACCE.fa sacce_macmu
CREATE INDEX saccemacmu ON sacce_macmu(clust_id);

CREATE TABLE sacce_mondo (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensMONDO.fa-modSACCE.fa sacce_mondo
CREATE INDEX saccemondo ON sacce_mondo(clust_id);

CREATE TABLE sacce_orysa (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.graORYSA.fa-modSACCE.fa sacce_orysa
CREATE INDEX sacceorysa ON sacce_orysa(clust_id);

CREATE TABLE sacce_pantr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensPANTR.fa-modSACCE.fa sacce_pantr
CREATE INDEX saccepantr ON sacce_pantr(clust_id);

CREATE TABLE sacce_schpo (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modSACCE.fa-sanSCHPO.fa sacce_schpo
CREATE INDEX sacceschpo ON sacce_schpo(clust_id);

CREATE TABLE sacce_fugru (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensFUGRU.fa-modSACCE.fa sacce_fugru
CREATE INDEX saccefugru ON sacce_fugru(clust_id);

CREATE TABLE sacce_tetni (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensTETNI.fa-modSACCE.fa sacce_tetni
CREATE INDEX saccetetni ON sacce_tetni(clust_id);

CREATE TABLE sacce_xentr (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.ensXENTR.fa-modSACCE.fa sacce_xentr
CREATE INDEX saccexentr ON sacce_xentr(clust_id);

CREATE TABLE sacce_yarli (
 clust_id INTEGER NOT NULL,
 clu2 VARCHAR(10) NOT NULL,
 species VARCHAR(15) NOT NULL,
 score VARCHAR(6) NOT NULL,
 ID VARCHAR(30) UNIQUE NOT NULL,
 seed_status CHAR(4)
);
.import sqltable.modSACCE.fa-ncbiYARLI.fa sacce_yarli
CREATE INDEX sacceyarli ON sacce_yarli(clust_id);

--End Yeast maps


ANALYZE;
