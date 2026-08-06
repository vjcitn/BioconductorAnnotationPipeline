
.libPaths("~/R-libraries")

term_f <- "term.txt"
term2term_f <- "term2term.txt"
term_definition_f <- "term_definition.txt"
term_synonym_f <- "term_synonym.txt"
graph_path_f <- "graph_path.txt"


obo <- GSEABase::getOBOCollection('../go-basic.obo')
kv <- obo@.kv
stanza <- obo@.stanza

synonym_type <- c('alt_id')
synonym_scope <- c('exact', 'related', 'broad', 'narrow')
universal <- c('all')

names <- rownames(stanza)[-1]  ## Remove __Root__
names <- c("is_a", names)      ## Add is_a relationship
names <- c(names, synonym_type)    ## Add synonym_type
names <- c(names, synonym_scope)    ## Add synonym_scope
names <- c(names, universal)     ## Add universal 

## Create term table
terms <- data.frame(id = seq_along(names),
                    name = names)

temp_df <- kv[kv$key == 'namespace',][-2]  ## extract term relationships from kv
names(temp_df) <- c('name', 'term_type')
term <- dplyr::left_join(terms, temp_df)

term['acc'] <- term['name']     ## Works if not including subsets in term table

nam <- kv[kv$key == 'name',][-2]
colnames(nam) <- c('name', 'value')
temp <- dplyr::left_join(term, nam)
term['name'] <- ifelse(is.na(temp$value), term$name, temp$value)

obselete <- kv[kv$key == 'is_obsolete',][[1]] ## Get tags that are absolete

term['is_obsolete'] <- ifelse(names %in% obselete, 1, 0)

term['is_root'] <- rep(0, nrow(term))



relationships <- c('relationship', 'external')
term['is_relationship'] <- ifelse(term$term_type %in% relationships, 1, 0)
term[term$name == 'is_a', 'term_type'] <- 'relationship'
term[term$name %in% synonym_type, 'term_type'] <- 'synonym_type'
term[term$name %in% synonym_scope, 'term_type'] <- 'synonym_scope'
## universal is a root 
term[term$name %in% universal, c('term_type','is_root')] <- c('universal',1)

write.table(term, file = term_f, quote=F, col.names=F, row.names=F, sep = "\t")


## Create term2term table

is_a <- kv[kv$key == 'is_a',]
colnames(is_a) <- c('term1_id', 'relationship_type_id', 'term2_id')

relations <- kv[kv$key == 'relationship',][-2]
relations <- tidyr::separate(relations, value, c('V2', 'V3'), sep = " ")
colnames(relations) <- c('term1_id', 'relationship_type_id', 'term2_id')

relations <- rbind(is_a, relations)

## separate ontologies for last steps
bpids <- match(kv[kv$value == "biological_process",1], names)
mfids <- match(kv[kv$value == "molecular_function",1], names)
ccids <- match(kv[kv$value == "cellular_component",1], names)


rel2term <- function(reldf, namvec){
    ## function to generate term2term data.frame
    ## reldf is a 'relations' data.frame like 'relations'
    ## namvec is a vector of GO IDs, e.g., the 'names' vector
    ## note that term2 is the parent of term1, and the term2term
    ## file we output has the parent in column 3 and the child in column 4
    reldf <- as.data.frame(apply(reldf, 2, function(x) match(x, namvec)))
    reldf$id <- seq_len(nrow(reldf))
    reldf$complete <- 0
    reldf <- reldf[,c(4, 2, 3, 1, 5)]
    reldf
}

term2term <- rel2term(relations, names)

## check to see that there aren't any cross-ontology term matches
crossmatchTest <- function(ids, termdf)
    all(rowSums(cbind(termdf$term1_id %in% ids, termdf$term2_id %in% ids)) %in% c(0,2))
stopifnot(all(sapply(list(bpids, mfids, ccids), crossmatchTest, termdf = term2term)))

## add in the relationship between the 'universal' term and
## all the root terms (biological_process, molecular_function, cellular_component)
## this used to come as part of the term2term.txt file we got from geneontology.org
## but now we have to add by hand

root_terms <- c("biological_process","cellular_component","molecular_function")
univterms <- data.frame(id = term2term[nrow(term2term), 'id'] + c(1:3),
                        relationship_type_id = rep(1, 3),
                        term2_id = rep(term[nrow(term), 'id'], 3),
                        term1_id = term[term$name %in% root_terms, 'id'],
                        complete = rep(0,3))
term2term <- rbind(term2term, univterms)

term2termlst <- lapply(list(bpids, mfids, ccids),
                       function(x) term2term[term2term$term1_id %in% x,])

write.table(term2term, file = term2term_f, quote=F, col.names=F, row.names=F, sep = "\t")


## term_synonym.txt

