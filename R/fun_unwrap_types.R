#' Unwrap a list of tables with wrapped types
#'
#' Unwrap a list of tables with wrapped types
#' (where only numeric and character types are present),
#' into a regular data.frame that may contain any of the
#' supported types
#'
#' @param l A list of tables with wrapped types
#' @return The original data.frame represented by l
#' @examples
#' # Wrap types for data.frame with current date
#' qst:::unwrap_types(qst:::wrap_types(data.frame(v1=Sys.Date())))
#' @noRd
unwrap_types <- function(l) {

  # Prepare the result. This function should only be called
  # with data produced by read_qst(), so detailed sanity
  # checking is needed. We assume data integrity or crash and burn.
  x <- l$data
  meta_vars <- l$meta_vars

  # Process any types that need processing. Note that here we process
  # according to the qst representation of types, not R native types
  cols_date <- meta_vars$name[meta_vars$type == "date"]
  cols_datetime <- meta_vars$name[meta_vars$type == "datetime"]
  x <- x %>%
    dplyr::mutate(dplyr::across(dplyr::all_of(cols_date), as.Date)) %>%
    dplyr::mutate(dplyr::across(dplyr::all_of(cols_datetime), strptime, "%Y-%m-%d %H:%M:%S"))

  # Assign any variable labels found in the wrapped list
  vars_with_labels <- meta_vars$name[!is.na(meta_vars$label)]
  for ( cur_col in vars_with_labels ) {
    attr(x[[cur_col]],"label") <- meta_vars$label[meta_vars$name==cur_col]
  }

  # Return the result
  x
}
