
# `rscopus_plus`

## An extension of the `rscopus` package

The [`rscopus_plus`](https://github.com/pablobernabeu/rscopus_plus) functions (Bernabeu, 2024) extend the R package [`rscopus`](https://github.com/muschellij2/rscopus) (Muschelli, 2022) to administer the search quota and to enable specific searches and comparisons. An example of use is [available here](https://github.com/pablobernabeu/L2_L3_EF).

- `scopus_search_plus` runs `rscopus::scopus_search` as many times as necessary based on the number of results and the search quota.

- `scopus_search_DOIs` gets DOIs from `scopus_search_plus`, which can then be imported into a reference manager, such as Zotero, to create a list of references.
  
- `scopus_search_additional_DOIs` searches for additional DOIs.

- `scopus_comparison` compares counts of publications on various topics during a certain period.

- `plot_scopus_comparison` draws a line plot with the output from `scopus_comparison`.

    ![plot_L2_L3_EF](https://raw.githubusercontent.com/pablobernabeu/L2_L3_EF/main/plot_L2_L3_EF.svg)

---

*Note.* Before using any of these functions, the user must read in their Scopus API key confidentially (see [rscopus guidelines](https://cran.r-project.org/web/packages/rscopus/vignettes/api_key.html)). 

---

### References

Bernabeu, P. (2024). *rscopus_plus (v1.1.5)*. Zenodo. https://doi.org/10.5281/zenodo.10689747

Muschelli, J. (2022). *Package ’rscopus’*. CRAN. https://cran.r-project.org/web/packages/rscopus/rscopus.pdf
