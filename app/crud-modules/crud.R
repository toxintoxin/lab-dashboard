crudUI <- function(id, ...) {
  ns <- NS(id)
  tagList(
    wellPanel("query"),
    DTOutput(ns("DT"), ...) %>% withSpinner(),
    # should be after the DT
    tags$script(src = "crud_interactive.js"),
    tags$script(paste0("crud_interactive('", ns(''), "')"))
  )
}

crudServer <- function(id, db, modal_body_edit) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    db.id <- paste0(db, ".", id)

    # role of user
    read <- db.id %in% session$userData$read[[1]]
    readWrite <- db.id %in% session$userData$readWrite[[1]]

    # create connection
    conn <- NULL
    tryCatch({
      conn <- mongo(collection = id, db = db, url = url, options = ssl_options(weak_cert_validation = TRUE))
    }, error = function(e) {
      showNotification("Error:", "database connection fail, please check your internet or contact administrator", type = "error")
    })

    # trigger to reload data
    trigger_name <- paste0("crud_trigger", db.id)
    session$userData[[trigger_name]] <- reactiveVal(0)

    # read database
    dat <- reactive({

      session$userData[[trigger_name]]()

      df <- NULL
      tryCatch({
        df <- conn$find(fields = '{}')
      }, error = function(e) {
        showNotification("Error:", "database connection fail, please check your internet or contact administrator", type = "error")
      })
      return(df)
    })

    # table preparation
    table_prep <- reactiveVal(NULL)
    observeEvent(dat(), {

      out <- dat()

      # build buttons
      ids <- out$"_id"
      if (readWrite == FALSE) {
        actions <- purrr::map_chr(ids, function(id) {
          paste0(
            '<div class="btn-group" style="width: 75px;" role="group" aria-label="Basic example">
              <button class="btn btn-warning btn-sm" id = ', id, ' style="margin: 0">readOnly</button>
            </div>'
          )
        })
      } else if (readWrite == TRUE) {
        actions <- purrr::map_chr(ids, function(id) {
          paste0(
            '<div class="btn-group" style="width: 75px;" role="group" aria-label="Basic example">
              <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Edit" id = ', id, ' style="margin: 0"><i class="fa fa-pencil"></i></button>
              <button class="btn btn-secondary btn-sm clone_btn" data-toggle="tooltip" data-placement="top" title="Clone" id = ', id, ' style="margin: 0"><i class="fa fa-clone"></i></button>
              <button class="btn btn-danger btn-sm delete_btn" data-toggle="tooltip" data-placement="top" title="Delete" id = ', id, ' style="margin: 0"><i class="fa fa-trash"></i></button>
            </div>'
          )
        })
      }

      # set the actions to the last column of the table
      out <- cbind(out, data.frame("Actions" = actions))

      # logic
      if (is.null(table_prep())) {
        # loading data into the table for the first time, so we render the entire table
        # rather than using a DT proxy
        table_prep(out)
      } else {
        # table has already rendered, so use DT proxy to update the data in the
        # table without rerendering the entire table
        replaceData(DT_proxy, out, resetPaging = FALSE)
      }

    })

    # DT render
    output$DT <- renderDT(# server = FALSE,  # The key to whether the download button downloads only the current row or all rows. 
    {
      req(table_prep())
      table_to_render <- table_prep()

      datatable(
        data = table_to_render,
        escape = FALSE,  # The key to render the html buttons.
        selection = "none",
        extensions = c("Buttons"),
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
            ),
                      list(
                        extend = "excel",
                        text = "Download",
                        title = NULL,
                        exportOptions = list(
                          columns = 1:(ncol(table_to_render) - 1),
                          modifier = list(page = "all")
                        )
                      )
          )
        )
      )
    })

    # create proxy
    DT_proxy <- dataTableProxy("DT")

    # edit
    crud_edit(
      id = NULL,
      conn = conn,
      modal_trigger = reactive({input$id_to_edit}),
      trigger_name = trigger_name,
      modal_body = modal_body_edit
    )

    # clone
    crud_clone(
      id = NULL,
      conn = conn,
      modal_trigger = reactive({input$id_to_clone}),
      trigger_name = trigger_name
    )

    # delete
    crud_delete(
      id = NULL,
      conn = conn,
      modal_trigger = reactive({input$id_to_delete}),
      trigger_name = trigger_name
    )

  })
}
