
# rscopus_plus

## Facilitating the use of the rscopus package in R

These functions provide a modest extension of the rscopus package in R to administer the search quota and to make specific searches and comparisons.

- `scopus_search_plus`: Run `rscopus::scopus_search` as many times as necessary based on the number of results and the search quota.

- `scopus_search_plus_DOIs`: Get DOIs from `scopus_search_plus`, which can then be imported into a reference manager, such as Zotero, to create a list of references.
  
- `scopus_search_plus_additional_DOIs`: Search for additional DOIs.

- `scopus_comparison`: Compare counts of publications on various topics during a certain period.

---

*Note.* Before running any of these functions, the user must read in their Scopus API key confidentially (see [rscopus guidelines](https://cran.r-project.org/web/packages/rscopus/vignettes/api_key.html)). An error appears if the key has not been read in.
