#!/bin/bash

# #First download the Reactome database in MySQL format.
# cd /tmp
# wget http://www.reactome.org/download/current/sql_dn.gz
# wget http://www.reactome.org/download/current/sql.gz
# gunzip sql_dn.gz
# gunzip sql.gz

# #put the newly downloaded data into the database
# #sudo -i
# cd /tmp
# mysql -u root -p reactome_dn < sql_dn
# mysql -u root -p reactome < sql

# #Dump the stuff we want to something sqlite can read
# rm /tmp/pathway2gene.txt /tmp/reactome2go.txt /tmp/pathway2name.txt
# cd /home/willem/openanalytics/rpackages
# mysql -u root -p < queries.sql

# sudo chown willem:willem /tmp/*.txt
# sed -ie 's/EntrezGene://' /tmp/pathway2gene.txt
# sed -ie 's/\t/: /2' /tmp/pathway2name.txt

# #Read into sqlite
# #Adapt sqlite.sql with new database version!
# rm /home/willem/openanalytics/rpackages/reactome.db/inst/extdata/reactome.sqlite
# sqlite3 /home/willem/openanalytics/rpackages/reactome.db/inst/extdata/reactome.sqlite < sqlite.sql

# rm reactome.sqlite
sqlite3 reactome.sqlite < sqlite.sql

#~ CREATE TABLE pathway2gene (
  #~ reactome_id CHAR(8) NOT NULL,                  -- Reactome DB_ID
  #~ gene_id VARCHAR(20) NOT NULL                  -- Entrez Gene
#~ );
#~ Query:
#~ SELECT p2e.DB_ID e2i.indirectIdentifier FROM reactome.Pathway_2_hasEvent AS p2e, reactome_dn.Event_2_indirectIdentifier AS e2i WHERE AND e2i.DB_ID = p2e.hasEvent AND e2i.indirectIdentifier LIKE "%Entrez%";

#~ CREATE TABLE reactome2go(
	#~ reactome_id TEXT,
	#~ go_id TEXT
#~ );
#~ Query:
#~ SELECT DB_ID, indirectIdentifier FROM reactome_dn.Event_2_indirectIdentifier WHERE indirectIdentifier LIKE "%go%";

#~ CREATE TABLE map_counts (
  #~ map_name VARCHAR(80) PRIMARY KEY,
  #~ count INTEGER NOT NULL
#~ );
#~ QUERY:
#~ Create from data

#~ CREATE TABLE map_metadata (
  #~ map_name VARCHAR(80) NOT NULL,
  #~ source_name VARCHAR(80) NOT NULL,
  #~ source_url VARCHAR(255) NOT NULL,
  #~ source_date VARCHAR(20) NOT NULL
#~ );
#~ QUERY:
#~ NA, just wirte yourself

#~ CREATE TABLE metadata (
  #~ name VARCHAR(80) PRIMARY KEY,
  #~ value VARCHAR(255)
#~ );
#~ QUERY:
#~ NA, just wirte yourself

#~ CREATE TABLE pathway2name (
  #~ reactome_id CHAR(5) NOT NULL UNIQUE,              -- Reactome DB_ID
  #~ path_name VARCHAR(100) NOT NULL UNIQUE         -- Reactome pathway name
#~ );
#~ QUERY:
#~ SELECT DB_ID, _displayName FROM DatabaseObject WHERE _class = "Pathway";

#~ CREATE INDEX Ipathway2gene ON pathway2gene(gene_id);
