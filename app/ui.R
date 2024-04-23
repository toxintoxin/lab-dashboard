ui <- page_fluid(
  title = "SIII 612 Lab Dashboard",
  navlistPanel(widths = c(2, 10),
    "SIII 612 Lab Dashboard",
    tabPanel("Home",
      layout_columns(
        col_widths = c(8, 4, 4, 8, 12, 12),
        row_heights = c(4, 2, 2, 1),
        card(
          h1("intro")
        ),
        card(
          img(src = "group_photo.jpg")
        ),
        card(
          h4("Hello")
        ),
        card(
          h4("something")
        ),
        card(
          h4("NEWS")
        ),
        card()
      )
    ),
    tabPanel("Lab meeting", labmeetingUI("labmeeting")),
    tabPanel("Library", libraryUI("library")),
    "Routine",
    tabPanel("Routine of FSH group", routineUI("fsh")),
    tabPanel("Reservation for bsc", reservationUI("reservation")),
    "Contact",
    tabPanel("Members", membersUI("members")),
    "Database",
    tabPanel("Lipid", dbUI("lipid")),
    tabPanel("Antibody", dbUI("antibody")),
    "Test Panels",
    tabPanel("person CRUD test", crudDTOutput("person"))
  )
)

ui <- secure_app(
  ui = ui,
  head_auth = tagList(
    tags$link(rel = "shortcut icon", href = "favicon.ico"),
    tags$link(rel="stylesheet", href="https://cdn.staticfile.org/font-awesome/4.7.0/css/font-awesome.css"),
    tags$style(HTML("
    
    ")),
    tags$title("SIII 612 Lab Dashboard"),  # this title was showed when login
    useShinyjs()
  ),
  fab_position = "bottom-left"
)