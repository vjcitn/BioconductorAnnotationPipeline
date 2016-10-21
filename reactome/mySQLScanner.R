## This is meant to be an R script to scan SQL, split on ";" and then to keep
## elements that start with "CREATE TABLE", and these will be named after the
## string that comes next when those strings are split by " ".

## ## Will want to make this into a function too.

## foo = scan(file="scrap.sql", what=character(), sep=";")
## ## Hmmm...
## scan(file="scrap.sql", what=character(), sep=";", blank.lines.skip = TRUE)


## ## better?
## foo = scan(file="scrap.sql", what=list(""), sep=";", strip.white=TRUE)
## foo = scan(file="scrap.sql", what=list(""), sep=";", strip.white=TRUE, multi.line=TRUE)


## ## lets go with this for now (can't seem to get scan to split based on ";"
## ## alone)
## foo = scan(file="scrap.sql", what="")
## foo = paste(foo, collapse=" ")
## foo = unlist(strsplit(foo, split=";"))
## foo = foo[grep("CREATE", foo)]


## ## Vals version (seems to not quite work right- which is odd since the only
## ## change is that it tries to respect the comment.char argument...
## ## Basically, calling it this way sometimes leaves things appended that
## ## should be split off (deletes ";"s?)
## sqlSlurper <- function(file, SQLFilter="CREATE",encoding="UTF-8") {
##     raw <- scan(file, what="", comment.char="-",encoding=encoding)
##     string <- paste(raw, collapse=" ")
##     char <- unlist(strsplit(string, split=";"))
##     filt <- char[grep(SQLFilter, char)]
##     ##trim whitespace
##     filt = sub("^ ","",filt)
##     sub(" $","",filt)
## }
## ## boo = sqlSlurper("sqlite3.sql")


## Lets factor out a simple stream operation
sqlScanner <- function(file, encoding="UTF-8"){
  raw = scan(file=file, what="", encoding=encoding)
  paste(raw, collapse=" ")
}


## requires that SQL statements be properly separated by ";"
sqlParseFile <- function(file,SQLFilter="CREATE", encoding="UTF-8"){
  string <- sqlScanner(file, encoding=encoding)
  char <- unlist(strsplit(string, split=";"))
  filt <- char[grep(SQLFilter, char)]
  filt <- sub("^ ","",filt)
  sub(" $","",filt) 
}
## USAGE: sqlParseFile("scrap.sql")


## TODO: maybe methodize to combine sqlParseFile and sqlParserString
sqlParseString <- function(string,SQLFilter="CREATE"){
  char <- unlist(strsplit(string, split=";"))
  filt <- char[grep(SQLFilter, char)]
  filt <- sub("^ ","",filt)
  sub(" $","",filt) 
}


## To create the CREATE TABLE statements just do this:

## crts <- sqlParseFile("sqlite3.sql")
## crts <- paste(crts, collapse=";\n")
## write(crts, file="createStatements.sql")


## I also need some functions that will take the data directly from the MySQL dump and then parse it into a form that can be used here.
convertMySQLToSQLite <- function(file, encoding="UTF-8"){
  ## Insert stmnts must be separated from Create stmnts
  string <- sqlScanner(file, encoding="UTF-8")
  strng <- gsub("INSERT",");INSERT",string)
                 
  ## Read in and "adjust" the CREATE statements.
  # crt <- sqlParseString(string)
  ## drop the following
  # crt <- gsub("`","",crt)
  # crt <- gsub("`","",crt)
  
  ## Read in and "adjust" the INSERT statements.
  # insrt <- sqlParseString(string, SQLFilter="INSERT")
  
}

###################
## I am running into problems handling the really large strings.
## I think I probably want to use Nishants streamer stuff here?
