.echo ON

DELETE FROM enzyme where locus="Gene";

CREATE INDEX enzyme1 on enzyme(locus);
CREATE INDEX pmid1 on pmid(locus);
