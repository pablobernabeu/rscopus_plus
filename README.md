
# super_scopus_search

### A set of functions that run `rscopus::scopus_search` as many times as necessary based on the number of results and the search quota.

- `super_scopus_search`: Run `rscopus::scopus_search` as many times as necessary based on the number of results and the search quota.

- `super_scopus_search_DOIs`: Get DOIs from `super_scopus_search`, which can then be copied and pasted into a reference manager, such as Zotero, to create a list of references.
  
- `super_scopus_search_additional_DOIs`: Search for additional DOIs after running `super_scopus_search_DOIs(save_date_time_file = TRUE)`.

*Note.* Before running any of these functions, the user must read in their Scopus API key confidentially (see https://cran.r-project.org/web/packages/rscopus/vignettes/api_key.html). An error appears if the key has not been read in.
