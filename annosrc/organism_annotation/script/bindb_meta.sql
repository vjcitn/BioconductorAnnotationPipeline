.echo ON

CREATE TABLE map_counts (
 map_name TEXT,
 count INTEGER,
 UNIQUE(map_name)
);

BEGIN TRANSACTION;

INSERT INTO map_counts
 SELECT 'ACCNUM', count(DISTINCT _id)
 FROM accessions;

INSERT INTO map_counts
 SELECT 'CHRLOC', count(DISTINCT _id)
 FROM chromosome_locations;

INSERT INTO map_counts
 SELECT 'CHR', count(DISTINCT _id)
 FROM chromosomes;

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

INSERT INTO map_counts
 SELECT 'MAP', count(DISTINCT _id)
 FROM cytogenetic_locations;

INSERT INTO map_counts
 SELECT 'PATH', count(DISTINCT _id)
 FROM kegg;

INSERT INTO map_counts
 SELECT 'PMID', count(DISTINCT _id)
 FROM pubmed;

INSERT INTO map_counts
 SELECT 'REFSEQ', count(DISTINCT _id)
 FROM refseq;

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

INSERT INTO map_counts
 SELECT 'PMID2GENE', count(DISTINCT pubmed_id)
 FROM pubmed;

INSERT INTO map_counts
 SELECT 'CHRLENGTHS', count(*)
 FROM chrlengths;

INSERT INTO map_counts
 SELECT 'ENTREZID', count(*)
 FROM genes;



INSERT INTO map_counts
 SELECT 'UNIPROT', count(DISTINCT _id)
 FROM uniprot;

INSERT INTO map_counts
 SELECT 'CHRLOCEND', count(DISTINCT _id)
 FROM chromosome_locations;


INSERT INTO map_counts
 SELECT 'TOTAL', count(*)
 FROM genes;

COMMIT TRANSACTION;

CREATE TABLE map_metadata (
 map_name TEXT,
 source_name TEXT,
 source_url TEXT,
 source_date TEXT
);

BEGIN TRANSACTION;

INSERT INTO map_metadata
 SELECT 'ACCNUM', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='EGSOURCENAME' AND
        m2.name='EGSOURCEURL' AND
        m3.name='EGSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CHRLOC', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='GPSOURCENAME' AND
        m2.name='GPSOURCEURL' AND
        m3.name='GPSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'CHR', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

INSERT INTO map_metadata
 SELECT 'ALIAS2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

-- INSERT INTO map_metadata
--  SELECT 'ALIAS2EG', source_name, source_url, source_date
--  FROM map_metadata
--  WHERE map_name='ACCNUM';

INSERT INTO map_metadata
 SELECT 'ENZYME', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='KEGGSOURCENAME' AND
        m2.name='KEGGSOURCEURL' AND
        m3.name='KEGGSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'GENENAME', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

INSERT INTO map_metadata
 SELECT 'GO', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='GOSOURCENAME' AND
        m2.name='GOSOURCEURL' AND
        m3.name='GOSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'MAP', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

--former place of OMIM insertion (moved to make it human specific)

INSERT INTO map_metadata
 SELECT 'PATH', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENZYME';

INSERT INTO map_metadata
 SELECT 'PMID', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

INSERT INTO map_metadata
 SELECT 'REFSEQ', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

INSERT INTO map_metadata
 SELECT 'SYNONYM2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

INSERT INTO map_metadata
 SELECT 'SYMBOL', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

-- INSERT INTO map_metadata
--  SELECT 'UNIGENE', source_name, source_url, source_date
--  FROM map_metadata
--  WHERE map_name='ACCNUM';

INSERT INTO map_metadata
 SELECT 'ENZYME2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENZYME';

INSERT INTO map_metadata
 SELECT 'GO2GENE', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='GOEGSOURCENAME' AND
        m2.name='GOEGSOURCEURL' AND
        m3.name='GOEGSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'GO2ALLGENES', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name IN ('GO', 'GO2GENE');

--INSERT INTO map_metadata
-- SELECT 'GO2EG', source_name, source_url, source_date
-- FROM map_metadata
-- WHERE map_name IN ('GO', 'ACCNUM');

INSERT INTO map_metadata
 SELECT 'PATH2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENZYME';

INSERT INTO map_metadata
 SELECT 'PFAM', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='IPISOURCENAME' AND
        m2.name='IPISOURCEURL' AND
        m3.name='IPISOURCEDATE';

INSERT INTO map_metadata
 SELECT 'PROSITE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='PFAM';

INSERT INTO map_metadata
 SELECT 'PMID2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

INSERT INTO map_metadata
 SELECT 'ENTREZID', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';


--ENSEMBL has two kinds of map_metadata
INSERT INTO map_metadata
 SELECT 'ENSEMBL', m1.value, m2.value, m3.value
 FROM metadata AS m1, metadata AS m2, metadata AS m3
 WHERE m1.name='ENSOURCENAME' AND
        m2.name='ENSOURCEURL' AND
        m3.name='ENSOURCEDATE';

INSERT INTO map_metadata
 SELECT 'ENSEMBL2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ENSEMBL';


INSERT INTO map_metadata
 SELECT 'ENSEMBL', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

INSERT INTO map_metadata
 SELECT 'ENSEMBL2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';






INSERT INTO map_metadata
 SELECT 'CHRLOCEND', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='CHRLOC';

INSERT INTO map_metadata
 SELECT 'UNIPROT', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';




COMMIT TRANSACTION;

ANALYZE;
