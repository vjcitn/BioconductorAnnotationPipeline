.echo ON

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

--from the symbol table, we want to make BOTH the genes AND the gene_info table (gene_id is going to be the unique ID)

ATTACH DATABASE 'plasmoDBSrc.sqlite' AS plasmoSrc;

INSERT INTO metadata
 SELECT * FROM plasmoSrc.metadata;

INSERT INTO metadata (name,value) VALUES ('CENTRALID','ORF');
INSERT INTO metadata (name,value) VALUES ('TAXID','36329');

CREATE TABLE genes (
 _id INTEGER PRIMARY KEY,
 gene_id TEXT
);

INSERT INTO genes (gene_id)
 SELECT DISTINCT gene_id
 FROM symbol
 ORDER BY gene_id;

CREATE INDEX c1 ON genes(gene_id);



CREATE TABLE gene_info (
 _id INTEGER REFERENCES genes(_id),
 gene_name TEXT,
 symbol TEXT
);

--Gene Info table is slightly simplified.. (no descriptions were parsed, so we are leaving them out for now)
INSERT INTO gene_info
 SELECT g._id as _id, 
 	CASE WHEN i.description='-' THEN NULL ELSE i.description END,
	CASE WHEN i.gene_id='-' THEN NULL ELSE i.gene_id END
 FROM genes as g, plasmoSrc.symbol as i
 WHERE i.gene_id=g.gene_id
 ORDER BY _id;

DELETE FROM gene_info WHERE gene_name IS NULL AND symbol IS NULL;

CREATE INDEX c4 ON gene_info(_id);


--for the go tables (all 6 of em) we will have to sort out what stuff we need from gosrc.sqlite and the tables we have inplasmoDB.sqlite.  this will probably look more like it does in yeast or tair than it does down below...

-- in general: we get the _id from the genes table (central table) and add on the go IDs and evidence codes that go with from the go table, THEN for the "all" we use GO and the offspring tables to flesh out all possible children for each term.


