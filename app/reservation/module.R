reservationUI <- function(id) {
  ns <- NS(id)
  layout_columns(col_widths = c(6, 6),
    calUI(ns("bsc_1")),
    calUI(ns("bsc_2"))
  )
}

reservationServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    calServer("bsc_1")
    calServer("bsc_2")
  })
}

calUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      id,
      actionLink(ns("refresh"), "Refresh", icon = icon("arrows-rotate"))
    ),
    calendarOutput(ns("cal"), height = "600px")
  )
}

calServer <- function(id) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    conn <- mongo(collection = "bsc_reservation", db = "siii612_co", url = url, options = ssl_options(weak_cert_validation = TRUE))

    query <- sprintf('{"calendarId": "%s"}', id)

    cal_df <- reactive({
      input$refresh
      input$create
      input$cal_delete
      dat <- conn$find(query)
      return(dat)
    })

    output$cal <- renderCalendar({
      cal_df() %>%
        calendar(
          view = "week",
          navigation = TRUE,
          useDetailPopup = TRUE,
          isReadOnly = FALSE
        ) %>%
        cal_week_options(
          eventView = c("time"),
          taskView = FALSE
        ) %>%
        cal_events(
          selectDateTime = JS(sprintf("function(info) {Shiny.setInputValue('reservation-%s-selection', info);}", id))
        )
    })

    observeEvent(input$selection, {
      showModal(modalDialog(
        size = "l",
        title = "Reservation",
        tagList(
          tags$p(tags$b(session$userData$user_zh)),
          "from",
          tags$b(with_tz(as_datetime(input$selection$start), "Asia/Shanghai")),
          " to ",
          tags$b(with_tz(as_datetime(input$selection$end), "Asia/Shanghai")),
          "?"
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("create"), "Yes", class = "btn-success")
        )
      ))
      cal_proxy_clear_selection("cal")
    })

    observeEvent(input$create, {
      conn$insert(data.frame(
        id = conn$find(sort = '{"id": -1}', limit = 1)$id + 1,
        calendarId = id,
        start = with_tz(as_datetime(input$selection$start), "Asia/Shanghai"),
        end = with_tz(as_datetime(input$selection$end), "Asia/Shanghai"),
        title = session$userData$user_zh
      ))
      removeModal()
    })

    observeEvent(input$cal_delete, {
      entry_title <- conn$find(sprintf('{"id": %d}', as.double(input$cal_delete$id)))$title
      if (entry_title != session$userData$user_zh) {
        showNotification("You can't delete someone's reservation.", type = "error")
      } else {
        conn$remove(sprintf('{"id": %d}', as.double(input$cal_delete$id)))
        cal_proxy_delete("cal", input$cal_delete)
      }
    })

  })
}