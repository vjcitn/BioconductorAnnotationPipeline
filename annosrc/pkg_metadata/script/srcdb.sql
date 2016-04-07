.echo ON
.separator \t

CREATE TABLE metadata (
 package_name TEXT,
 db_schema TEXT,
 organism TEXT,
 species TEXT,
 manufacturer TEXT,
 chip_name TEXT,
 manufacture_url TEXT,
 biocViews TEXT
);

.import descriptionInfo.txt metadata
CREATE INDEX m1 on metadata(package_name);
