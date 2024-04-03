routineUI <- function(id) {
  ns <- NS(id)
  tagList(
    layout_columns(
      DTOutput(ns("wip")) %>% withSpinner(),
      DTOutput(ns("mycoplasma")) %>% withSpinner(),
      DTOutput(ns("fbsdeact")) %>% withSpinner()
    )
  )
}

routineServer <- function(id) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    conn <- mongo(collection = paste0("routine_", id), db = "siii612_co", url = url, options = ssl_options(weak_cert_validation = TRUE))

    dat <- reactivePoll(1000, session,
      checkFunc = function() {
        conn$find()
      },
      valueFunc = function() {
        conn$find(sort = '{"Date": 1}')
      }
    )

    output$wip <- renderDT({
      datatable(dat() %>% filter(item == "WorkInProgress") %>% pivot_wider(names_from = "item", values_from = "who"),
        selection = "none",
        options = list(
          dom = "frt",
          pageLength = -1,
          order = list(1, 'desc'),
          columnDefs = list(
            list(orderable = FALSE, targets = 2),
            list(targets = 1, render = JS("
              function(data, type, row, meta) {
                return new Date(data).toLocaleDateString();
              }
            "))
          )
        )
      )
    })

    output$mycoplasma <- renderDT({
      datatable(dat() %>% filter(item == "Mycoplasma") %>% pivot_wider(names_from = "item", values_from = "who"),
        selection = "none",
        options = list(
          dom = "frt",
          pageLength = -1,
          order = list(1, 'desc'),
          columnDefs = list(
            list(orderable = FALSE, targets = 2),
            list(targets = 1, render = JS("
              function(data, type, row, meta) {
                return new Date(data).toLocaleDateString();
              }
            "))
          )
        )
      )
    })

    output$fbsdeact <- renderDT({
      datatable(dat() %>% filter(item == "FBSdeactivate") %>% pivot_wider(names_from = "item", values_from = "who"),
        selection = "none",
        options = list(
          dom = "frt",
          pageLength = -1,
          order = list(1, 'desc'),
          columnDefs = list(
            list(orderable = FALSE, targets = 2),
            list(targets = 1, render = JS("
              function(data, type, row, meta) {
                return new Date(data).toLocaleDateString();
              }
            "))
          )
        )
      )
    })
  })
}