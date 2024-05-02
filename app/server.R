server <- function(input, output, session) {

  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )

  observe({
    user_info <- reactiveValuesToList(res_auth)
    req(length(user_info) != 0)
    session$userData$nickname <- user_info$nickname
    session$userData$display_name <- user_info$display_name
    session$userData$read <- user_info$read
    session$userData$readWrite <- user_info$readWrite
    showNotification(paste0("Welcome back! ", session$userData$display_name), type = "message")
  })

  session$userData$members <- credentials %>% dplyr::select(c("nickname", "phone", "email"))
  crudServer(
    id = "library_tags",
    db = "siii612_co",
    modal_body_edit = tagList(
      textInput("library_tags-word", label = "word"),
      colorPickr("library_tags-color", label = "color", selected = "#ff0000")
    )
  )
  libraryServer("library")

  membersServer("members")

  labmeetingServer("labmeeting")

  reservationServer("reservation")
  routineServer("fsh")
  crudServer("db_lipid", "siii612_co")
  crudServer("db_antibody", "siii612_co")
  crudServer(
    id = "penguins",
    db = "siii612_co",
    modal_body_edit = tagList(h1("aaaaaaaaa"))
  )
}