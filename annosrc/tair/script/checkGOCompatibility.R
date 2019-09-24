## R script to verify that the GO we are mapping the ALL mappings with does not not have terms that are not in the present mapping (which could create problems).

##If this test fails, then you have to go and get an older (more compatible) GO source.


##should look sort of like our other check.  Except that if this fails we will just have to STOP.
##In the example case from before (below), we are checking to see if we have a go term that is NOT in go.go_term
## select count(distinct go_id) from go where go_id NOT IN (select go_id from go.go_term);

##But in the new case, we will want to check if we have a go term in the GO
##sources that is NOT in our go_bp, go_mf or go_cc tables.  If we find such an
##animal, then it means that our GO sources are "too new" relative to the
##original sources.  If that happens, then there will be GO terms added to our
##go_xx_all tables that are not able to be found in the GO sources that were
##originally distributed.  So in that case, we would want to STOP in that case
##and rebuild the older GO sources...


##So to check this, we want to compare the go_bp table to the go_bp_offspring
##table from the gosrc.sqlite DB that we are trying to use.

##Should look like this:
##as read from WITHIN the newly minted chipsrc_arabidopsis.sqlite DB 
##ATTACH "GO.sqlite" as go;
##select count(distinct go_id) from go_bp_all where go_id NOT IN (select go_id from go.go_term);

##now just make it so that that the go_bp_all, go_mf_all and go_cc_all go_ids are checked at once.
##select count(distinct go_id) FROM (SELECT go_id from go_bp_all UNION SELECT go_id from go_cc_all UNION SELECT go_id from go_mf_all) where go_id NOT IN (select go_id from go.go_term);


.libPaths("~/R-3.6.1")
library("DBI")
library("RSQLite")

drv <- dbDriver("SQLite")
con <- dbConnect(drv, "../../db/chipsrc_arabidopsis.sqlite")

sql <- "ATTACH '../../db/GO.sqlite' as go;"
## sql <- "ATTACH '../../db/GO.sqlite_oldBAK' as go;"
dbGetQuery(con, sql)

sql <- "select count(distinct go_id) FROM (SELECT go_id from go_bp_all UNION SELECT go_id from go_cc_all UNION SELECT go_id from go_mf_all) where go_id NOT IN (select go_id from go.go_term);"

res = dbGetQuery(con, sql)

if(res!=0){
 stop("There apears to be a problem with foreign GO terms in your go_xx_all tables.  The GO sources you are using to populate the go_xx_all tables appear to be too new to have come from the GO.sqlite database that is present.  Please verify that the GO.sqlite package used out in the world is the same one being used to make the go_xx_all tables.")
}



##Of course there is a huge problem with this, because the GO.sqlite DB will also be new and therefore not tell you if there is a problem...  So I need a way to make this check against a "standard" that can be set 2X a year and THEN I will have a real test.  This is in line with Roberts proposal that I need some standard DBs hanging around for me to check against to see if things have changed much...  I probably want to point this to the sanctionedSQLite dir for a given release.
