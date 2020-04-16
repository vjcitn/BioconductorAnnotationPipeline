
term_f <- "term.txt"
term2term_f <- "term2term.txt"
term_definition_f <- "term_definition.txt"
term_synonym_f <- "term_synonym.txt"
graph_path_f <- "graph_path.txt"


obo <- GSEABase::getOBOCollection('go.obo')
kv <- obo@.kv
stanza <- obo@.stanza

synonym_type <- c('alt_id')
synonym_scope <- c('exact', 'related', 'broad', 'narrow')

names <- rownames(stanza)[-1]  ## Remove __Root__
names <- c("is_a", names)      ## Add is_a relationship
names <- c(names, synonym_type)    ## Add synonym_type
names <- c(names, synonym_scope)    ## Add synonym_scope


## Create term table
terms <- data.frame(id = seq_along(names),
                    name = names)

temp_df <- kv[kv$key == 'namespace',][-2]  ## extract term relationships from kv
names(temp_df) <- c('name', 'term_type')
term <- dplyr::left_join(terms, temp_df)

term['acc'] <- term['name']     ## Works if not including subsets in term table

obselete <- kv[kv$key == 'is_obsolete',][[1]] ## Get tags that are absolete

term['is_obsolete'] <- ifelse(names %in% obselete, 1, 0)

term['is_root'] <- rep(0, nrow(term))

relationships <- c('relationship', 'external')
term['is_relationship'] <- ifelse(term$term_type %in% relationships, 1, 0)
term[term$name == 'is_a', 'term_type'] <- 'relationship'
term[term$name %in% synonym_type, 'term_type'] <- 'synonym_type'
term[term$name %in% synonym_scope, 'term_type'] <- 'synonym_scope'

write.table(term, file = term_f, quote=F, col.names=F, row.names=F)


## Create term2term table

is_a <- kv[kv$key == 'is_a',]
colnames(is_a) <- c('term1_id', 'relationship_type_id', 'term2_id')

relations <- kv[kv$key == 'relationship',][-2]
relations <- tidyr::separate(relations, value, c('V2', 'V3'), sep = " ")
colnames(relations) <- c('term1_id', 'relationship_type_id', 'term2_id')

relations <- rbind(is_a, relations)

relations[[1]] <- match(relations[[1]], names)      # Change GO names into the ids we assigned form the term table
relations[[2]] <- match(relations[[2]], names)
relations[[3]] <- match(relations[[3]], names)

term2term <- relations
term2term['id'] <- seq_along(nrow(term2term))
term2term['complete'] <- 0
term2term <- term2term[c(4, 2, 1, 3, 5)]

write.table(term2term, file = term2term_f, quote=F, col.names=F, row.names=F)


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

term_synonym <- dplyr::left_join(alt_id, by_synonym)

term_synonym$term_id <- match(term_synonym$term_id, names)
term_synonym$synonym_type_id <- match(term_synonym$synonym_type_id, names)

term_synonym <- term_synonym[c(1, 3, 4, 2, 5)]
    
write.table(term_synonym, file = term_synonym_f, quote=F, col.names=F, row.names=F)


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


write.table(term_definition, file = term_definition_f, quote=F, col.names=F, row.names=F)


## graph_path.txt

## NOTE: This section generalizes the file to only show generate edges in the transitive closure
## We assume that the shortest distances are not going to be needed, so those are set to one.


V <- as.character(seq_along(names))
E <- with(term2term, split(term1_id, term2_id))
gg <- graph::graphNEL(V, E, "directed")

tc <- RBGL::transitive.closure(gg)

edges <- graph::edges(tc)
edges <- lapply(names(edges), function(x){   # This essentially performs an unsplit operation to get our adjacency data.frame back
    e1 <- edges[[x]]
    e2 <- rep(x, length(e1))
    data.frame(V2 = e1, V3 = e2)
})

graph_path <- do.call(rbind, edges)
graph_path['V1'] <- seq_len(nrow(graph_path))
graph_path <- graph_path[, c(3, 1, 2)]

ones <- rep(1, nrow(graph_path))
graph_path['V4'] <- ones
graph_path['V5'] <- ones
graph_path['V6'] <- ones


write.table(graph_path, file = graph_path_f, quote=F, col.names=F, row.names=F)

