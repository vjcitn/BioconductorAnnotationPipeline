.echo ON

INSERT INTO map_counts
 SELECT 'UCSCKG', count(DISTINCT _id)
 FROM ucsc;

INSERT INTO map_metadata
 SELECT 'UCSCKG', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='CHRLOC';

ANALYZE;
