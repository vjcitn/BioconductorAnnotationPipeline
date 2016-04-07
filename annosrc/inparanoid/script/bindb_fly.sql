.echo ON
ATTACH DATABASE "inparanoid.sqlite" AS inp;
ATTACH DATABASE '../../db/metadatasrc.sqlite' AS meta;

CREATE TABLE aedes_aegypti (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO aedes_aegypti
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_aedae;
CREATE INDEX aedae_c ON aedes_aegypti(clust_id);
CREATE INDEX aedae_s ON aedes_aegypti(species);

CREATE TABLE anopheles_gambiae (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO anopheles_gambiae
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_anoga;
CREATE INDEX anoga_c ON anopheles_gambiae(clust_id);
CREATE INDEX anoga_s ON anopheles_gambiae(species);

CREATE TABLE apis_mellifera (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO apis_mellifera
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_apime;
CREATE INDEX apime_c ON apis_mellifera(clust_id);
CREATE INDEX apime_s ON apis_mellifera(species);

CREATE TABLE arabidopsis_thaliana (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO arabidopsis_thaliana
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_arath;
CREATE INDEX arath_c ON arabidopsis_thaliana(clust_id);
CREATE INDEX arath_s ON arabidopsis_thaliana(species);

CREATE TABLE bos_taurus (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO bos_taurus
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_bosta;
CREATE INDEX bosta_c ON bos_taurus(clust_id);
CREATE INDEX bosta_s ON bos_taurus(species);

CREATE TABLE caenorhabditis_briggsae (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO caenorhabditis_briggsae
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_caebr;
CREATE INDEX caebr_c ON caenorhabditis_briggsae(clust_id);
CREATE INDEX caebr_s ON caenorhabditis_briggsae(species);

CREATE TABLE caenorhabditis_elegans (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO caenorhabditis_elegans
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_caeel;
CREATE INDEX caeel_c ON caenorhabditis_elegans(clust_id);
CREATE INDEX caeel_s ON caenorhabditis_elegans(species);

CREATE TABLE caenorhabditis_remanei (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO caenorhabditis_remanei
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_caere;
CREATE INDEX caere_c ON caenorhabditis_remanei(clust_id);
CREATE INDEX caere_s ON caenorhabditis_remanei(species);

CREATE TABLE candida_glabrata (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO candida_glabrata
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_cangl;
CREATE INDEX cangl_c ON candida_glabrata(clust_id);
CREATE INDEX cangl_s ON candida_glabrata(species);

CREATE TABLE canis_familiaris (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO canis_familiaris
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_canfa;
CREATE INDEX canfa_c ON canis_familiaris(clust_id);
CREATE INDEX canfa_s ON canis_familiaris(species);

CREATE TABLE ciona_intestinalis (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO ciona_intestinalis
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_cioin;
CREATE INDEX cioin_c ON ciona_intestinalis(clust_id);
CREATE INDEX cioin_s ON ciona_intestinalis(species);

CREATE TABLE cryptococcus_neoformans (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO cryptococcus_neoformans
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_cryne;
CREATE INDEX cryne_c ON cryptococcus_neoformans(clust_id);
CREATE INDEX cryne_s ON cryptococcus_neoformans(species);

CREATE TABLE danio_rerio (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO danio_rerio
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_danre;
CREATE INDEX danre_c ON danio_rerio(clust_id);
CREATE INDEX danre_s ON danio_rerio(species);

CREATE TABLE debaryomyces_hanseneii (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO debaryomyces_hanseneii
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_debha;
CREATE INDEX debha_c ON debaryomyces_hanseneii(clust_id);
CREATE INDEX debha_s ON debaryomyces_hanseneii(species);

CREATE TABLE dictyostelium_discoideum (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO dictyostelium_discoideum
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_dicdi;
CREATE INDEX dicdi_c ON dictyostelium_discoideum(clust_id);
CREATE INDEX dicdi_s ON dictyostelium_discoideum(species);

CREATE TABLE homo_sapiens (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO homo_sapiens
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.homsa_drome;
CREATE INDEX drome_c ON homo_sapiens(clust_id);
CREATE INDEX drome_s ON homo_sapiens(species);

CREATE TABLE drosophila_pseudoobscura (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO drosophila_pseudoobscura
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_drops;
CREATE INDEX drops_c ON drosophila_pseudoobscura(clust_id);
CREATE INDEX drops_s ON drosophila_pseudoobscura(species);

CREATE TABLE entamoeba_histolytica (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO entamoeba_histolytica
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_enthi;
CREATE INDEX enthi_c ON entamoeba_histolytica(clust_id);
CREATE INDEX enthi_s ON entamoeba_histolytica(species);

CREATE TABLE escherichia_coliK12 (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO escherichia_coliK12
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_escco;
CREATE INDEX escco_c ON escherichia_coliK12(clust_id);
CREATE INDEX escco_s ON escherichia_coliK12(species);

CREATE TABLE gallus_gallus (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO gallus_gallus
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_galga;
CREATE INDEX galga_c ON gallus_gallus(clust_id);
CREATE INDEX galga_s ON gallus_gallus(species);

CREATE TABLE gasterosteus_aculeatus (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO gasterosteus_aculeatus
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_gasac;
CREATE INDEX gasac_c ON gasterosteus_aculeatus(clust_id);
CREATE INDEX gasac_s ON gasterosteus_aculeatus(species);

CREATE TABLE kluyveromyces_lactis (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO kluyveromyces_lactis
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_klula;
CREATE INDEX klula_c ON kluyveromyces_lactis(clust_id);
CREATE INDEX klula_s ON kluyveromyces_lactis(species);

CREATE TABLE macaca_mulatta (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO macaca_mulatta
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_macmu;
CREATE INDEX macmu_c ON macaca_mulatta(clust_id);
CREATE INDEX macmu_s ON macaca_mulatta(species);

CREATE TABLE monodelphis_domestica (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO monodelphis_domestica
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_mondo;
CREATE INDEX mondo_c ON monodelphis_domestica(clust_id);
CREATE INDEX mondo_s ON monodelphis_domestica(species);

CREATE TABLE mus_musculus (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO mus_musculus
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status  
 FROM inp.musmu_drome;
CREATE INDEX musmu_c ON mus_musculus(clust_id);
CREATE INDEX musmu_s ON mus_musculus(species);

CREATE TABLE oryza_sativa (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO oryza_sativa
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_orysa;
CREATE INDEX orysa_c ON oryza_sativa(clust_id);
CREATE INDEX orysa_s ON oryza_sativa(species);

CREATE TABLE pan_troglodytes (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO pan_troglodytes
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_pantr;
CREATE INDEX pantr_c ON pan_troglodytes(clust_id);
CREATE INDEX pantr_s ON pan_troglodytes(species);

CREATE TABLE rattus_norvegicus (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO rattus_norvegicus
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status  
 FROM inp.ratno_drome;
CREATE INDEX ratno_c ON rattus_norvegicus(clust_id);
CREATE INDEX ratno_s ON rattus_norvegicus(species);

CREATE TABLE saccharomyces_cerevisiae (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO saccharomyces_cerevisiae
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_sacce;
CREATE INDEX sacce_c ON saccharomyces_cerevisiae(clust_id);
CREATE INDEX sacce_s ON saccharomyces_cerevisiae(species);

CREATE TABLE schizosaccharomyces_pombe (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO schizosaccharomyces_pombe
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_schpo;
CREATE INDEX schpo_c ON schizosaccharomyces_pombe(clust_id);
CREATE INDEX schpo_s ON schizosaccharomyces_pombe(species);

CREATE TABLE takifugu_rubripes (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO takifugu_rubripes
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_fugru;
CREATE INDEX fugru_c ON takifugu_rubripes(clust_id);
CREATE INDEX fugru_s ON takifugu_rubripes(species);

CREATE TABLE tetraodon_nigroviridis (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO tetraodon_nigroviridis
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_tetni;
CREATE INDEX tetni_c ON tetraodon_nigroviridis(clust_id);
CREATE INDEX tetni_s ON tetraodon_nigroviridis(species);

CREATE TABLE xenopus_tropicalis (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO xenopus_tropicalis
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_xentr;
CREATE INDEX xentr_c ON xenopus_tropicalis(clust_id);
CREATE INDEX xentr_s ON xenopus_tropicalis(species);

CREATE TABLE yarrowia_lipolytica (
 inp_id VARCHAR(30) UNIQUE NOT NULL,	--Inparanoid ID
 clust_id INTEGER NOT NULL,		--Inparanoid Cluster ID
 species CHAR(5) NOT NULL,		--Inparanoid Species ID
 score VARCHAR(6) NOT NULL,		--Inparanoid Score
 seed_status CHAR(4)			--Inparanoid Seed Status
);
INSERT INTO yarrowia_lipolytica
 SELECT ID,clust_id, 
 ltrim(ltrim(ltrim(ltrim(ltrim(ltrim(rtrim(species,".fa"),"ens"),"mod"),"fly"),"san"),"ncbi"),"gra"),
 score,seed_status   
 FROM inp.drome_yarli;
CREATE INDEX yarli_c ON yarrowia_lipolytica(clust_id);
CREATE INDEX yarli_s ON yarrowia_lipolytica(species);



CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

INSERT INTO metadata
 SELECT * FROM inp.metadata
 WHERE name LIKE "INP%";


--putting the package name in explicitely for now. 
--But this should be made more generic later.

INSERT INTO metadata (name, value)
 VALUES ('PKGNAME', 'hom.Dm.inp');

INSERT INTO metadata
 SELECT 'DBSCHEMA', db_schema
 FROM meta.metadata
 WHERE package_name IN
        (SELECT value FROM metadata WHERE name='PKGNAME');

INSERT INTO metadata
 SELECT 'ORGANISM', organism
 FROM meta.metadata
 WHERE package_name IN
        (SELECT value FROM metadata WHERE name='PKGNAME');

INSERT INTO metadata
 SELECT 'SPECIES', species
 FROM meta.metadata
 WHERE package_name IN
        (SELECT value FROM metadata WHERE name='PKGNAME');

DELETE FROM metadata WHERE name='PKGNAME';




CREATE TABLE map_metadata (
  map_name VARCHAR(80) NOT NULL,
  source_name VARCHAR(80) NOT NULL,
  source_url VARCHAR(255) NOT NULL,
  source_date VARCHAR(20) NOT NULL
);

INSERT INTO map_metadata
 SELECT 'AEDAE', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ANOGA', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'APIME', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ARATH', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'BOSTA', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CAEBR', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CAEEL', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CAERE', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CANGL', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CANFA', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CIOIN', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CRYNE', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'DANRE', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'DEBHA', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'DICDI', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

-- INSERT INTO map_metadata
--  SELECT 'DROME', m1.value, m2.value, m3.value
--  FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
--  WHERE m1.name='INPSOURCENAME' AND
--        m2.name='INPSOURCEURL' AND
--        m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'DROPS', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ENTHI', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ESCCO', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'GALGA', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'GASAC', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'HOMSA', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'KLULA', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'MACMU', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'MONDO', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'MUSMU', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ORYSA', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PANTR', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'RATNO', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'SACCE', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'SCHPO', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'FUGRU', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';
 
INSERT INTO map_metadata
 SELECT 'TETNI', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';
 
INSERT INTO map_metadata
 SELECT 'XENTR', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';
 
INSERT INTO map_metadata
 SELECT 'YARLI', m1.value, m2.value, m3.value
 FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
 WHERE m1.name='INPSOURCENAME' AND
       m2.name='INPSOURCEURL' AND
       m3.name='INPSOURCEDATE';


CREATE TABLE map_counts (
  map_name VARCHAR(80) PRIMARY KEY,
  count INTEGER NOT NULL
);


INSERT INTO map_counts
 SELECT 'AEDAE', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM aedes_aegypti where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM aedes_aegypti where seed_status LIKE "100%" AND species LIKE "%AEDAE%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'ANOGA', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM anopheles_gambiae where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM anopheles_gambiae where seed_status LIKE "100%" AND species LIKE "%ANOGA%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'APIME', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM apis_mellifera where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM apis_mellifera where seed_status LIKE "100%" AND species LIKE "%APIME%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'ARATH', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM arabidopsis_thaliana where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM arabidopsis_thaliana where seed_status LIKE "100%" AND species LIKE "%ARATH%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'BOSTA', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM bos_taurus where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM bos_taurus where seed_status LIKE "100%" AND species LIKE "%BOSTA%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'CAEBR', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM caenorhabditis_briggsae where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM caenorhabditis_briggsae where seed_status LIKE "100%" AND species LIKE "%CAEBR%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'CAEEL', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM caenorhabditis_elegans where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM caenorhabditis_elegans where seed_status LIKE "100%" AND species LIKE "%CAEEL%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'CAERE', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM caenorhabditis_remanei where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM caenorhabditis_remanei where seed_status LIKE "100%" AND species LIKE "%CAERE%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'CANGL', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM candida_glabrata where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM candida_glabrata where seed_status LIKE "100%" AND species LIKE "%CANGL%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'CANFA', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM canis_familiaris where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM canis_familiaris where seed_status LIKE "100%" AND species LIKE "%CANFA%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'CIOIN', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM ciona_intestinalis where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM ciona_intestinalis where seed_status LIKE "100%" AND species LIKE "%CIOIN%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'CRYNE', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM cryptococcus_neoformans where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM cryptococcus_neoformans where seed_status LIKE "100%" AND species LIKE "%CRYNE%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'DANRE', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM danio_rerio where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM danio_rerio where seed_status LIKE "100%" AND species LIKE "%DANRE%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'DEBHA', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM debaryomyces_hanseneii where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM debaryomyces_hanseneii where seed_status LIKE "100%" AND species LIKE "%DEBHA%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'DICDI', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM dictyostelium_discoideum where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM dictyostelium_discoideum where seed_status LIKE "100%" AND species LIKE "%DICDI%") as two 
 WHERE one.clust_id = two.clust_id;


-- INSERT INTO map_counts
--  SELECT 'DROME', COUNT(DISTINCT one.inp_id) FROM 
--  (SELECT * FROM drosophila_melanogaster where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
--  (SELECT * FROM drosophila_melanogaster where seed_status LIKE "100%" AND species LIKE "%DROME%") as two 
--  WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'DROPS', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM drosophila_pseudoobscura where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM drosophila_pseudoobscura where seed_status LIKE "100%" AND species LIKE "%DROPS%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'ENTHI', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM entamoeba_histolytica where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM entamoeba_histolytica where seed_status LIKE "100%" AND species LIKE "%ENTHI%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'ESCCO', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM escherichia_coliK12 where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM escherichia_coliK12 where seed_status LIKE "100%" AND species LIKE "%ESCCO%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'GALGA', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM gallus_gallus where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM gallus_gallus where seed_status LIKE "100%" AND species LIKE "%GALGA%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'GASAC', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM gasterosteus_aculeatus where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM gasterosteus_aculeatus where seed_status LIKE "100%" AND species LIKE "%GASAC%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'HOMSA', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM homo_sapiens where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM homo_sapiens where seed_status LIKE "100%" AND species LIKE "%HOMSA%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'KLULA', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM kluyveromyces_lactis where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM kluyveromyces_lactis where seed_status LIKE "100%" AND species LIKE "%KLULA%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'MACMU', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM macaca_mulatta where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM macaca_mulatta where seed_status LIKE "100%" AND species LIKE "%MACMU%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'MONDO', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM monodelphis_domestica where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM monodelphis_domestica where seed_status LIKE "100%" AND species LIKE "%MONDO%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'MUSMU', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM mus_musculus where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM mus_musculus where seed_status LIKE "100%" AND species LIKE "%MUSMU%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'ORYSA', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM oryza_sativa where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM oryza_sativa where seed_status LIKE "100%" AND species LIKE "%ORYSA%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'PANTR', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM pan_troglodytes where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM pan_troglodytes where seed_status LIKE "100%" AND species LIKE "%PANTR%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'RATNO', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM rattus_norvegicus where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM rattus_norvegicus where seed_status LIKE "100%" AND species LIKE "%RATNO%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'SACCE', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM saccharomyces_cerevisiae where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM saccharomyces_cerevisiae where seed_status LIKE "100%" AND species LIKE "%SACCE%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'SCHPO', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM schizosaccharomyces_pombe where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM schizosaccharomyces_pombe where seed_status LIKE "100%" AND species LIKE "%SCHPO%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'FUGRU', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM takifugu_rubripes where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM takifugu_rubripes where seed_status LIKE "100%" AND species LIKE "%FUGRU%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'TETNI', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM tetraodon_nigroviridis where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM tetraodon_nigroviridis where seed_status LIKE "100%" AND species LIKE "%TETNI%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'XENTR', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM xenopus_tropicalis where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM xenopus_tropicalis where seed_status LIKE "100%" AND species LIKE "%XENTR%") as two 
 WHERE one.clust_id = two.clust_id;


INSERT INTO map_counts
 SELECT 'YARLI', COUNT(DISTINCT one.inp_id) FROM 
 (SELECT * FROM yarrowia_lipolytica where seed_status LIKE "100%" AND species LIKE "%DROME%") as one INNER JOIN 
 (SELECT * FROM yarrowia_lipolytica where seed_status LIKE "100%" AND species LIKE "%YARLI%") as two 
 WHERE one.clust_id = two.clust_id;




DETACH DATABASE inp;

ANALYZE;
