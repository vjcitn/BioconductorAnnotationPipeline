.echo ON
.mode tabs

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);

CREATE TABLE chrlength (
       chr TEXT PRIMARY KEY,
       length INTEGER,
       path TEXT
);
.import chromInfo.txt chrlength