.echo ON

CREATE TABLE AbstractModifiedResidue (
 DB_ID INTEGER PRIMARY KEY,
 referenceSequence TEXT NOT NULL,
 referenceSequence_class TEXT NOT NULL
);

CREATE TABLE Affiliation (
  DB_ID INTEGER PRIMARY KEY,
  address TEXT NOT NULL
);

CREATE TABLE Affiliation_2_name (
  DB_ID INTEGER,
  name_rank INTEGER,
  name TEXT
);

CREATE TABLE BlackBoxEvent (
  DB_ID INTEGER PRIMARY KEY,
  templateEvent INTEGER,
  templateEvent_class TEXT
);

-- CREATE TABLE `BlackBoxEvent_2_hasEvent` (
--   `DB_ID` int(10) unsigned default NULL,
--   `hasEvent_rank` int(10) unsigned default NULL,
--   `hasEvent` int(10) unsigned default NULL,
--   `hasEvent_class` varchar(64) default NULL,
--   KEY `DB_ID` (`DB_ID`),
--   KEY `hasEvent` (`hasEvent`)
-- )

-- CREATE TABLE `Book` (
--   `DB_ID` int(10) unsigned NOT NULL,
--   `ISBN` text,
--   `chapterTitle` text,
--   `pages` text,
--   `publisher` int(10) unsigned default NULL,
--   `publisher_class` varchar(64) default NULL,
--   `year` int(10) default NULL,
--   PRIMARY KEY  (`DB_ID`),
--   KEY `publisher` (`publisher`),
--   KEY `year` (`year`),
--   FULLTEXT KEY `ISBN` (`ISBN`),
--   FULLTEXT KEY `chapterTitle` (`chapterTitle`),
--   FULLTEXT KEY `pages` (`pages`)
-- )

-- CREATE TABLE `Book_2_chapterAuthors` (
--   `DB_ID` int(10) unsigned default NULL,
--   `chapterAuthors_rank` int(10) unsigned default NULL,
--   `chapterAuthors` int(10) unsigned default NULL,
--   `chapterAuthors_class` varchar(64) default NULL,
--   KEY `DB_ID` (`DB_ID`),
--   KEY `chapterAuthors` (`chapterAuthors`)
-- )

-- DROP TABLE IF EXISTS `CandidateSet`;
-- SET @saved_cs_client     = @@character_set_client;
-- SET character_set_client = utf8;
-- CREATE TABLE `CandidateSet` (
--   `DB_ID` int(10) unsigned NOT NULL,
--   PRIMARY KEY  (`DB_ID`)
-- ) 

-- CREATE TABLE `CandidateSet_2_hasCandidate` (
--   `DB_ID` int(10) unsigned default NULL,
--   `hasCandidate_rank` int(10) unsigned default NULL,
--   `hasCandidate` int(10) unsigned default NULL,
--   `hasCandidate_class` varchar(64) default NULL,
--   KEY `DB_ID` (`DB_ID`),
--   KEY `hasCandidate` (`hasCandidate`)
-- )

-- CREATE TABLE `CatalystActivity` (
--   `DB_ID` int(10) unsigned NOT NULL,
--   `activity` int(10) unsigned default NULL,
--   `activity_class` varchar(64) default NULL,
--   `physicalEntity` int(10) unsigned default NULL,
--   `physicalEntity_class` varchar(64) default NULL,
--   PRIMARY KEY  (`DB_ID`),
--   KEY `activity` (`activity`),
--   KEY `physicalEntity` (`physicalEntity`)
-- ) 






-- .echo ON
-- CREATE TABLE metadata (
--  name TEXT,
--  value TEXT
-- );

-- CREATE TABLE current_release (
--   id TEXT,
--   org_name TEXT,
--   version TEXT,
--   protein_entry_count INTEGER,
--   protein_xref_count INTEGER,
--   protein_count INTEGER,
--   gene_entry_count INTEGER,
--   gene_xref_count INTEGER,
--   gene_count INTEGER
-- );

-- -- CREATE TABLE release (
-- --   id TEXT,
-- --   org_name TEXT,
-- --   version TEXT,
-- --   protein_entry_count INTEGER,
-- --   protein_xref_count INTEGER,
-- --   protein_count INTEGER,
-- --   gene_entry_count INTEGER,
-- --   gene_xref_count INTEGER,
-- --   gene_count INTEGER
-- -- );


-- CREATE TABLE data_source (
--   id INTEGER PRIMARY KEY,
--   code TEXT,
--   name TEXT,
--   data_type TEXT
-- );
-- CREATE INDEX ds1 ON data_source(id);

-- CREATE TABLE gene (
--   id INTEGER PRIMARY KEY,
--   chromosome TEXT
-- );

-- CREATE TABLE gene_entry (
--   id TEXT,
--   primary_id TEXT,
--   secondary_id TEXT,
--   data_source_id INTEGER,
--   gene_id INTEGER NOT NULL
-- );
-- CREATE INDEX ge1 ON gene_entry(data_source_id);
-- CREATE INDEX ge2 ON gene_entry(gene_id);

-- CREATE TABLE gene_xref (
--   primary_id TEXT,
--   secondary_id TEXT,
--   data_source_id INTEGER,
--   gene_id INTEGER NOT NULL
-- );

-- CREATE TABLE interpro_match (
--   protein_id TEXT,
--   entry_ac TEXT,
--   method_ac TEXT,
--   from_pos INTEGER,
--   to_pos INTEGER
-- );
-- CREATE INDEX im1 ON interpro_match(protein_id);

-- CREATE TABLE protein (
--   id TEXT,
--   version INTEGER,
--   release_id TEXT,
--   master_id TEXT,
--   description TEXT,
--   uniparc_id TEXT
-- );

-- CREATE TABLE protein2gene (
--   protein_id TEXT,
--   gene_id INTEGER
-- );
-- CREATE INDEX pg1 ON protein2gene(gene_id, protein_id);

-- CREATE TABLE protein_entry (
--   id INTEGER,
--   primary_id TEXT,
--   secondary_id TEXT,
--   data_source_id INTEGER,
--   protein_id TEXT
-- );


-- CREATE TABLE protein_xref (
--   primary_id TEXT,
--   secondary_id TEXT,
--   data_source_id INTEGER,
--   protein_id INTEGER
-- );

-- CREATE TABLE sequence (
--   id TEXT,
--   length INTEGER,
--   sequence text
-- );

-- CREATE TABLE data_source_release (
--   data_source_id INTEGER,
--   release_id TEXT,
--   details TEXT
-- );

-- CREATE TABLE organism (
--   name TEXT,
--   tax_id INTEGER,
--   org_sci_name TEXT,
--   uniprot_common_name TEXT,
--   uniprot_os_code TEXT
-- ) ;

-- CREATE TABLE uniparc (
--   id TEXT,
--   length INTEGER,
--   sequence text
-- );

