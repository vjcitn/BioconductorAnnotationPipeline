.echo ON

CREATE INDEX gl1 on gene_literature(sgd);

CREATE INDEX sf1 on sgd_features(sgd);

-- CREATE INDEX rg1 on registry_genenames(sgd);