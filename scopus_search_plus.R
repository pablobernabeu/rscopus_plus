
# Run `rscopus::scopus_search` as many times as necessary based on the number
# of results and the search quota.

# Note. Before running the current function, the user must read in their
# Scopus API key confidentially
# (see https://cran.r-project.org/web/packages/rscopus/vignettes/api_key.html).
# An error appears if the key has not been read in.

scopus_search_plus =

  function( query,

            search_period,                     # single year or period (e.g., '2000-2010')
            quota = 5,                         # Scopus API quota
            view = c('STANDARD', 'COMPLETE'),  # see https://cran.r-project.org/web/packages/rscopus/rscopus.pdf
            inst_token = NULL,                 # see https://cran.r-project.org/web/packages/rscopus/rscopus.pdf
            verbose = TRUE                     # print progress in R console
  ) {

    require(rscopus)

    # Error if API key missing
    if(!have_api_key()) {
      stop('The login key for the Scopus API has not been read in. Find out more at \n',
           '  https://cran.r-project.org/web/packages/rscopus/vignettes/api_key.html')
    }

    view = match.arg(view)

    require(dplyr)

    res = tryCatch({

      if(is.null(inst_token)) {
        scopus_search(query = query, max_count = quota, count = quota,
                      date = search_period, view = view,
                      verbose = verbose)
      } else {
        scopus_search(query = query, max_count = quota, count = quota,
                      date = search_period, view = view,
                      headers = inst_token_header(inst_token),
                      verbose = verbose)
      }

    }, error = function(e) {
      message("Error in nested function 'scopus_search': ", e$message)
      return(NULL)
    })

    if(is.null(res)) {
      return(data.frame(author = character(), date = character(),
                        title = character(), publication = character(),
                        doi = character()))
    }

    total_results = suppressWarnings(as.integer(res$total_results))

    if(is.na(total_results) || total_results == 0) {
      return(data.frame(author = character(), date = character(),
                        title = character(), publication = character(),
                        doi = character()))
    }

    # Scopus rejects requests with start >= 5000; cap accordingly
    safe_max = min(total_results - 1L, 4999L)
    if(total_results > 5000L) {
      warning("Total results (", total_results, ") exceed the Scopus pagination ",
              "limit of 5000. Only the first 5000 results will be retrieved.")
    }

    chunks = seq(0, safe_max, by = quota)

    results = data.frame(author = character(), date = character(),
                         title = character(), publication = character(),
                         doi = character())

    for(i_chunk in seq_along(chunks)) {

      res = tryCatch({

        if(is.null(inst_token)) {
          scopus_search(query = query, max_count = quota, count = quota,
                        start = chunks[i_chunk], date = search_period,
                        view = view, verbose = verbose)
        } else {
          scopus_search(query = query, max_count = quota, count = quota,
                        start = chunks[i_chunk], date = search_period,
                        view = view, headers = inst_token_header(inst_token),
                        verbose = verbose)
        }

      }, error = function(e) {
        message("Error in nested function 'scopus_search': ", e$message)
        return(NULL)
      })

      if(is.null(res)) next

      for(i_entry in seq_along(res$entries)) {

        author      = res$entries[[i_entry]]$`dc:creator`
        date        = res$entries[[i_entry]]$`prism:coverDisplayDate`
        title       = res$entries[[i_entry]]$`dc:title`
        publication = res$entries[[i_entry]]$`prism:publicationName`
        doi         = res$entries[[i_entry]]$`prism:doi`

        i_results = data.frame(
          author      = ifelse(!is.null(author),      author,      NA),
          date        = ifelse(!is.null(date),        date,        NA),
          title       = ifelse(!is.null(title),       title,       NA),
          publication = ifelse(!is.null(publication), publication, NA),
          doi         = ifelse(!is.null(doi),         doi,         NA)
        )

        results = rbind(results, i_results)
      }
    }

    return(results)
  }
