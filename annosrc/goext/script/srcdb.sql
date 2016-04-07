.echo ON
.separator " "

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);

CREATE TABLE ec2go (
  ec_no VARCHAR(16) NOT NULL,                   -- EC number (with "EC:" prefix)
  go_id CHAR(10) NOT NULL                       -- GO ID
);
.import ec2go ec2go
