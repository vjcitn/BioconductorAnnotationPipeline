.echo on

DROP TABLE cytogenetic_locations;

DELETE FROM map_counts where map_name = "MAP";

DELETE FROM map_metadata where map_name = "MAP";

INSERT INTO map_counts
 SELECT 'ZFIN', count(DISTINCT _id)
 FROM zfin;

INSERT INTO map_metadata
 SELECT 'ZFIN', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';