crud_edit <- function(id, conn, modal_trigger, trigger_name, modal_body =...) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    observeEvent(modal_trigger(), {
      # req(id %in% session$userData$collection_admin)
      showModal(modalDialog(
        size = "l",
        title = "Edit Entry",
        modal_body,
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("update"), "Update", class = "btn-primary")
        )
      ))
    })

    observeEvent(input$update, {
      showNotification("nothing happend")
      # tryCatch({

      #   query <- sprintf('{"_id": {"$oid":"%s"}}', modal_trigger())
      #   df <- conn$find(query)
      #   conn$insert(df)

      #   session$userData[[trigger_name]](session$userData[[trigger_name]]() + 1)

      # }, error = function(e) {
      #   showNotification("Error Clone", type = "error")
      # })

      # removeModal()
    })


    # observeEvent(input$id_to_edit, {
    #   showModal(modalDialog(
    #     size = "l",
    #     title = "Edit Entry",
    #     tagList(
    #       "sjdklf", "79878"
    #     ),
    #     footer = tagList(
    #       modalButton("Cancel"),
    #       actionButton(ns("update"), "Update", class = "btn-success")
    #     )
    #   ))
    # })

    # observeEvent(input$update, {
    #   query <- sprintf('{"_id": {"$oid":"%s"}}', input$id_to_edit)
    #   update <- sprintf('{"$set": {"JC": "%s"}}', "123")
    #   conn$update(query, update)
    #   removeModal()
    # })



  })
}
