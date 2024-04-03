labmeetingUI <- function(id) {
  ns <- NS(id)
  card(height = 750,
    DTOutput(ns("DT")) %>% withSpinner()
  )
}

labmeetingServer <- function(id) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    conn <- mongo(collection = "lab_meeting", db = "siii612_co", url = url, options = ssl_options(weak_cert_validation = TRUE))

    lab_meeting <- reactivePoll(1000, session,
      checkFunc = function() {
        conn$find()
      },
      valueFunc = function() {
        conn$find(sort = '{"Date": 1}')
      }
    )

    output$DT <- renderDT({
      datatable(lab_meeting(),
        selection = "none",
        options = list(
          dom = "frt",
          pageLength = -1,
          order = list(1, 'desc'),
          columnDefs = list(
            list(orderable = FALSE, targets = c(2:4)),
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