libraryUI <- function(id) {
  ns <- NS(id)
  layout_sidebar(padding = 0,
    sidebar = sidebar(open = "always", position = "right", width = 180,
      value_box(
        title = "Total",
        value = textOutput(ns("total_value")),
        showcase = bs_icon("mortarboard-fill"),
        showcase_layout = "top right",
        theme = "blue"
      ),
      value_box(
        title = "JC",
        value = textOutput(ns("jc_value")),
        showcase = bs_icon("eyeglasses"),
        showcase_layout = "top right",
        theme = "teal"
      )
    ),
    layout_columns(col_widths = c(2, 2, -6, 2, 12),
      actionButton(ns("add"), "Add"),
      actionButton(ns("delete"), "Delete", class = "btn-danger"),
      actionButton(ns("jc_mark"), "JC Mark"),
      card(height = 600,
        DTOutput(ns("DT")) %>% withSpinner()
      )
    )
  )
}

libraryServer <- function(id) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    conn <- mongo(collection = "library", db = "siii612_co", url = url, options = ssl_options(weak_cert_validation = TRUE))

    lib <- reactivePoll(1000, session,
      checkFunc = function() {
        conn$find()
      },
      valueFunc = function() {
        conn$find()
      }
    )

    observeEvent(input$add, {
      showModal(modalDialog(
        title  = "Add to library",
        tagList(
          textInput(ns("doi"), "DOI", value = ""),
          "It will take some time after clicking the 'Add' button, please do not click repeatedly until you see any message."
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("add_submit"), "Add", class = "btn-success")
        )
      ))
    })

    observeEvent(input$add_submit, {
      doi <- input$doi
      if (!nchar(doi) > 0) {
        showNotification("Please fill in DOI", type = "error")
      } else {
        if ((!doi %in% conn$find()$DOI)) {
          tryCatch({
            data <- cr_works(dois = doi)$data
            new_row <- data.frame(check.names = FALSE, stringsAsFactors = FALSE,
              Index = nrow(conn$find()) + 1,
              Title = data$title,
              Journal = ifelse("container.title" %in% names(data), data$container.title, "not found"),
              Tags = "",
              DOI = doi,
              "Time Added" = Sys.time(),
              "Added by" = session$userData$user_en,
              JC = "-"
            )
            conn$insert(as.data.frame(new_row))
            showNotification("Paper +1 !", type = "message")
            removeModal()
          }, warning  = function(w) {
            showNotification("Sorry, this DOI couldn't be found in CrossRef", type = "error")
          })
        } else {
          showNotification("This paper is already in the library", type = "error")
        }
      }
    })

    observeEvent(input$delete, {
      showModal(modalDialog(
        title = "Delete",
        tagList(
          textInput(ns("index_num_to_delete"), "Index number")
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("delete_submit"), "Delete", class = "btn-danger")
        )
      ))
    })

    observeEvent(input$delete_submit, {
      index_num <- input$index_num_to_delete
      if (!nchar(index_num) > 0) {
        showNotification("Please fill in the Index number", type = "error")
      } else {
        index_num <- as.numeric(index_num)
        if (is.na(index_num)) {
          showNotification("Index number is not a number", type = "error")
        } else if (!(index_num %% 1 == 0 && index_num >= 1 && index_num <= nrow(conn$find()))) {
          showNotification("Index number is invalid", type = "error")
        } else {
          query <- sprintf('{"Index": %d}', index_num)
          entry_added_by <- conn$find(query)$`Added by`
          if (entry_added_by != session$userData$user_en) {
            showNotification("You can't delete someone's entry.", type = "error")
          } else {
            conn$remove(query)
            removeModal()
            showNotification("You deleted one entry.", type = "default")
          }

        }
      }
    })

    observeEvent(input$jc_mark, {
      showModal(modalDialog(
        title = "JC Mark",
        tagList(
          textInput(ns("index_num"), "Index number"),
          selectInput(ns("jc_person"), "Mark", choices = c(Choose = "", "-", session$userData$members$name_en))
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("jc_mark_submit"), "Mark", class = "btn-success")
        )
      ))
    })

    observeEvent(input$jc_mark_submit, {
      index_num <- input$index_num
      jc_person <- input$jc_person
      if (!nchar(index_num) > 0 || !nchar(jc_person) > 0) {
        showNotification("Please fill in all fields", type = "error")
      } else {
        index_num <- as.numeric(index_num)
        if (is.na(index_num)) {
          showNotification("Index number is not a number", type = "error")
        } else if (!(index_num %% 1 == 0 && index_num >= 1 && index_num <= nrow(conn$find()))) {
          showNotification("Index number is invalid", type = "error")
        } else {
          query <- sprintf('{"Index": %d}', index_num)
          update <- sprintf('{"$set": {"JC": "%s"}}', jc_person)
          conn$update(query, update)
          removeModal()
          showNotification("JC Mark", type = "message")
        }
      }
    })

    output$total_value <- renderText({
      nrow(lib())
    })

    output$jc_value <- renderText({
      sum(lib()$JC != "-")
    })

    output$DT <- renderDT({
      datatable(lib(),
        rownames = FALSE,
        selection = "none",
        options = list(
          dom = "frt",
          pageLength = -1,
          order = list(5, 'desc'),
          columnDefs = list(
            list(orderable = FALSE, targets = c(0:4, 6:7)),
            list(targets = 4, render = JS("
              function(data, type, full, meta) {
                if (data.startsWith('http')) {
                  return '<a href=\"' + data + '\" target=\"_blank\">' + data + '</a>';
                } else {
                  return '<a href=\"https://doi.org/' + data + '\" target=\"_blank\">' + data + '</a>';
                }
              }
            ")),
            list(targets = 5, render = JS("
              function(data, type, row, meta) {
                return new Date(data).toLocaleString();
              }
            "))
          )
        )
      )
    })

  })
}