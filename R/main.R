
# This is the base source file for the qst package


#' Write a data.frame to an SQLite database
#'
#' This function writes a data.frame to an SQLite database.
#' The database has one table, named data, containing the data.
#' Additional tables, prefixed with meta_, may be added in the
#' future to support additional data types not supported
#' in a native way by SQLite.
#'
#' @param x A data.frame to be written to file. Supported
#'   column types are integer, numeric and character.
#'
#' @param path The path to write to.
#'
#' @param ... Other parameters passed to methods.
#'
#' @param unique_indexes A list of character vectors.
#'   Each element of the list will create a new unique
#'   index over the specified column(s). Duplicate rows
#'   will result in failure.
#'
#' @param indexes A list of character vectors. Each
#'   element of the list will create a new index.
#'
#' @return The original data frame passed in x
#'
#' @examples
#' # Write the cars data set to a file
#' cars_db <- tempfile()
#' write_qst(cars, cars_db, indexes=list("speed"))
#' unlink(cars_db)
#'
#' @export
write_qst = function(x, path, ..., unique_indexes=NULL, indexes=NULL)
{
    if ( !is.data.frame(x) ) {
        stop("`x` must be a data frame", call. = FALSE)
    }
    v.classes = x %>%  sapply(class) %>% unlist() %>% unique()
    all_types_supported = v.classes %in% c("integer", "numeric", "character")  %>% all()
    if ( !all_types_supported ) {
        stop(paste("`x` must only contain columns of type integer, numeric or character. It contains ",
                   paste(v.classes, collapse=", " )))
    }
    if (file.exists(path)) file.remove(path)
    con <- DBI::dbConnect(RSQLite::SQLite(), path)
    on.exit(DBI::dbDisconnect(con))
    dplyr::copy_to(con, x, "data", temporary=FALSE, overwrite=TRUE,
                       unique_indexes=unique_indexes, indexes=indexes)
    invisible(x)
}


#' Read a data.frame from an SQLite database
#'
#' @description
#'
#' This function reads a data.frame from an SQLite database.
#' The database has one table, named data, containing the data.
#' Additional tables, prefixed with meta_, may be added in the
#' future to support additional data types not supported
#' in a native way by SQLite.
#'
#' By specifying lazy=TRUE, the data.frame will not be read into
#' memory on the read operation, but instead a lazy
#' evaluated data.frame will be returned. This results in a
#' near-instantaneous read operation, but subsequent operation
#' will then be done from disk using SQL translation when the
#' data.frame is passed to other functions or collect() is
#' called on it.
#'
#' @param path The path to read from.
#'
#' @param lazy If TRUE, the full data.frame will not be read into
#'   memory, but instead a lazy evaluated data.frame will
#'   be returned.
#'
#' @return A data.frame read from the SQLite file found at path
#'
#' @examples
#' # Write the cars data set to a file, then read it back
#' cars_db <- tempfile()
#' write_qst(cars, cars_db, indexes=list("speed"))
#' dat <- read_qst(cars_db)
#' unlink(cars_db)
#'
#' @importFrom dbplyr escape
#' @export
read_qst <- function(path, lazy=FALSE)
{
    con <- DBI::dbConnect(RSQLite::SQLite(), path)
    data = dplyr::tbl(con, "data")

    # Collect results unless lazy is TR
    if (!isTRUE(lazy)) {
      # This should be switched to a custom qst::collect method
      data <- dplyr::collect(data)
      on.exit(DBI::dbDisconnect(con))
    }

    return(data)
}
