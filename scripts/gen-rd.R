#!/usr/bin/env Rscript
# Generates .Rd files from box modules using box's own internal doc-parsing
# pipeline (box:::parse_documentation) - the same one box::help() uses. Feeds
# rd2qmd, which converts them to .md for docs/_quarto.yml (see justfile's
# docs-build recipe).

src_dir <- "src/package_name"
out_dir <- "man"

unlink(out_dir, recursive = TRUE)
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

r_files <- list.files(src_dir, pattern = "\\.r$", full.names = TRUE)
r_files <- r_files[basename(r_files) != "__init__.r"] # re-export wiring, no real docs

parse_documentation <- getNamespace("box")$parse_documentation

for (f in r_files) {
  mod_name <- sub("\\.r$", "", basename(f))
  cat("Processing module:", mod_name, "\n")

  info <- list(name = mod_name, source_path = normalizePath(f))
  class(info) <- c("box$mod_info", "box$info")

  mod_ns <- new.env(parent = globalenv())
  ns_attr <- new.env(parent = emptyenv())
  ns_attr$info <- info
  mod_ns$.__module__. <- ns_attr # box::make_namespace() does this before sourcing

  sys.source(f, envir = mod_ns, keep.source = TRUE)

  docs <- parse_documentation(info, mod_ns)

  for (topic in names(docs)) {
    fname <- if (topic == ".__module__.") {
      paste0(mod_name, "-module.Rd")
    } else {
      paste0(topic, ".Rd")
    }
    writeLines(docs[[topic]], file.path(out_dir, fname))
    cat("  wrote:", fname, "\n")
  }
}
