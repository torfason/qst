#' Prepare list of tables for writing wrapped types.
#'
#' Wrap the types in a data.frame into a list of data.frames
#' where only numeric and character types are present.
#'
#' @param x A data.frame containing any supported data types.
#' @return A list of tables with wrapped types
#' @examples
#' # Wrap types for data.frame with current date
#' qst:::wrap_types(data.frame(v1=Sys.Date()))
#' @noRd
wrap_types <- function(x) {

  # Sanity checks: Is x a data.frame
  if ( !is.data.frame(x) ) {
      stop("`x` must be a data frame", call. = FALSE)
  }
  x <- tibble::as_tibble(x)

  # Create tables to wrap the type info
  meta_vars <- x %>%
    sapply(class) %>%
    sapply(paste, collapse="+") %>%
    tibble::enframe(name="name", value="type")

  # Add any labels to metadata
  var_labels <- sapply(x, attr, which="label", exact=TRUE)
  var_labels[sapply(var_labels,is.null)] <- NA
  stopifnot(all(sapply(var_labels, length)==1))
  var_labels <- unname(unlist(var_labels))
  meta_vars$label <- var_labels

  # Sanity checks: Only accept supported data types
  supported_types <- par.qst$supported_types$r
  if ( !all(meta_vars$type %in% supported_types) ) {
    stop(paste("`x` must only contain columns of the following types: \n    [",
               paste(supported_types,collapse=", "), "]. \n",
               "It contains variables of type \n    [",
               paste(setdiff(unique(meta_vars$type), supported_types), collapse=", " ), "]."))
  }

  # Process any types that need processing
  cols_date     <- meta_vars$name[meta_vars$type == "Date"]
  cols_datetime <- meta_vars$name[meta_vars$type == "POSIXct+POSIXt"]
  x <- x %>%
    dplyr::mutate(dplyr::across(dplyr::all_of(cols_date), as.character)) %>%
    dplyr::mutate(dplyr::across(dplyr::all_of(cols_datetime), as.character))

  # Replace the native representation of the types with the qst representation
  # For now, we do each type manually, even if a lookup would be nicer
  meta_vars$type[meta_vars$type=="Date"] = "date"
  meta_vars$type[meta_vars$type=="POSIXct+POSIXt"] = "datetime"

  # By now, the only acceptable types are the core types,
  # integer, numeric and character
  stopifnot( sapply(x,class) %in% par.qst$core_types )

  # Return the result
  list(data=x, meta_vars=meta_vars)
}
