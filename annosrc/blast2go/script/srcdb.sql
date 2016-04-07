.echo ON
.separator \t

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);


--Here we just import the basics into tables.
CREATE TABLE Cf_refseq2go (
 rs_id VARCHAR(20) NOT NULL,
 go_id VARCHAR(20) NOT NULL
);
.import CfIDs_RS.tab Cf_refseq2go
CREATE INDEX CfRS ON Cf_refseq2go(rs_id);

CREATE TABLE Cf_genbank2go (
 gb_id VARCHAR(20) NOT NULL,
 go_id VARCHAR(20) NOT NULL
);
.import CfIDs_GB.tab Cf_genbank2go
CREATE INDEX CfGB ON Cf_genbank2go(gb_id);


CREATE TABLE Ssc_refseq2go (
 rs_id VARCHAR(20) NOT NULL,
 go_id VARCHAR(20) NOT NULL
);
.import SscIDs_RS.tab Ssc_refseq2go
CREATE INDEX SscRS ON Ssc_refseq2go(rs_id);

CREATE TABLE Ssc_genbank2go (
 gb_id VARCHAR(20) NOT NULL,
 go_id VARCHAR(20) NOT NULL
);
.import SscIDs_GB.tab Ssc_genbank2go
CREATE INDEX SscGB ON Ssc_genbank2go(gb_id);





ANALYZE;
