library(shiny)
library(DT)
library(shinyjs)
library(bslib)
library(bsicons)
library(shinycssloaders)
library(rcrossref)
library(mongolite)
library(tidyr)
library(dplyr)
library(toastui)
library(lubridate)
library(shinymanager)

Sys.setenv(TZ = "Asia/Shanghai")

source("library/module.R")
source("members/module.R")
source("labmeeting/module.R")
source("reservation/module.R")
source("routine/module.R")
source("database/module.R")

source("crud-modules/crud.R")
source("crud-modules/crud_edit.R")
source("crud-modules/crud_clone.R")
source("crud-modules/crud_delete.R")

mongodb <- config::get()$mongodb

url <- sprintf(
  "mongodb+srv://%s:%s@%s/",
  mongodb$username,
  mongodb$password,
  mongodb$host
)

credentials <- mongo(collection = "credentials", db = "shinyAccess", url = url, options = ssl_options(weak_cert_validation = TRUE))$find()
