membersUI <- function(id) {
  ns <- NS(id)
  card(height = 750,
    DTOutput(ns("DT")) %>% withSpinner()
  )
}

membersServer <- function(id) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    output$DT <- renderDT({
      datatable(
        data = session$userData$members,
        colnames = c("Name", "Phone", "Email"),
        selection = "none",
        options = list(
          dom = "rt",
          pageLength = -1
        )
      )
    })

  })
}