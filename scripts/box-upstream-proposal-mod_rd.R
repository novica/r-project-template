# Proposal: export a function from `box` that returns a module's Rd
# documentation source, so external tools (doc site generators, rd2qmd,
# custom pkgdown-alternatives, etc.) can consume it without reaching into
# unexported internals (box:::parse_documentation, attr(mod, "info")/
# attr(mod, "namespace")).
#
# `box::help()` already builds exactly this data internally (see
# R/help.r) but only ever passes it to `display_help()` as a side effect
# — it's never returned to the caller. This wraps the same steps
# `box::help()` already performs, minus the display step, as a small
# exported function.
#
# Suggested home: alongside `help()` in box's own R/help.r; add `mod_rd` to
# NAMESPACE exports. Written as box-internal code (calls `throw()` and
# `parse_documentation()` unqualified, as sibling internal functions would),
# not as external `:::`-based code — this is meant to be pasted into box's
# own source tree, not run standalone. To smoke-test it outside box's
# package, assign it into box's namespace first:
#   environment(mod_rd) <- asNamespace("box")
#   box::use(mymod = ./some/module)
#   mod_rd(mymod)

#' Get a module's Rd documentation source
#'
#' Returns the Rd (R documentation) source for every documented topic in a
#' loaded module — the module itself (`.__module__.`) and each documented
#' export. This is the same data `box::help()` computes internally before
#' displaying it; `mod_rd()` returns it instead, for tools that want to
#' process a module's documentation programmatically (e.g. generating a
#' documentation website).
#'
#' @param mod A module object, as returned by \code{box::use()}.
#' @return A named list of character vectors, one per documented topic
#'   (\code{".__module__."} for the module-level doc, plus one entry per
#'   documented export), each containing that topic's Rd source lines.
#' @examples
#' \dontrun{
#' box::use(mymod = ./mymod)
#' docs <- box::mod_rd(mymod)
#' writeLines(docs$my_function, "man/my_function.Rd")
#' }
#' @export
mod_rd <- function(mod) {
  if (!inherits(mod, "box$mod")) {
    throw("`mod` must be a module object, as returned by box::use()")
  }

  info <- attr(mod, "info")
  mod_ns <- attr(mod, "namespace")

  if (inherits(info, "box$pkg_info")) {
    throw(
      "mod_rd() only supports local/script modules, not package modules ",
      "(use base R's `?` / `help()` for package documentation instead)"
    )
  }

  if (!requireNamespace("roxygen2", quietly = TRUE)) {
    throw("mod_rd() requires the 'roxygen2' package to be installed")
  }

  parse_documentation(info, mod_ns)
}
