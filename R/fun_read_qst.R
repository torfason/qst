



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
#' Note that types apart from the core types,
#' integer, numeric and character
#' are not currently supported with lazy=TRUE. They will be
#' converted to the core types with a warning.
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
    meta_vars = dplyr::tbl(con, "meta_vars")

    # Collect results unless lazy is TR
    if (!isTRUE(lazy)) {
      # This should be switched to a custom qst::collect method
      data <- dplyr::collect(data)
      meta_vars <- dplyr::collect(meta_vars)
      on.exit(DBI::dbDisconnect(con))

      # Call the unwrap function to replace core types with any
      # of the supported types
      data <- unwrap_types(list(data=data, meta_vars=meta_vars))
    }

    if (isTRUE(lazy) && !all(meta_vars$type %in% par.qst$core_types)) {
      warning("Note that lazy mode is not fully supported except for core types (numeric/integer/characters). ",
              "Other types will be silently converted to one of the core types. For full type support",
              "use lazy=FALSE.")
    }

    return(data)
}
