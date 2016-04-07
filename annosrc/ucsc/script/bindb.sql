.echo ON
ATTACH DATABASE "../human/gpsrc.sqlite" AS humansrc;

CREATE TABLE chrloc_human as
 SELECT gene_id, chrom, start, end FROM humansrc.chrloc;
CREATE INDEX h1 on chrloc_human(gene_id);

CREATE TABLE cytoBand_human AS
 SELECT chrom, chromStart, chromEnd, cytoBandName
 FROM humansrc.cytoBand;

CREATE TABLE chrlength_human AS
 SELECT chr, length
 FROM humansrc.chrlength;

CREATE TABLE ucsc_gene_human AS
 SELECT ucsc_id, gene_id
 FROM humansrc.ucsc_id;

CREATE TABLE metadata_human (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_human 
 SELECT * FROM humansrc.metadata;

DETACH DATABASE humansrc;


ATTACH DATABASE "../mouse/gpsrc.sqlite" AS mousesrc;

CREATE TABLE chrloc_mouse as
 SELECT gene_id, chrom, start, end FROM mousesrc.chrloc;
CREATE INDEX m1 on chrloc_mouse(gene_id);

CREATE TABLE cytoBand_mouse AS
 SELECT chrom, chromStart, chromEnd, cytoBandName
 FROM mousesrc.cytoBand;

CREATE TABLE chrlength_mouse AS
 SELECT chr, length
 FROM mousesrc.chrlength;

-- CREATE TABLE ucsc_gene_mouse AS
--  SELECT ucsc_id, gene_id
--  FROM mousesrc.ucsc_id;

CREATE TABLE metadata_mouse (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_mouse
 SELECT * FROM mousesrc.metadata;

DETACH DATABASE mousesrc;


ATTACH DATABASE "../rat/gpsrc.sqlite" AS ratsrc;

CREATE TABLE chrloc_rat as
 SELECT gene_id, chrom, start, end FROM ratsrc.chrloc;
CREATE INDEX r1 on chrloc_rat(gene_id);

-- CREATE TABLE cytoBand_rat AS
--  SELECT chrom, chromStart, chromEnd, cytoBandName
--  FROM ratsrc.cytoBand;

CREATE TABLE chrlength_rat AS
 SELECT chr, length
 FROM ratsrc.chrlength;

-- CREATE TABLE ucsc_gene_rat AS
--  SELECT ucsc_id, gene_id
--  FROM ratsrc.ucsc_id;

CREATE TABLE metadata_rat (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_rat
 SELECT * FROM ratsrc.metadata;

DETACH DATABASE ratsrc;


ATTACH DATABASE "../fly/gpsrc.sqlite" AS flysrc;

CREATE TABLE chrloc_fly as
 SELECT gene_id, chrom, start, end FROM flysrc.chrloc;
CREATE INDEX f1 on chrloc_fly(gene_id);

CREATE TABLE cytoBand_fly AS
 SELECT chrom, chromStart, chromEnd, cytoBandName
 FROM flysrc.cytoBand;

CREATE TABLE chrlength_fly AS
 SELECT chr, length
 FROM flysrc.chrlength;

CREATE TABLE metadata_fly (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_fly
 SELECT * FROM flysrc.metadata;

DETACH DATABASE flysrc;



ATTACH DATABASE "../fish/gpsrc.sqlite" AS fishsrc;

CREATE TABLE chrloc_fish as
 SELECT gene_id, chrom, start, end FROM fishsrc.chrloc;
CREATE INDEX fi1 on chrloc_fish(gene_id);

-- CREATE TABLE cytoBand_fish AS
--  SELECT chrom, chromStart, chromEnd, cytoBandName
--  FROM fishsrc.cytoBand;

CREATE TABLE chrlength_fish AS
 SELECT chr, length
 FROM fishsrc.chrlength;

CREATE TABLE metadata_fish (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_fish
 SELECT * FROM fishsrc.metadata;

DETACH DATABASE fishsrc;



ATTACH DATABASE "../canine/gpsrc.sqlite" AS caninesrc;

CREATE TABLE chrloc_canine as
 SELECT gene_id, chrom, start, end FROM caninesrc.chrloc;
CREATE INDEX ca1 on chrloc_canine(gene_id);

-- CREATE TABLE cytoBand_canine AS
--  SELECT chrom, chromStart, chromEnd, cytoBandName
--  FROM caninesrc.cytoBand;

CREATE TABLE chrlength_canine AS
 SELECT chr, length
 FROM caninesrc.chrlength;

CREATE TABLE metadata_canine (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_canine
 SELECT * FROM caninesrc.metadata;

DETACH DATABASE caninesrc;



ATTACH DATABASE "../bovine/gpsrc.sqlite" AS bovinesrc;

CREATE TABLE chrloc_bovine as
 SELECT gene_id, chrom, start, end FROM bovinesrc.chrloc;
CREATE INDEX bo1 on chrloc_bovine(gene_id);

-- CREATE TABLE cytoBand_bovine AS
--  SELECT chrom, chromStart, chromEnd, cytoBandName
--  FROM bovinesrc.cytoBand;

CREATE TABLE chrlength_bovine AS
 SELECT chr, length
 FROM bovinesrc.chrlength;

CREATE TABLE metadata_bovine (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_bovine
 SELECT * FROM bovinesrc.metadata;

DETACH DATABASE bovinesrc;



ATTACH DATABASE "../worm/gpsrc.sqlite" AS wormsrc;

CREATE TABLE chrloc_worm as
 SELECT gene_id, chrom, start, end FROM wormsrc.chrloc;
CREATE INDEX cel1 on chrloc_worm(gene_id);

-- CREATE TABLE cytoBand_worm AS
--  SELECT chrom, chromStart, chromEnd, cytoBandName
--  FROM wormsrc.cytoBand;

CREATE TABLE chrlength_worm AS
 SELECT chr, length
 FROM wormsrc.chrlength;

CREATE TABLE metadata_worm (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_worm
 SELECT * FROM wormsrc.metadata;

DETACH DATABASE wormsrc;



-- ATTACH DATABASE "../pig/gpsrc.sqlite" AS pigsrc;

-- CREATE TABLE chrloc_pig as
--  SELECT gene_id, chrom, start, end FROM pigsrc.chrloc;
-- CREATE INDEX pig1 on chrloc_pig(gene_id);

-- -- CREATE TABLE cytoBand_pig AS
-- --  SELECT chrom, chromStart, chromEnd, cytoBandName
-- --  FROM pigsrc.cytoBand;

-- CREATE TABLE chrlength_pig AS
--  SELECT chr, length
--  FROM pigsrc.chrlength;

-- CREATE TABLE metadata_pig (
--  name TEXT,
--  value TEXT
-- );

-- INSERT INTO metadata_pig
--  SELECT * FROM pigsrc.metadata;

-- DETACH DATABASE pigsrc;



ATTACH DATABASE "../chicken/gpsrc.sqlite" AS chickensrc;

CREATE TABLE chrloc_chicken as
 SELECT gene_id, chrom, start, end FROM chickensrc.chrloc;
CREATE INDEX chick1 on chrloc_chicken(gene_id);

-- CREATE TABLE cytoBand_chicken AS
--  SELECT chrom, chromStart, chromEnd, cytoBandName
--  FROM chickensrc.cytoBand;

CREATE TABLE chrlength_chicken AS
 SELECT chr, length
 FROM chickensrc.chrlength;

CREATE TABLE metadata_chicken (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_chicken
 SELECT * FROM chickensrc.metadata;

DETACH DATABASE chickensrc;




ATTACH DATABASE "../yeast/gpsrc.sqlite" AS yeastsrc;

CREATE TABLE chrlength_yeast AS
 SELECT chr, length
 FROM yeastsrc.chrlength;

CREATE TABLE metadata_yeast (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_yeast
 SELECT * FROM yeastsrc.metadata;

DETACH DATABASE yeastsrc;




ATTACH DATABASE "../rhesus/gpsrc.sqlite" AS rhesussrc;

CREATE TABLE chrloc_rhesus as
 SELECT gene_id, chrom, start, end FROM rhesussrc.chrloc;
CREATE INDEX rhesus1 on chrloc_rhesus(gene_id);

-- CREATE TABLE cytoBand_rhesus AS
--  SELECT chrom, chromStart, chromEnd, cytoBandName
--  FROM rhesussrc.cytoBand;

CREATE TABLE chrlength_rhesus AS
 SELECT chr, length
 FROM rhesussrc.chrlength;

CREATE TABLE metadata_rhesus (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_rhesus
 SELECT * FROM rhesussrc.metadata;

DETACH DATABASE rhesussrc;




ATTACH DATABASE "../anopheles/gpsrc.sqlite" AS anophelessrc;

-- CREATE TABLE chrloc_anopheles as
--  SELECT gene_id, chrom, start, end FROM anophelessrc.chrloc;
-- CREATE INDEX anopheles1 on chrloc_anopheles(gene_id);

-- CREATE TABLE cytoBand_anopheles AS
--  SELECT chrom, chromStart, chromEnd, cytoBandName
--  FROM anophelessrc.cytoBand;

CREATE TABLE chrlength_anopheles AS
 SELECT chr, length
 FROM anophelessrc.chrlength;

CREATE TABLE metadata_anopheles (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_anopheles
 SELECT * FROM anophelessrc.metadata;

DETACH DATABASE anophelessrc;





ATTACH DATABASE "../chimp/gpsrc.sqlite" AS chimpsrc;

CREATE TABLE chrloc_chimp as
 SELECT gene_id, chrom, start, end FROM chimpsrc.chrloc;
CREATE INDEX chimp1 on chrloc_chimp(gene_id);

-- CREATE TABLE cytoBand_chimp AS
--  SELECT chrom, chromStart, chromEnd, cytoBandName
--  FROM chimpsrc.cytoBand;

CREATE TABLE chrlength_chimp AS
 SELECT chr, length
 FROM chimpsrc.chrlength;

CREATE TABLE metadata_chimp (
 name TEXT,
 value TEXT
);

INSERT INTO metadata_chimp
 SELECT * FROM chimpsrc.metadata;

DETACH DATABASE chimpsrc;
