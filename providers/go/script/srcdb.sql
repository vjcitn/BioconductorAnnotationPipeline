.echo ON
.mode tabs
.read ../script/term.sql
.read ../script/term_synonym.sql
.read ../script/term_definition.sql
.read ../script/term2term.sql
.read ../script/graph_path.sql
.import goterm/term.txt term
.import goterm/term_synonym.txt term_synonym
.import goterm/term_definition.txt term_definition
.import goterm/term2term.txt term2term
.import goterm/graph_path.txt graph_path

CREATE TABLE metadata (
 name TEXT,
 value TEXT
);

ANALYZE;