CREATE TABLE go_bp (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_bp
 SELECT g._id, i.go_id, i.evidence_code
 FROM genes as g, plasmoSrc.go as i
 WHERE i.gene_id=g.gene_id AND i.ontology='Biological Process';

CREATE INDEX go1 ON go_bp(_id);
CREATE INDEX go4 ON go_bp(go_id);

CREATE TABLE go_mf (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_mf
 SELECT g._id, i.go_id, i.evidence_code
 FROM genes as g, plasmoSrc.go as i
 WHERE i.gene_id=g.gene_id AND i.ontology='Molecular Function';

CREATE INDEX go2 ON go_mf(_id);
CREATE INDEX go5 ON go_mf(go_id);

CREATE TABLE go_cc (
 _id INTEGER REFERENCES genes(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_cc
 SELECT g._id, i.go_id, i.evidence_code
 FROM genes as g, plasmoSrc.go as i
 WHERE i.gene_id=g.gene_id AND i.ontology='Cellular Component';

CREATE INDEX go3 ON go_cc(_id);
CREATE INDEX go6 ON go_cc(go_id);


-- then do the go_XX_ALL tables

ATTACH DATABASE 'gosrc.sqlite' AS gosrc;

INSERT INTO metadata
 SELECT * from gosrc.metadata;

CREATE TABLE go_bp_all (
 _id INTEGER REFERENCES sgd(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_bp_all
 SELECT g._id, t.go_id, g.evidence
 FROM gosrc.go_bp_offspring as t,
        go_bp as g
 WHERE g.go_id=t.offspring_go_id;

INSERT INTO go_bp_all
 SELECT _id, go_id, evidence
 FROM go_bp;

CREATE INDEX goa1 on go_bp_all(_id);


CREATE TABLE go_mf_all (
 _id INTEGER REFERENCES sgd(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_mf_all
 SELECT g._id, t.go_id, g.evidence
 FROM gosrc.go_mf_offspring as t,
        go_mf as g
 WHERE g.go_id=t.offspring_go_id;

INSERT INTO go_mf_all
 SELECT _id, go_id, evidence
 FROM go_mf;

CREATE INDEX goa2 on go_mf_all(_id);

CREATE TABLE go_cc_all (
 _id INTEGER REFERENCES sgd(_id),
 go_id TEXT,
 evidence TEXT
);

INSERT INTO go_cc_all
 SELECT g._id, t.go_id, g.evidence
 FROM gosrc.go_cc_offspring as t,
        go_cc as g
 WHERE g.go_id=t.offspring_go_id;

INSERT INTO go_cc_all
 SELECT _id, go_id, evidence
 FROM go_cc;

CREATE INDEX goa3 on go_cc_all(_id);

DETACH DATABASE gosrc;





--put in a gene_synonyms table (later to become alias)
--Do this like we did alias, but this time instead of EGs we are using those gene_id

CREATE TEMP TABLE gene_synonyms_orgi (
 _id INTEGER REFERENCES genes(_id),
 symbol TEXT
);

INSERT INTO gene_synonyms_orgi
 SELECT g._id, i.alias 
 FROM genes as g CROSS JOIN plasmoSrc.alias as i
 WHERE i.gene_id=g.gene_id AND alias != "-";

INSERT INTO gene_synonyms_orgi
 SELECT _id, symbol
 FROM gene_info; 

CREATE TABLE gene_synonyms (
 _id INTEGER REFERENCES genes(_id),
 symbol TEXT
);

INSERT INTO gene_synonyms
 SELECT DISTINCT _id, symbol
 FROM gene_synonyms_orgi;

DROP TABLE gene_synonyms_orgi;
VACUUM;
CREATE INDEX c22 ON gene_synonyms(_id);











-- attach stuff for and insert into kegg tables.
-- do this one by 1st getting the data hooked in from KEGG (update the KEGG scripts so that this shows up in keggsrc.sqlite)
-- THEN, I need to attach the kegg data in a gene_id (instead of EG) centric way

ATTACH DATABASE 'keggsrc.sqlite' as kegg;

INSERT INTO metadata
 SELECT * FROM kegg.metadata WHERE name LIKE "KEGGSOURCE%";

CREATE TABLE kegg (
 _id INTEGER REFERENCES genes(_id),
 path_id TEXT
);

-- original insert was like this:
-- INSERT INTO kegg
--  SELECT DISTINCT g._id as _id, substr(k.pathway_id, -5, 5)
--  FROM genes as g, kegg.pathway2gene as k 
--  WHERE g.gene_id=k.gene_or_orf_id
--  ORDER BY _id;


-- NOW: make temp table keggt and populate with something sensible
CREATE TEMP TABLE keggt (
 gene_id TEXT,
 pathway_id TEXT
);

INSERT INTO keggt
 SELECT DISTINCT a.gene_id as gene_id, substr(k.pathway_id, -5, 5) as pathway_id
 FROM plasmoSrc.alias as a, kegg.pathway2gene as k 
 WHERE a.alias=k.gene_or_orf_id;

CREATE INDEX c17Temp ON keggt(gene_id);

-- Then do real insert
INSERT INTO kegg
 SELECT DISTINCT g._id as _id, kt.pathway_id
 FROM genes as g, keggt as kt 
 WHERE g.gene_id=kt.gene_id
 ORDER BY _id;

CREATE INDEX c17 ON kegg(_id);




--------------------------------
-- next verse, same as the 1st

CREATE TABLE ec (
 _id INTEGER REFERENCES genes(_id),
 ec_number TEXT
);

-- this was the original
-- INSERT INTO ec
--  SELECT DISTINCT g._id as _id, e.ec_id
--  FROM genes as g, kegg.pfa_ec as e
--  WHERE g.gene_id=e.gene_or_orf_id
--  ORDER BY _id;

-- now make a temp table
CREATE TEMP TABLE ect (
 gene_id TEXT,
 ec_id TEXT
);

INSERT INTO ect
 SELECT DISTINCT a.gene_id as gene_id, e.ec_id 
 FROM plasmoSrc.alias as a, kegg.pfa_ec as e
 WHERE a.alias=e.gene_or_orf_id;

CREATE INDEX c18Temp ON ect(gene_id);

-- Then do real insert
INSERT INTO ec
 SELECT DISTINCT g._id as _id, ect.ec_id
 FROM genes as g, ect
 WHERE g.gene_id=ect.gene_id
 ORDER BY _id;

CREATE INDEX c18 ON ec(_id);

DETACH DATABASE kegg;




-- map metadata:

CREATE TABLE map_metadata (
 map_name TEXT,
 source_name TEXT,
 source_url TEXT,
 source_date TEXT
);

INSERT INTO map_metadata
 SELECT 'GENENAME', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PLASMOSOURCENAME' AND
        m2.name='PLASMOSOURCEURL' AND
        m3.name='PLASMOSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'SYMBOL', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='GENENAME';

INSERT INTO map_metadata
 SELECT 'ENZYME', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='KEGGSOURCENAME' AND
        m2.name='KEGGSOURCEURL' AND
        m3.name='KEGGSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PATH', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENZYME';

INSERT INTO map_metadata
 SELECT 'GO', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='GOSOURCENAME' AND
        m2.name='GOSOURCEURL' AND
        m3.name='GOSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'GO2GENE', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='PLASMOSOURCENAME' AND
        m2.name='PLASMOSOURCEURL' AND
        m3.name='PLASMOSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'GO2ALLGENES', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name IN ('GO', 'GO2GENE');

INSERT INTO map_metadata
 SELECT 'ALIAS2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='GENENAME';







CREATE TABLE map_counts (
 map_name TEXT,
 count INTEGER,
 UNIQUE(map_name)
);

BEGIN TRANSACTION;

-- INSERT INTO map_counts
--  SELECT 'ACCNUM', count(DISTINCT _id)
--  FROM accessions;

-- INSERT INTO map_counts
--  SELECT 'CHRLOC', count(DISTINCT _id)
--  FROM chromosome_locations;

-- INSERT INTO map_counts
--  SELECT 'CHR', count(DISTINCT _id)
--  FROM chromosomes;

INSERT INTO map_counts
 SELECT 'ENZYME', count(DISTINCT _id)
 FROM ec;

INSERT INTO map_counts
 SELECT 'GENENAME', count(DISTINCT _id)
 FROM gene_info;

INSERT INTO map_counts
 SELECT 'SYNONYM2GENE', count(DISTINCT symbol)
 FROM gene_synonyms;


INSERT INTO map_counts
 SELECT 'GO', count(DISTINCT _id)
 FROM ( 
        SELECT _id FROM go_bp UNION
        SELECT _id FROM go_mf UNION
        SELECT _id FROM go_cc
 );

-- INSERT INTO map_counts
--  SELECT 'MAP', count(DISTINCT _id)
--  FROM cytogenetic_locations;

INSERT INTO map_counts
 SELECT 'PATH', count(DISTINCT _id)
 FROM kegg;

-- INSERT INTO map_counts
--  SELECT 'PMID', count(DISTINCT _id)
--  FROM pubmed;

-- INSERT INTO map_counts
--  SELECT 'REFSEQ', count(DISTINCT _id)
--  FROM refseq;

INSERT INTO map_counts
 SELECT 'SYMBOL', count(DISTINCT _id)
 FROM gene_info;

-- INSERT INTO map_counts
--  SELECT 'UNIGENE', count(DISTINCT _id)
--  FROM unigene;

INSERT INTO map_counts
 SELECT 'ENZYME2GENE', count(DISTINCT ec_number)
 FROM ec;

INSERT INTO map_counts
 SELECT 'GO2ALLGENES', count(go_id)
 FROM (SELECT DISTINCT go_id FROM go_bp_all UNION
        SELECT DISTINCT go_id FROM go_mf_all UNION
        SELECT DISTINCT go_id FROM go_cc_all);

INSERT INTO map_counts
 SELECT 'GO2GENE', count(go_id)
 FROM (SELECT DISTINCT go_id FROM go_bp UNION
        SELECT DISTINCT go_id FROM go_mf UNION
        SELECT DISTINCT go_id FROM go_cc);

INSERT INTO map_counts
 SELECT 'PATH2GENE', count(DISTINCT path_id)
 FROM kegg;

-- INSERT INTO map_counts
--  SELECT 'PFAM', count(DISTINCT _id)
--  FROM pfam;

-- INSERT INTO map_counts
--  SELECT 'PROSITE', count(DISTINCT _id)
--  FROM prosite;

-- INSERT INTO map_counts
--  SELECT 'PMID2GENE', count(DISTINCT pubmed_id)
--  FROM pubmed;

-- INSERT INTO map_counts
--  SELECT 'CHRLENGTHS', count(*)
--  FROM chrlengths;


INSERT INTO map_counts
 SELECT 'ENTREZID', count(*)
 FROM genes;

INSERT INTO map_counts
 SELECT 'TOTAL', count(*)
 FROM genes;

COMMIT TRANSACTION;

