#' Greet users
#'
#' The \code{package_name/hello} module provides functions for greeting users.
".__module__."

#' Greets the user by name.
#' Returns a greeting message.
#' @name say_hello
#' @param name A string containing the name of the person to greet.
#' @return A character string with a greeting message.
#' @export
#'
#' @examples
#' say_hello("Alice")
#' # "Hello, Alice!"
say_hello <- function(name) {
  paste0("Hello, ", name, "!")
}


#' Bids farewell to the user by name.
#' Returns a goodbye message.
#' @name  say_goodbye
#' @param name A string containing the name of the person to bid farewell.
#' @return A character string with a goodbye message.
#' @export
#'
#' @examples
#' say_goodbye("Alice")
#' # "Goodbye, Alice!"
say_goodbye <- function(name) {
  paste0("Goodbye, ", name, "!")
}
