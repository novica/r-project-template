# Proposal: a batch counterpart to mod_rd() (see
# box-upstream-proposal-mod_rd.R) that discovers and loads every module in a
# directory and returns all of their Rd documentation in one call. This is
# what makes a project's own custom doc-generation script unnecessary
# entirely, rather than just removing its dependency on box internals.
#
# Written as box-internal code (unqualified calls to sibling internal
# functions), meant to be pasted into box's own source tree, not run
# standalone. `load_mod.box$mod_info()` (see R/load.r) is the key existing
# building block this relies on: unlike `box::use()`, it's already NSE-free
# — it loads a module from just an `info` object (name + source_path), doing
# everything box::use() does under the hood (namespace creation, sourcing,
# `.on_load` hook) without needing a literal module-path expression at the
# call site. That's what makes iterating over an arbitrary, discovered-at-
# runtime set of files possible at all.
#
# Suggested home: alongside `mod_rd()` in box's own R/help.r; add `mod_rd_dir`
# to NAMESPACE exports.
#
# To smoke-test outside box's package:
#   environment(mod_rd_dir) <- asNamespace("box")
#   mod_rd_dir("src/package_name")

#' Get Rd documentation for every module in a directory
#'
#' Discovers every `.R`/`.r` file in \code{dir_path}, loads each as a module,
#' and returns its Rd documentation source — the same data \code{mod_rd()}
#' returns for a single already-loaded module, but for every module in a
#' directory at once. Useful for generating a full API reference for a
#' project without hand-writing a discovery/load/extract loop against box's
#' internals.
#'
#' @param dir_path Path to a directory of module files.
#' @param pattern Regex matching module source files. Default matches `.R`
#'   and `.r` files.
#' @param exclude Optional regex (matched against the file's base name); any
#'   file it matches is skipped. Useful for excluding files that are only
#'   re-export wiring (e.g. `"^__init__\\.[Rr]$"`) and have no real
#'   documentation of their own.
#' @return A named list of named lists: one entry per module (named after
#'   the module, e.g. `"hello"`), each containing the same named list of Rd
#'   character vectors that \code{mod_rd()} returns for a single module.
#' @examples
#' \dontrun{
#' all_docs <- box::mod_rd_dir("src/mypackage")
#' for (mod_name in names(all_docs)) {
#'   for (topic in names(all_docs[[mod_name]])) {
#'     writeLines(all_docs[[mod_name]][[topic]], paste0("man/", topic, ".Rd"))
#'   }
#' }
#' }
#' @export
mod_rd_dir <- function(dir_path, pattern = "\\.[Rr]$", exclude = NULL) {
  if (!requireNamespace("roxygen2", quietly = TRUE)) {
    throw("mod_rd_dir() requires the 'roxygen2' package to be installed")
  }

  files <- list.files(dir_path, pattern = pattern, full.names = TRUE)
  if (!is.null(exclude)) {
    files <- files[!grepl(exclude, basename(files))]
  }

  mod_names <- sub(pattern, "", basename(files))

  docs <- lapply(seq_along(files), function(i) {
    info <- mod_info(list(name = mod_names[[i]]), normalizePath(files[[i]]))
    loaded <- load_mod(info)
    parse_documentation(info, loaded$mod_ns)
  })

  stats::setNames(docs, mod_names)
}
