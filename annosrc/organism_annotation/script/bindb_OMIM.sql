.echo ON

INSERT INTO map_counts
 SELECT 'OMIM', count(DISTINCT _id)
 FROM omim;

INSERT INTO map_metadata
 SELECT 'OMIM', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

