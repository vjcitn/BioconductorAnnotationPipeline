
term_f <- "term.txt"
term2term_f <- "term2term.txt"
term_definition_f <- "term_definition.txt"
term_synonym_f <- "term_synonym.txt"
graph_path_f <- "graph_path.txt"


obo <- GSEABase::getOBOCollection('go.obo')
kv <- obo@.kv
stanza <- obo@.stanza

synonyms <- c('exact', 'alt_id', 'related', 'broad', 'narrow')

names <- rownames(stanza)[-1]  ## Remove __Root__
names <- c("is_a", names)      ## Add is_a relationship
names <- c(names, synonyms)    ## Add synonyms


## Create term table
terms <- data.frame(id = seq_along(names),
                    name = names)

term_id_names <- terms

temp_df <- kv[kv$key == 'namespace'][-2]
names(temp_df) <- c('name', 'term_type')
term <- dplyr::left_join(terms, temp_df)

term['acc'] <- term['name']     ## Works if not including subsets in term table

obselete <- kv[kv$key == 'is_obsolete'][[1]] ## Get tags that are absolete

term['is_obsolete'] <- ifelse(names %in% obselete, 1, 0)

term['is_root'] <- rep(0, nrow(term))

relationships <- c('relationship', 'external')
term['is_relationsip'] <- ifelse(term$term_type %in% relationships, 1, 0)


## Create term2term table

is_a <- kv[kv$key == 'is_a',]
colnames(is_a) <- c('term1', 'relationship', 'term2')

relations <- kv[kv$key == 'relationship',][-2]
relations <- tidyr::separate(relations, value, c('V2', 'V3'), sep = " ")
colnames(relations) <- c('term1_id', 'relationship_type_id', 'term2_id')

rbind(is_a, relations)

relations[[1]] <- match(relations[[1]], names)
relations[[2]] <- match(relations[[2]], names)
relations[[3]] <- match(relations[[3]], names)

term2term <- relations
term2term['id'] <- seq_along(nrow(term2term))
term2term['complete'] <- 0
term2term <- term2term[c(4, 2, 1, 3, 5)]



## term_synonym.txt

alt_id <- kv[kv$key == 'alt_id',]

synonym <- kv[kv$key == 'synonym',]
synonyms <- toupper(synonyms)
by_synonym <- lapply(synonyms, function(s) {
    val <- synonym[grep(s, synonyms),]$value
    
})
names(by_synonym) <- synonym

term2synonym <- synonyms[c(1, 2, 3, 5, 4)]
    


## term_definition.txt

def <-  kv[kv$key == 'relationship',][-2]
colnames(def) <- c('term_id', 'term_definition')
def[[1]] <- match(def[[1]], names)

comment <- kv[kv$key == 'relationship',][-2]
colnames(comment) <- c('term_id', 'term_comment')
comment[[1]] <- match(comment[[1]], names)

term_definition <- dplyr::left_join(def, comment)

term_definition['dbx_ref_id'] <- '\\N'
term_definition['reference'] <- '\\N'

term_definition <- term_definition[c(1, 2, 4, 3, 5)]

## graph_path.txt


V <- as.character(seq_along(names))
E <- with(term2term, split(term1_id, term2_id))
gg <- graphNEL(V, E, "directed")

tc <- RBGL::transitive.closure()
