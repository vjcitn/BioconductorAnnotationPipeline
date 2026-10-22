# iceSurvey: a Shiny survey tool over the bioc-on-ice catalog.
#
# Milestone 11 ("BiocAnnoNG") proposes domain-specific routing and
# verification before any specific domain (GWAS, ontologies, cellxgene,
# ...) is picked up. This app is the survey step that comes before that
# choice: pick one of the catalog's resources, see what tables/columns it
# actually has, and preview rows via a parameterized LIMIT query -- so a
# domain gets picked from what's actually in the catalog, not a guess.

library(shiny)
library(DT)
library(DBI)
library(duckdb)

`%||%` <- function(a, b) if (is.null(a) || is.na(a)) b else a

.connect_ice <- function(endpoint = "https://icegate-bioconice.seandavi.workers.dev") {
    con <- DBI::dbConnect(duckdb::duckdb())
    DBI::dbExecute(con, "INSTALL iceberg; LOAD iceberg;")
    DBI::dbExecute(con, sprintf(
        "ATTACH 'bioconice' AS bioc (TYPE ICEBERG, ENDPOINT '%s', AUTHORIZATION_TYPE 'none');",
        endpoint
    ))
    con
}

# One connection and one table listing for the life of the app process --
# `SHOW ALL TABLES` is cheap and the catalog's resource list doesn't change
# within a session, so there is no need to re-query it per user action.
.con <- .connect_ice()
.resources <- DBI::dbGetQuery(.con, "SHOW ALL TABLES;")
.resources <- .resources[order(.resources$schema, .resources$name), ]
.resources$qualified <- paste0(.resources$schema, ".", .resources$name)

.choices <- split(.resources$qualified, .resources$schema)

ui <- fluidPage(
    titlePanel("iceSurvey -- bioc-on-ice resource browser"),
    sidebarLayout(
        sidebarPanel(
            selectInput("resource", sprintf("Resource (%d available)", nrow(.resources)),
                        choices = .choices),
            numericInput("limit", "LIMIT (rows to preview)", value = 20, min = 1, max = 5000),
            helpText("Schema/table come straight from the live catalog's own",
                     "SHOW ALL TABLES; nothing here is hardcoded."),
            width = 3
        ),
        mainPanel(
            h4("Columns"),
            DTOutput("columns"),
            h4("Preview"),
            DTOutput("preview"),
            width = 9
        )
    )
)

server <- function(input, output, session) {

    qualified_name <- reactive({
        req(input$resource)
        input$resource
    })

    schema_table <- reactive({
        parts <- strsplit(qualified_name(), ".", fixed = TRUE)[[1]]
        list(schema = parts[1], table = paste(parts[-1], collapse = "."))
    })

    columns <- reactive({
        st <- schema_table()
        ident <- DBI::dbQuoteIdentifier(.con, c("bioc", st$schema, st$table))
        sql <- sprintf("DESCRIBE %s;", paste(ident, collapse = "."))
        tryCatch(
            DBI::dbGetQuery(.con, sql),
            error = function(e) {
                validate(need(FALSE, paste("DESCRIBE failed:", conditionMessage(e))))
            }
        )
    })

    preview <- reactive({
        st <- schema_table()
        n <- max(1L, as.integer(input$limit %||% 20))
        ident <- DBI::dbQuoteIdentifier(.con, c("bioc", st$schema, st$table))
        sql <- sprintf("SELECT * FROM %s LIMIT %d;", paste(ident, collapse = "."), n)
        tryCatch(
            DBI::dbGetQuery(.con, sql),
            error = function(e) {
                validate(need(FALSE, paste("Query failed:", conditionMessage(e))))
            }
        )
    })

    output$columns <- renderDT({
        datatable(columns(), options = list(pageLength = 10, dom = "tip"), rownames = FALSE)
    })

    output$preview <- renderDT({
        datatable(preview(), options = list(pageLength = 20, scrollX = TRUE), rownames = FALSE)
    })

    session$onSessionEnded(function() {
        # Shared connection outlives any one session; nothing to disconnect here.
    })
}

shinyApp(ui, server)
