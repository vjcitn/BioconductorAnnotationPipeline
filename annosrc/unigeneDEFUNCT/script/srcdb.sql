.echo ON
.separator \t

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);

CREATE TEMP TABLE tmp_accession_unigene (
        gene_id TEXT,
        accession TEXT
);
.import unigene.txt tmp_accession_unigene
CREATE INDEX tt1 on tmp_accession_unigene(accession);

DROP TABLE IF EXISTS accession_unigene;
CREATE TABLE accession_unigene (
        gene_id TEXT,
        accession TEXT
);

INSERT INTO accession_unigene
 SELECT min(gene_id), accession
 FROM tmp_accession_unigene
 GROUP BY accession;

CREATE INDEX au1 on accession_unigene(accession);



CREATE TEMP TABLE tmp_image_acc_from_uni (
        gene_id TEXT,
        accession TEXT
);
.import image.txt tmp_image_acc_from_uni
CREATE INDEX tti1 on tmp_image_acc_from_uni(accession);

DROP TABLE IF EXISTS image_acc_from_uni;
CREATE TABLE image_acc_from_uni (
        gene_id TEXT,
        accession TEXT
);

INSERT INTO image_acc_from_uni
 SELECT min(gene_id), accession
 FROM tmp_image_acc_from_uni
 GROUP BY accession;

CREATE INDEX iafu1 on image_acc_from_uni(accession);

DELETE FROM image_acc_from_uni WHERE accession = "";


ANALYZE;
