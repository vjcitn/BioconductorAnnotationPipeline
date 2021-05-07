.echo ON
.separator \t

CREATE TABLE genes (
       taxid INTEGER NOT NULL,
       gene_id INTEGER NOT NULL,
       other_taxid INTEGER NOT NULL,
       other_gene_id INTEGER NOT NULL
);

.import gene_orthologs genes

CREATE TABLE names (
       taxid INTEGER NOT NULL,
       name TEXT
);

.import names.txt names

DELETE FROM names WHERE taxid NOT IN (SELECT DISTINCT taxid FROM genes UNION SELECT DISTINCT other_taxid FROM genes);

 -- We're just gonna put in all the metadata table data here, rather than trying to use the existing infrastructure

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);

INSERT INTO metadata VALUES('Db type', 'OrthologyDb');
INSERT INTO metadata VALUES('Supporting package', 'AnnotationDbi');
INSERT INTO metadata VALUES('DBSCHEMA', 'ORTHOLOGY_DB');


ANALYZE;

