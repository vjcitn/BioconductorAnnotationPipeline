### Create 4 tab files: 'gene_cytogenetic.tab', 'gene_chromosome.tab',
### 'gene_synonym.tab' and 'gene_dbXrefs.tab'

read1 <-
    function(con, what, nrows)
{
    read.table(
        con, header = FALSE, colClasses = what, nrows = nrows,
        sep="\t", stringsAsFactors=FALSE, quote="", comment.char="",
    )
}

write1 <-
    function(con, key, value)
{
    key <- rep(key,lengths(value))
    line <- paste(key, unlist(value), sep="\t")
    writeLines(line, con)
}

splitStrUtil <- function() {
    fin <- file("gene_info", "r")

    output_files <- c(
        "gene_cytogenetic.tab", "gene_chromosome.tab", "gene_synonym.tab",
        "gene_dbXrefs.tab"
    )
    names(output_files) <- output_files
    fout <- lapply(output_files, file, "w")

    on.exit({
        close(fin)
        for (f in fout)
            close(f)
    })

    what <- rep("NULL", 13)
    what[c(2, 5:8)] <- "character"

    repeat {
        data <- tryCatch(read1(fin, what, 10000), error = identity)
        if (is(data, "error"))
            break

        key <- data[[1]]

        value <- strsplit(data[[2]], "[ ]*\\|[ ]*")
        write1(fout[["gene_synonym.tab"]], key, value)

        value <- strsplit(data[[3]], "[ ]*\\|[ ]*")
        write1(fout[["gene_dbXrefs.tab"]], key, value)

        value <- strsplit(data[[4]], "[ ]*\\|[ ]*")
        write1(fout[["gene_chromosome.tab"]], key, value)

        value <- strsplit(
            data[[5]], "( and )|( or )|([ ]*;[ ]*)|([ ]*,[ ]*)|([ ]*\\|[ ]*)",
        )
        write1(fout[["gene_cytogenetic.tab"]], key, value)
    }

    NULL
}

system.time({
    splitStrUtil( )
})
gc()
