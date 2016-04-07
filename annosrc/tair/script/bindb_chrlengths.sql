-- call by doing this :
-- sqlite3 -bail ag.sqlite < CHRLENGTHS.sql 

-- DROP TABLE chrlengths;
CREATE TABLE chrlengths (
      chromosome VARCHAR(2) PRIMARY KEY,                   -- chromosome name
      length INTEGER NOT NULL
);

INSERT INTO chrlengths (chromosome,length) VALUES ('1',30432563);
INSERT INTO chrlengths (chromosome,length) VALUES ('2',19705359);
INSERT INTO chrlengths (chromosome,length) VALUES ('3',23470805);
INSERT INTO chrlengths (chromosome,length) VALUES ('4',18585042);
INSERT INTO chrlengths (chromosome,length) VALUES ('5',26992728);
INSERT INTO chrlengths (chromosome,length) VALUES ('C',154478);
INSERT INTO chrlengths (chromosome,length) VALUES ('M',366924);

INSERT INTO map_counts (map_name,count) VALUES ('CHRLENGTHS',7);