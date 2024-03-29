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
  # Prepare the list to write
  wrapped <- wrap_types(x)

  # Write the wrapped tables, first the data, then any meta tables
  # the meta_vars table is required
  if (file.exists(path)) file.remove(path)
  con <- DBI::dbConnect(RSQLite::SQLite(), path)
  on.exit(DBI::dbDisconnect(con))
  dplyr::copy_to(con, wrapped$data, "data", temporary=FALSE, overwrite=TRUE,
                     unique_indexes=unique_indexes, indexes=indexes)
  dplyr::copy_to(con, wrapped$meta_vars, "meta_vars", temporary=FALSE, overwrite=TRUE)

  # Return the original, in line with other write_*() functions
  invisible(x)
}
