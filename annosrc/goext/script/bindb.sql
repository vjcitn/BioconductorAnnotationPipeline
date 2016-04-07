.echo ON
ATTACH DATABASE "ec2gosrc.sqlite" AS goext;

CREATE TABLE ec2go AS
 SELECT * FROM goext.ec2go;

INSERT INTO metadata
 SELECT * FROM goext.metadata;

DETACH DATABASE goext;
