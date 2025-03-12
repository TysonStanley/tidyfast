linters = all_linters(
  missing_argument_linter(allow_trailing = TRUE),
  undesirable_function_linter(modify_defaults(default_undesirable_functions,
    library = NULL,
    options = NULL
  )),
  assignment_linter = NULL,
  commented_code_linter = NULL,
  condition_call_linter = NULL,
  expect_identical_linter = NULL,
  function_argument_linter = NULL,
  implicit_integer_linter = NULL,
  infix_spaces_linter = NULL,
  keyword_quote_linter = NULL,
  line_length_linter = NULL,
  object_name_linter = NULL,
  unused_import_linter = NULL
)
