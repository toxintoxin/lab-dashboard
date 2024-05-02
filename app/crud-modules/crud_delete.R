crud_delete <- function(id, conn, modal_trigger, trigger_name) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    observeEvent(modal_trigger(), {
      # req(id %in% session$userData$collection_admin)
      showModal(modalDialog(
        size = "l",
        title = "Delete Entry",
        tagList(
          h1("Please note that this is irrevocable!"),
          textInput(
            ns("delete_verify"),
            label = paste0("Type \"", modal_trigger(), "\" to delete the entry"),
            width = "100%"
          )
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("delete"), "Delete", class = "btn-danger")
        )
      ))
    })

    observeEvent(input$delete, {
      if (input$delete_verify != modal_trigger()) {
        showNotification("id is wrong", type = "error")
      } else {
        tryCatch({

          query <- sprintf('{"_id": {"$oid":"%s"}}', modal_trigger())
          conn$remove(query)

          session$userData[[trigger_name]](session$userData[[trigger_name]]() + 1)

        }, error = function(e) {
          showNotification("Error Delete", type = "error")
        })

        removeModal()
      }
    })

  })
}
