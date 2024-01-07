# dev file for preparing release
cpp11::cpp_register(here::here())
## clean up by removing all .o files
files = fs::dir_ls(here::here("src/"), regexp = "\\.o|\\.so")
fs::file_delete(files)
devtools::document(here::here())
devtools::check(here::here())
