test_that("say_hello returns a greeting", {
  expect_equal(say_hello("Alice"), "Hello, Alice!")
})

test_that("say_goodbye returns a farewell", {
  expect_equal(say_goodbye("Bob"), "Goodbye, Bob!")
})
