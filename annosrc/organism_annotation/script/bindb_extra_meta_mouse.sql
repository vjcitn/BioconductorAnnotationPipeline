.echo ON

BEGIN TRANSACTION;

INSERT INTO map_metadata
 SELECT 'MGI', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

INSERT INTO map_metadata
 SELECT 'MGI2GENE', source_name, source_url, source_date
 FROM map_metadata
 WHERE map_name='ACCNUM';

COMMIT TRANSACTION;

ANALYZE;
