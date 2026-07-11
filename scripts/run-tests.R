#!/usr/bin/env Rscript
# Run the testthat suite. With no args, runs the whole __tests__ dir; with a
# file path arg (after `--` when invoked via `uvr run`), runs just that file.

args <- commandArgs(trailingOnly = TRUE)

if (length(args) > 0) {
  testthat::test_file(args[[1]])
} else {
  testthat::test_dir("src/package_name/__tests__")
}
