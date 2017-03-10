## library("DBI")
library("RSQLite")


popInpTab = function(table, srcSpecies, db, five){

    ##derive the other species name from the table.
    otherSpecies = sub("\\_$","",sub("^\\_","",sub(srcSpecies,"",table)))
    ##derive the new table name
    newTable = otherSpecies
    otherSpcAbbrev = five[[otherSpecies]]
    srcSpcAbbrev = five[[srcSpecies]]
      
    ##Make a table
    message(cat(paste("Creating table: ",newTable,sep="")))
    sql<- paste("    CREATE TABLE IF NOT EXISTS ",newTable, " (
        inp_id VARCHAR(30) UNIQUE NOT NULL,
        clust_id INTEGER NOT NULL,
        species CHAR(5) NOT NULL,
        score VARCHAR(6) NOT NULL,
        seed_status CHAR(4))
    ;", sep="")
    dbGetQuery(db, sql)

    ##Get the data out that we want to insert
    sql<- paste("
       SELECT ID, clust_id,
       species,
       score, seed_status 
       FROM inp.",table,";
       ", sep="")
    data <- dbGetQuery(db, sql)
    
    ##Process that data to remove .fa and to convert the species abbreviation into a code. (for now)
    data[,"species"] <- sub(".fa$","", data[,"species"])
    altFive <- five
    names(altFive) <- sub("^(.).+_","\\1.",names(altFive),perl=TRUE)    
    data[,"species"] <- altFive[match(data[,"species"], names(altFive))]
    
    ##Populate that table
    message(cat(paste("Populating table: ",newTable,sep="")))
    sql<- paste("    INSERT into ",newTable,
       " (inp_id, clust_id, species, score, seed_status) VALUES
        (?,?,?,?,?)",sep="")
    dbBeginTransaction(conn=db)  ## BOOM
    dbSendQuery(db, sql, data=unclass(unname(data)))
    dbCommit(db)
    
    ##Two indices per table
    ind1 = paste(otherSpcAbbrev,"_c",sep="")
    sql<- paste("CREATE INDEX IF NOT EXISTS ",ind1," ON ",newTable,
                "(clust_id);",sep="")
    dbGetQuery(db, sql)
    ind2 = paste(otherSpcAbbrev,"_s",sep="")
    sql<- paste("CREATE INDEX IF NOT EXISTS ",ind2," ON ",newTable,
                "(species);",sep="")
    dbGetQuery(db, sql)
    
    ##Map Metadata: (table was created by parent function)
    sql<- paste("
      INSERT INTO map_metadata
       SELECT '",otherSpcAbbrev,"', m1.value, m2.value, m3.value
       FROM inp.metadata AS m1, inp.metadata AS m2, inp.metadata AS m3
       WHERE m1.name='INPSOURCENAME' AND
             m2.name='INPSOURCEURL' AND
             m3.name='INPSOURCEDATE';",sep="")
    dbGetQuery(db, sql)

    ##MapCounts: (table was created by parent function)
    sql<- paste("
      INSERT INTO map_counts
       SELECT '",otherSpcAbbrev,"', COUNT(DISTINCT one.inp_id) FROM
       (SELECT * FROM ",newTable," where seed_status LIKE '100%' AND species LIKE '%",srcSpcAbbrev,"%') as one INNER JOIN
       (SELECT * FROM ",newTable," where seed_status LIKE '100%' AND species LIKE '%",otherSpcAbbrev,"%') as two
       WHERE one.clust_id = two.clust_id;",sep="")
    dbGetQuery(db, sql)

}



makeINP_DB = function(species, tableNames, five, ipPath, metaPath){
  
    fiveLetters <- five[[species]]
    twoLetters <- paste(toupper(substr(fiveLetters,1,1)),
                        tolower(substr(fiveLetters,4,4)),sep="")
    dbname <- paste("hom.",twoLetters,".inp.sqlite",sep="")
    drv <- dbDriver("SQLite")
    db <- dbConnect(drv,dbname=dbname)

    sql<-paste("ATTACH DATABASE '",ipPath,"' AS inp;",sep="")
    dbGetQuery(db, sql)
        
    ##Find all tablenames with 5 letter codes that match.  We need to make tables of each.
    tablesInd = grep(species, tableNames)
    tables = tableNames[tablesInd]


    ##Create various metadata tables    
    sql<- paste("CREATE TABLE metadata (
      name VARCHAR(80) PRIMARY KEY,
      value VARCHAR(255));")
    dbGetQuery(db, sql)
                
    sql<- paste("INSERT INTO metadata
      SELECT * FROM inp.metadata
      WHERE name LIKE 'INP%';")
    dbGetQuery(db, sql)

    pkgPrefix <- paste("hom.",twoLetters,".inp",sep="") ##temporary insert.
    sql<- paste("INSERT INTO metadata (name, value)
      VALUES ('PKGNAME', '",pkgPrefix,"');", sep="")
    dbGetQuery(db, sql)

    ##The whole thing depends on this metadatasrc.sqite DB that we maintain.
    sql<- paste("ATTACH DATABASE '", metaPath ,"' AS meta;",sep="")
    dbGetQuery(db, sql)
        
    sql<- paste("INSERT INTO metadata
      SELECT 'DBSCHEMA', db_schema
      FROM meta.metadata
      WHERE package_name IN
        (SELECT value FROM metadata WHERE name='PKGNAME');")
    dbGetQuery(db, sql)
    
    sql<- paste("INSERT INTO metadata
      SELECT 'ORGANISM', organism
      FROM meta.metadata
      WHERE package_name IN
        (SELECT value FROM metadata WHERE name='PKGNAME');")
    dbGetQuery(db, sql)

    sql<- paste("INSERT INTO metadata
      SELECT 'SPECIES', species
      FROM meta.metadata
      WHERE package_name IN
        (SELECT value FROM metadata WHERE name='PKGNAME');")
    dbGetQuery(db, sql)

    sql<- paste("DELETE FROM metadata WHERE name='PKGNAME';")
    dbGetQuery(db, sql)

    ## Some metadata to indicate what the package is etc.
    sql<- "INSERT INTO metadata (name, value)
      VALUES ('package', 'AnnotationDbi');"
    dbGetQuery(db, sql)   
    sql<- "INSERT INTO metadata (name, value)
      VALUES ('Db type', 'InparanoidDb');"
    dbGetQuery(db, sql)


    ##Create the map_counts and map_metadata tables as well
    sql<- paste("    CREATE TABLE map_metadata (
      map_name VARCHAR(80) NOT NULL,
      source_name VARCHAR(80) NOT NULL,
      source_url VARCHAR(255) NOT NULL,
      source_date VARCHAR(20) NOT NULL);")
    dbGetQuery(db, sql)
    
    sql<- paste("CREATE TABLE map_counts (
      map_name VARCHAR(80) PRIMARY KEY,
      count INTEGER NOT NULL);")
    dbGetQuery(db, sql)

    
    ##For all the tables in our list, make a table for the DB and populate it
    for(i in seq_len(length(tables))){        
        popInpTab(table = tables[i], srcSpecies = species, db = db, five)    
    }
   
}




makeDBs <- function(dataDir=".", metaDir= NULL){
    if(is.null(metaDir)) stop("You must specify a dir that contains the databases!")

  ##Make some generic tables to start.
  drv <- dbDriver("SQLite")
  ipPath <- file.path(dataDir,"inparanoid.sqlite")
  metaPath <- file.path(metaDir, "metadatasrc.sqlite")
  db <- dbConnect(drv,dbname= ipPath)
  
  tableNames = dbListTables(db)
  tableNames = tableNames[tableNames!='metadata'] ##not strictly necessary 
  tableNames = tableNames[tableNames!='dm_gene_prot_map'] ##not necessary 
  
  fiveCode = read.delim(system.file("extdata", "fiveLetterCode.txt",
                                 package="InparanoidBaseBuilder"),
    header=FALSE, sep="\t")
  five = as.vector(fiveCode[,1])
  names(five) = fiveCode[,2]
  ##Now I can get the name from the 5 letter code so like:
  ##five[["toupper(tableNames[i])"]] So I will need to get all the names that
  ##have "homsa" in them (for human) - "homsa" will become a parameter later
  ##on.
  

  ##close out the connection to inparanoid DB for now. (only needed it here so
  ##I could get the table names for below
  dbDisconnect(db)

  ##Usage is as below:
  makeINP_DB("Homo_sapiens", tableNames, five, ipPath, metaPath)
  makeINP_DB("Mus_musculus", tableNames, five, ipPath, metaPath)
  makeINP_DB("Drosophila_melanogaster", tableNames, five, ipPath, metaPath)
  makeINP_DB("Rattus_norvegicus", tableNames, five, ipPath, metaPath)
  makeINP_DB("Saccharomyces_cerevisiae", tableNames, five, ipPath, metaPath)
  makeINP_DB("Arabidopsis_thaliana", tableNames, five, ipPath, metaPath)
  makeINP_DB("Danio_rerio", tableNames, five, ipPath, metaPath)
  makeINP_DB("Caenorhabditis_elegans", tableNames, five, ipPath, metaPath)

}


