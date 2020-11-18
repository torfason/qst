
# Packages
library(testthat)


# Test basic operation
test_that("qst works",{
  cars_db <- tempfile()
  teardown(unlink(cars_db))
  cars_compare <- tibble::as_tibble(cars)
  write_qst(cars, cars_db)
  cars_roundtrip <- read_qst(cars_db)
  expect_equal(cars_roundtrip, cars_compare)
})


# Test operation in delayed mode
test_that("qst works in delayed mode",{
  cars_db <- tempfile()
  teardown(unlink(cars_db))
  cars_compare <- tibble::as_tibble(cars)
  write_qst(cars, cars_db)
  cars_roundtrip <- read_qst(cars_db, lazy=TRUE)
  teardown(DBI::dbDisconnect(cars_roundtrip$src$con))
  expect_equal(dplyr::collect(cars_roundtrip), cars_compare)
})


# Test usage when writing indexes
test_that("indexes work",{
  cars_db <- tempfile()
  teardown(unlink(cars_db))
  cars_compare <- tibble::as_tibble(cars)
  write_qst(cars, cars_db, indexes=list("speed"))
  cars_roundtrip <- read_qst(cars_db, lazy=TRUE)
  teardown(DBI::dbDisconnect(cars_roundtrip$src$con))
  expect_equal(dplyr::collect(cars_roundtrip), cars_compare)
})


# Test that unique indexes trigger errors
test_that("unique indexes trigger error on insert",{
  cars_db <- tempfile()
  teardown(unlink(cars_db))
  expect_error(write_qst(cars, cars_db, unique_indexes=list("speed")))
})
