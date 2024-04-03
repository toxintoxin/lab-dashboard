server <- function(input, output, session) {

  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )

  observe({
    user_info <- reactiveValuesToList(res_auth)
    req(length(user_info) != 0)
    session$userData$user_en <- user_info$name_en
    session$userData$user_zh <- user_info$name_zh
    showNotification(paste0("Welcome back! ", session$userData$user_zh), type = "message")
  })

  session$userData$members <- credentials %>% dplyr::select(c("name_en", "phone", "email"))
  libraryServer("library")

  membersServer("members")

  labmeetingServer("labmeeting")

  reservationServer("reservation")
  routineServer("fsh")
  dbServer("lipid")
  dbServer("antibody")
  crudDT("person", "siii612_co")
}