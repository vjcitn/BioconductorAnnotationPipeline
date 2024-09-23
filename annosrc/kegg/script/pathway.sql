.echo ON
--.mode tabs

-- Metadata tables.
CREATE TABLE metadata (
  name VARCHAR(80) PRIMARY KEY,
  value VARCHAR(255)
);

.mode tabs
CREATE TABLE pathway2name (
  path_id CHAR(5) NOT NULL UNIQUE,              -- KEGG pathway short ID
  path_name VARCHAR(100) NOT NULL UNIQUE         -- KEGG pathway name
) ;
.import map_title.tab pathway2name

