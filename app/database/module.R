dbUI <- function(id) {
  ns <- NS(id)
  tagList(
    DTOutput(ns("DT")) %>% withSpinner(),
  )
}

dbServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    conn <- mongo(collection = paste0("database_", id), db = "siii612_co", url = url, options = ssl_options(weak_cert_validation = TRUE))
    df <- conn$find()
    output$DT <- renderDT({
      datatable(df)
    })
  })
}