alt_id <- kv[kv$key == 'alt_id',]
colnames(alt_id) <- c('term_id', 'synonym_type_id', 'term_synonym')
alt_id['acc_synonym'] <- alt_id['term_synonym']
alt_id['synonym_category_id'] <- "\\N"

synonym <- kv[kv$key == 'synonym',]
by_synonym <- lapply(synonym_scope, function(s) {               # This extracts synonyms from our kv data.frame and parses them to adhere to the term_synonym table
    val <- synonym[grep(toupper(s), synonym$value),][-2]
    val$value <- stringi::stri_extract_first_regex(val$value, '(?<=").*?(?=")')
    val['synonym_type_id'] <- s
    val
})
by_synonym <- do.call(rbind, by_synonym)

colnames(by_synonym) <- c('term_id', 'term_synonym', 'synonym_type_id')
by_synonym['acc_synonym'] <- "\\N"
by_synonym['synonym_category_id'] <- "\\N"

term_synonym <- rbind(alt_id, by_synonym)

term_synonym$term_id <- match(term_synonym$term_id, names)
term_synonym$synonym_type_id <- match(term_synonym$synonym_type_id, names)

term_synonym <- term_synonym[c(1, 3, 4, 2, 5)]
    
write.table(term_synonym, file = term_synonym_f, quote=F, col.names=F, row.names=F, sep = "\t")


## term_definition.txt

def <-  kv[kv$key == 'def',][-2]
colnames(def) <- c('term_id', 'term_definition')
def[[1]] <- match(def[[1]], names)
def$term_definition <- unlist(stringi::stri_extract_first_regex(def$term_definition, '(?<=").*?(?=")'))

comment <- kv[kv$key == 'comment',][-2]
colnames(comment) <- c('term_id', 'term_comment')
comment[[1]] <- match(comment[[1]], names)

term_definition <- dplyr::left_join(def, comment)

term_definition['dbx_ref_id'] <- '\\N'
term_definition['reference'] <- '\\N'

term_definition <- term_definition[c(1, 2, 4, 3, 5)]

term_definition[is.na(term_definition)] <- "//N"   # Change any remaining NA's to mysql-friendly //N's


write.table(term_definition, file = term_definition_f, quote=F, col.names=F, row.names=F, sep = "\t")


## graph_path.txt

## NOTE: This section generalizes the file to only show generate edges in the transitive closure
## We assume that the shortest distances are not going to be needed, so those are set to one.

## in prior versions, the following was just done for all
## the GO terms at once. But RBGL::transitive.closure is
## now aborting if we do that, killing the R process
## Not sure why that is, but it appears to work if we
## use each ontology separately. 

tt2graph_path <- function(term2termobj, namevec){
    V <- as.character(seq_along(namevec))
    ## Convenionally the GO graph is thought of as being a directed
    ## graph, where the edge directions are from more specific to
    ## lesss specific terms (child -> parent). But we are interested
    ## in the opposite direction (parent -> child), because we want
    ## to populate for example the go_bp_offspring table
    ## so we need the transitive graph going the other direction
    ## Therefore we split the term2 IDs using the term1 IDs to
    ## get the reversed direction
    E <- with(term2termobj, split(term1_id, term2_id))
    V <- V[V %in% unique(c(names(E), do.call(c, E)))]
    gg <- graph::graphNEL(V, E, "directed")
    tc <- RBGL::transitive.closure(gg)
    edges <- graph::edges(tc)
    edges <- lapply(names(edges), function(x) {
        e1 <- edges[[x]]
        e2 <- rep(x, length(e1))
        data.frame(V2 = e1, V3 = e2)
    })
    graph_path <- do.call(rbind, edges)
    graph_path$V1 <- seq_len(nrow(graph_path))
    graph_path <- graph_path[, c(3,1,2)]
    ones <- rep(1, nrow(graph_path))
    graph_path$V4 <- ones
    graph_path$V5 <- ones
    graph_path$V6 <- ones
    graph_path <- graph_path[,c(1,3,2,4,5,6)]
    two_col <- graph_path[,c(2,3)]
    dup <- duplicated(t(apply(two_col, 1, sort)))
    graph_path <- graph_path[!dup,]
    graph_path
}

gplst <- lapply(term2termlst, tt2graph_path, namevec = names)

## the first column has to be 1:nrow the ending data.frame, so
## do the math first
gplst[[2]][,1] <- gplst[[2]][,1] + gplst[[1]][nrow(gplst[[1]]),1]
gplst[[3]][,1] <- gplst[[3]][,1] + gplst[[2]][nrow(gplst[[2]]),1]

graph_path <- do.call(rbind, gplst)

write.table(graph_path, file = graph_path_f, quote=F, col.names=F, row.names=F, sep = "\t")

