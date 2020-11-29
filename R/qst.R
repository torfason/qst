#' Store Tables in SQL Database
#'
#' @description
#'
#' This package provides functions for quickly writing (and reading)
#' back a `data.frame` to file in `sqlite` format. The name stands
#' for *Store Tables using SQLite'*, or alternatively for *Quick
#' Store Tables* (either way, it could be pronounced as *Quest*).
#'
#' For `data.frames` containing the supported data
#' types it is intended to work as a drop-in replacement for the
#' `write_*()` and `read_*()` functions provided by packages such
#' as `fst`, `feather`, `qs`, and `readr` packages (as well as the
#' `writeRDS()` and `readRDS()` functions).
#'
#' @md
#' @docType package
#' @name qst
NULL


# An environment to store some global package configuration.
par.qst <- new.env()
par.qst$core_types <- c("integer", "numeric", "character")
par.qst$supported_types <- tibble(
  r   = c("integer", "numeric", "character", "Date", "POSIXct+POSIXt"),
  qst = c("integer", "numeric", "character", "date", "datetime"))
par.qst$singles_day <- data.frame(
  singles_character = "One",
  singles_integer   = 11L,
  singles_numeric   = 111.11,
  singles_date      = structure(18577, class = "Date"),
  singles_datetime  = structure(1605093071, class = c("POSIXct", "POSIXt"), tzone = "UTC"),
  singles_char_lab  = "One labelled"
)
attr(par.qst$singles_day$singles_char_lab,"label") <- "A single character value"
