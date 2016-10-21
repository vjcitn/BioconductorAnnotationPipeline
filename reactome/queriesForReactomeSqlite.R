## I need the following
library(RSQLite)
con <- dbConnect(SQLite(), "reactome.sqlite")


#--catalysts:
sql <- "SELECT c.DB_ID AS pathway, ltrim(g.otherIdentifier,'EntrezGene:') AS entrez_gene FROM (SELECT p.DB_ID, cc.physicalEntity FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_catalystActivity AS c, CatalystActivity AS cc WHERE p.hasEvent=c.DB_ID AND c.catalystActivity=cc.DB_ID) AS c, (SELECT DISTINCT s.DB_ID, g.otherIdentifier FROM ReferenceEntity_2_otherIdentifier AS g, EntityWithAccessionedSequence AS s  WHERE g.DB_ID = s.referenceEntity AND otherIdentifier LIKE 'EntrezGene:%') as g WHERE c.physicalEntity = g.DB_ID"
foo1 <- dbGetQuery(con, sql)
head(foo1)

#--catalysts in complexes:
sql <- "SELECT c.DB_ID AS pathway, ltrim(g.otherIdentifier,'EntrezGene:') AS entrez_gene FROM (SELECT p.DB_ID, ccc.hasComponent FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_catalystActivity AS c, CatalystActivity AS cc, Complex_2_hasComponent AS ccc WHERE p.hasEvent=c.DB_ID AND c.catalystActivity=cc.DB_ID AND cc.physicalEntity_class='Complex' AND  cc.physicalEntity=ccc.DB_ID) AS c, (SELECT DISTINCT s.DB_ID, g.otherIdentifier FROM ReferenceEntity_2_otherIdentifier AS g, EntityWithAccessionedSequence AS s  WHERE g.DB_ID = s.referenceEntity AND otherIdentifier LIKE 'EntrezGene:%') as g WHERE c.hasComponent = g.DB_ID"
foo2 <- dbGetQuery(con, sql)
head(foo2)

#--inputs
sql <- "SELECT i.DB_ID AS pathway, ltrim(g.otherIdentifier,'EntrezGene:') AS entrez_gene FROM (SELECT p.DB_ID, i.input FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_input AS i WHERE p.hasEvent=i.DB_ID) AS i, (SELECT DISTINCT s.DB_ID, g.otherIdentifier FROM ReferenceEntity_2_otherIdentifier AS g, EntityWithAccessionedSequence AS s  WHERE g.DB_ID = s.referenceEntity AND otherIdentifier LIKE 'EntrezGene:%') as g WHERE i.input = g.DB_ID"
foo3 <- dbGetQuery(con, sql)
head(foo3)

#--outputs
sql <- "SELECT o.DB_ID AS pathway, ltrim(g.otherIdentifier,'EntrezGene:') AS entrez_gene FROM (SELECT p.DB_ID, o.output FROM Pathway_2_hasEvent AS p, ReactionlikeEvent_2_output AS o WHERE p.hasEvent=o.DB_ID) AS o, (SELECT DISTINCT s.DB_ID, g.otherIdentifier FROM ReferenceEntity_2_otherIdentifier AS g, EntityWithAccessionedSequence AS s  WHERE g.DB_ID = s.referenceEntity AND otherIdentifier LIKE 'EntrezGene:%') as g WHERE o.output = g.DB_ID"
foo4 <- dbGetQuery(con, sql)
head(foo4)

bar = unique(rbind(foo1, foo2, foo3, foo4))
dim(bar)
