crudDTOutput <- function(id, ...) {
  ns <- NS(id)
  tagList(
    wellPanel("query"),
    DTOutput(ns("DT"), ...) %>% withSpinner(),
    tags$script(src = "DT_module.js"),
    tags$script(paste0("DT_module_js('", ns(''), "')"))
  )
}

crudDT <- function(id, db) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    # connection
    conn <- NULL
    tryCatch({
      conn <- mongo(collection = id, db = "siii612_co", url = url, options = ssl_options(weak_cert_validation = TRUE))
    }, error = function(e) {
      showNotification("Error:", "database connection fail, please check your internet or contact administrator", type = "error")
    })

    # build table
    table_build <- function() {
      # data
      df <- conn$find(fields = '{}')
      # build buttons
      ids <- df$"_id"
      actions <- purrr::map_chr(ids, function(id) {
        paste0(
          '<div class="btn-group" style="width: 100px;" role="group" aria-label="Basic example">
            <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Edit" id = ', id, ' style="margin: 0"><i class="fa fa-pencil"></i></button>
            <button class="btn btn-secondary btn-sm clone_btn" data-toggle="tooltip" data-placement="top" title="Clone" id = ', id, ' style="margin: 0"><i class="fa fa-clone"></i></button>
            <button class="btn btn-danger btn-sm delete_btn" data-toggle="tooltip" data-placement="top" title="Delete" id = ', id, ' style="margin: 0"><i class="fa fa-trash"></i></button>
          </div>'
        )
      })
      # set the actions to the last column of the table
      table <- cbind(df, dplyr::tibble("Actions" = actions))
      return(table)
    }

    # table
    table_rv <- reactiveVal(table_build())

    # DT render
    output$DT <- renderDT({
      datatable(
        table_build(),
        escape = FALSE,
        selection = "none",
        extensions = "Buttons",
        options = list(
          pageLength = 20,
          dom = "Biprt",
          buttons = list(
            list(
              extend = "collection",
              text = "<i class=' fa fa-copy'></i> test1",
              action = JS("function ( e, dt, node, config ) {
                                  alert( 'test1' );
                              }"),
              className = "btn-success"
            ),
            list(
              extend = "collection",
              text = "<i class='fas fa-file-excel'></i> Export",
              buttons = c('csv', 'excel', 'pdf'),
              className = "btn-default"
            )
          )
        )
      )
    })

    # edit
    observeEvent(input$id_to_edit, {
      showModal(modalDialog(
        size = "l",
        title = "Edit Entry",
        tagList(
          "sjdklf","79878"
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("update"), "Update", class = "btn-success")
        )
      ))
    })

    observeEvent(input$update, {
      query <- sprintf('{"_id": {"$oid":"%s"}}', input$id_to_edit)
      update <- sprintf('{"$set": {"JC": "%s"}}', "123")
      conn$update(query, update)
      removeModal()
    })

    # clone
    observeEvent(input$id_to_clone, {
      showModal(modalDialog(
        size = "l",
        title = "Insert Entry",
        tagList(
          "插入到最后"
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("insert"), "Insert", class = "btn-success")
        )
      ))
    })

    observeEvent(input$insert, {
      conn$insert(
        data.frame(
          
        )
      )
      removeModal()
    })

    # delete
    observeEvent(input$id_to_delete, {
      showModal(modalDialog(
        size = "l",
        title = "Delete Entry",
        tagList(
          h1("Please note that this is irrevocable!"),
          textInput(
            ns("delete_verify"),
            label = paste0("Type \"", input$id_to_delete, "\" to delete the entry"),
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
      if (input$delete_verify != input$id_to_delete) {
        showNotification("id is wrong", type = "error")
      } else {
        query <- sprintf('{"_id": {"$oid":"%s"}}', input$id_to_delete)
        conn$remove(query)
        DT::dataTableProxy("DT") %>% DT::replaceData(table_build())
        removeModal()
      }
    })

  })
}