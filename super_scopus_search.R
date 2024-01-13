
# Run `rscopus::scopus_search` as many times as necessary based on the number of results and the search quota.

# Note. Before running the current function, the user must read in their Scopus API key confidentially 
# (see https://cran.r-project.org/web/packages/rscopus/vignettes/api_key.html). An error appears if the key 
# has not been read in.

super_scopus_search = 
  
  function( query, 
            search_period,       # single year or period (e.g., '2000-2010')
            quota,               # Scopus API quota
            safe_maximum = 5000  # limit number of results
  ) {
    
    require(rscopus)
    
    if(have_api_key()) {  # error if API key missing
      
      require(dplyr)
      
      res = scopus_search( query = query, max_count = quota, 
                           count = quota, date = search_period )
      
      total_results = 0 : res$total_results
      
      chunks = total_results[seq(1, length(total_results), quota)]
      
      results = data.frame(author = as.character(), date = as.character(), 
                           title = as.character(), publication = as.character(), 
                           doi = as.character())
      
      for(i_chunk in 1 : n_distinct(chunks)) {
        
        res = scopus_search(query = query, max_count = quota, count = quota, 
                            start = chunks[i_chunk], date = search_period)
        
        for(i_entry in 1 : length(res$entries)) {
          
          author = res$entries[[i_entry]]$`dc:creator`
          date = res$entries[[i_entry]]$`prism:coverDisplayDate`
          title = res$entries[[i_entry]]$`dc:title`
          publication = res$entries[[i_entry]]$`prism:publicationName`
          doi = res$entries[[i_entry]]$`prism:doi`
          
          i_results = data.frame( author = ifelse(!is.null(author), author, NA), 
                                  date = ifelse(!is.null(date), date, NA), 
                                  title = ifelse(!is.null(title), title, NA), 
                                  publication = ifelse(!is.null(publication), publication, NA), 
                                  doi = ifelse(!is.null(doi), doi, NA) )
          
          results = rbind(results, i_results)
          
        }
      }
    }
  }
