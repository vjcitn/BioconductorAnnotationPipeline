CREATE TABLE pathway2gene (
  DB_ID VARCHAR(10) NOT NULL,                  -- Reactome DB_ID
  gene_id VARCHAR(10) NOT NULL                  -- Entrez Gene
);

CREATE TABLE reactome2go(
  DB_ID VARCHAR(10) NOT NULL,
  go_id VARCHAR(10)
);

CREATE TABLE map_counts (
  map_name VARCHAR(80) PRIMARY KEY,
  count INTEGER NOT NULL
);

CREATE TABLE map_metadata (
  map_name VARCHAR(80) NOT NULL,
  source_name VARCHAR(80) NOT NULL,
  source_url VARCHAR(255) NOT NULL,
  source_date VARCHAR(20) NOT NULL
);

CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

CREATE TABLE pathway2name (
  DB_ID VARCHAR(10) NOT NULL,              -- Reactome DB_ID
  path_name VARCHAR(150) NOT NULL         -- Reactome pathway name
);

CREATE INDEX Ipathway2gene ON pathway2gene(gene_id);

.separator "\t"
.import pathway2gene.txt pathway2gene
.import reactome2go.txt reactome2go
.import pathway2name.txt pathway2name

--do something here to fill the map stuff
INSERT INTO metadata (name, value) VALUES ("DBSCHEMA", "REACTOME_DB");
INSERT INTO metadata (name, value) VALUES ("DBSCHEMAVERSION", "44");
INSERT INTO metadata (name, value) VALUES ("SOURCENAME", "Reactome");
INSERT INTO metadata (name, value) VALUES ("SOURCEURL", "http://www.reactome.org/download/current/");
INSERT INTO metadata (name, value) VALUES ("SOURCEDATE", date('now'));
INSERT INTO metadata (name, value) VALUES ("Supporting package","AnnotationDbi");
INSERT INTO metadata (name, value) VALUES ("Db type","ReactomeDb");

INSERT INTO map_metadata (map_name, source_name, source_url, source_date) VALUES ("REACTOMEID2GO", "Reactome", "http://www.reactome.org/download/current/sql_dn.gz", date('now'));
INSERT INTO map_metadata (map_name, source_name, source_url, source_date) VALUES ("GO2REACTOMEID", "Reactome", "http://www.reactome.org/download/current/sql_dn.gz", date('now'));
INSERT INTO map_metadata (map_name, source_name, source_url, source_date) VALUES ("EXTID2PATHID", "Reactome", "http://www.reactome.org/download/current/sql_dn.gz", date('now'));
INSERT INTO map_metadata (map_name, source_name, source_url, source_date) VALUES ("PATHID2EXTID", "Reactome", "http://www.reactome.org/download/current/sql_dn.gz", date('now'));
INSERT INTO map_metadata (map_name, source_name, source_url, source_date) VALUES ("PATHNAME2ID", "Reactome", "http://www.reactome.org/download/current/sql_dn.gz", date('now'));
INSERT INTO map_metadata (map_name, source_name, source_url, source_date) VALUES ("PATHID2NAME", "Reactome", "http://www.reactome.org/download/current/sql_dn.gz", date('now'));

INSERT INTO map_counts (map_name, count) VALUES ("REACTOMEID2GO", (SELECT COUNT(DISTINCT(DB_ID)) FROM reactome2go));
INSERT INTO map_counts (map_name, count) VALUES ("GO2REACTOMEID", (SELECT COUNT(DISTINCT(go_id)) FROM reactome2go));
INSERT INTO map_counts (map_name, count) VALUES ("EXTID2PATHID", (SELECT COUNT(DISTINCT(gene_id)) FROM pathway2gene));
INSERT INTO map_counts (map_name, count) VALUES ("PATHID2EXTID", (SELECT COUNT(DISTINCT(DB_ID)) FROM pathway2gene));
INSERT INTO map_counts (map_name, count) VALUES ("PATHNAME2ID", (SELECT COUNT(DISTINCT(path_name)) FROM pathway2name));
INSERT INTO map_counts (map_name, count) VALUES ("PATHID2NAME", (SELECT COUNT(DISTINCT(DB_ID)) FROM pathway2name));