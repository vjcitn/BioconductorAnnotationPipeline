--1st attach GO.sqlite
ATTACH "../../db/GO.sqlite" as go;


--get all the terms from go_term
-- select go_id from go.go_term;

--How many terms are not in GO.db? (should be 0)
-- select count(distinct go_id) from go where go_id NOT IN (select go_id from go.go_term);


--So "just in case" this is ever NOT zero, we will do this every time.
delete from go where go_id NOT IN (select go_id from go.go_term);

--Now your database is safe!