crud_clone <- function(id, conn, modal_trigger, trigger_name) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    observeEvent(modal_trigger(), {
      # req(id %in% session$userData$collection_admin)
      showModal(modalDialog(
        size = "l",
        title = "Clone Entry",
        tagList(
          h1("The cloned entry will be inserted at the end.")
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("clone"), "Clone", class = "btn-secondary")
        )
      ))
    })

    observeEvent(input$clone, {
      tryCatch({

        query <- sprintf('{"_id": {"$oid":"%s"}}', modal_trigger())
        df <- conn$find(query)
        conn$insert(df)

        session$userData[[trigger_name]](session$userData[[trigger_name]]() + 1)

      }, error = function(e) {
        showNotification("Error Clone", type = "error")
      })

      removeModal()
    })

  })
}
