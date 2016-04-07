.echo ON
.separator \t

--Here we will join things to get an entrezGene2GO table.
ATTACH DATABASE 'chipmapsrc_canine.sqlite' AS CfMapSrc;

CREATE TABLE Cf_eg2go (
 eg_id VARCHAR(20) NOT NULL,
 go_id VARCHAR(20) NOT NULL
);

INSERT INTO Cf_eg2go
  SELECT map.gene_id, go.go_id
  FROM CfMapSrc.refseq AS map, Cf_refseq2go as go 
  WHERE map.accession = go.rs_id;

INSERT INTO Cf_eg2go
  SELECT map.gene_id, go.go_id
  FROM CfMapSrc.accession AS map, Cf_genbank2go as go 
  WHERE map.accession = go.gb_id;


ATTACH DATABASE 'chipmapsrc_pig.sqlite' AS SscMapSrc;

CREATE TABLE Ssc_eg2go (
 eg_id VARCHAR(20) NOT NULL,
 go_id VARCHAR(20) NOT NULL
);

INSERT INTO Ssc_eg2go
  SELECT map.gene_id, go.go_id
  FROM SscMapSrc.refseq AS map, Ssc_refseq2go as go 
  WHERE map.accession = go.rs_id;

INSERT INTO Ssc_eg2go
  SELECT map.gene_id, go.go_id
  FROM SscMapSrc.accession AS map, Ssc_genbank2go as go 
  WHERE map.accession = go.gb_id;



ANALYZE;
