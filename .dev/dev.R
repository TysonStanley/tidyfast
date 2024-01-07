# dev file for preparing release
cpp11::cpp_register(here::here())
## clean up by removing all .o files
files = fs::dir_ls(here::here("src/"), regexp = "\\.o|\\.so")
fs::file_delete(files)
# document
devtools::document(here::here())
# check package
devtools::check(here::here())
# fix github actions
usethis::use_github_action()
