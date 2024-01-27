
# Compare counts of publications on various topics during a certain period.

scopus_comparison = 
  
  function(reference_query, comparison_terms, search_period, quota, 
           safe_maximum = 5000, # limit number of results
           verbose = TRUE) {
    
    require(rscopus)
    
    # Error if API key missing
    if(!have_api_key()) {
      stop('The login key for the Scopus API has not been read in. Find out more at \n',
           '  https://cran.r-project.org/web/packages/rscopus/vignettes/api_key.html')
    }
    
    require(dplyr)  # data wrangling
    require(formattable)  # number formatting
    
    # Compose comparison queries by preceding each comparison term by the 
    # reference query. In this way, the `comparison_terms` input (e.g., 
    # "'effect size'") is not searched for alone, but it is always preceded 
    # by the reference query (e.g., "'language learning' 'effect size'").
    
    queries = reference_query
    
    for(i_term in seq_along(comparison_terms)) {
      queries = c(queries, paste(reference_query, comparison_terms[i_term]))
    }
    
    results = data.frame(query = as.character(), year = as.numeric(), 
                         publications = as.character())
    
    # Iterate over queries
    for(i_query in seq_along(queries)) {
      
      query = queries[i_query]
      
      # Iterate over search_period
      for(i_year in seq_along(search_period)) {
        
        year = search_period[i_year]
        
        # Current year must be transformed to search_period up to the 
        # following year to allow `search_scopus` function to work.
        
        i_search_period = paste(year, year+1, sep = '-')
        
        # Use tryCatch() to handle errors in scopus_search
        res = tryCatch({
          
          scopus_search(query = query, max_count = quota, count = quota, 
                        date = i_search_period, safe_maximum = safe_maximum,
                        verbose = verbose)
          
        }, error = function(e) {  # Print error message to console
          print(paste("Error in nested function 'scopus_search': ", e$message))
        })
        
        # Number of publications
        publications = res$total_results
        
        results = rbind(results, data.frame(query, year, publications))
      }
    }
    
    # Compute publication count over the whole search_period
    results = results %>% group_by(query) %>% 
      mutate(total_publications = sum(publications))
    
    # Create column containing each query and its total publication count
    results = results %>%
      mutate(query_total_publications = 
               paste0('"', query, '"', ' [', 
                      formattable::comma(total_publications, digits = 0), ']'))
    
    # Compute comparison weights by calculating the percentage of results for each
    # comparison query (e.g., "'language learning' 'effect size'") relative to the
    # results for the reference query (e.g., "'language learning'"). To this end,
    # iterate over comparison queries. The data used in each iteration include the
    # reference query and the comparison query specific to the iteration. In the
    # code `seq_along(queries[-1])` below, the first element (i.e., the reference
    # query) is removed in order to iterate over the comparison queries only.
    
    results2 = results[0,]
    
    for(i_query in seq_along(queries[-1])) {
      
      comparison_query = queries[-1][i_query]
      
      selection = results[results$query == comparison_query,]
      
      selection[selection$query == comparison_query,
                'average_comparison_percentage'] = 
        
        results[results$query == comparison_query,
                'total_publications'] / # divide by the reference query below
        
        results[results$query == reference_query,
                'total_publications'] * 100 # create percentage
      
      # Iterate over search_period
      for(i_year in seq_along(search_period)) {
        
        year = search_period[i_year]
        
        selection2 = selection[selection$year == year,]
        
        selection2$comparison_percentage = NA
        
        selection2[selection2$query == comparison_query & 
                     selection2$year == year,
                   'comparison_percentage'] = 
          
          results[results$query == comparison_query & 
                    results$year == year,
                  'publications'] / # divide by the reference query below
          
          results[results$query == reference_query & 
                    results$year == year,
                  'publications'] * 100 # create percentage
        
        # Add up iterations
        results2 = rbind(results2, selection2)
      }
    }
    
    # Select only the base query in the main data set 
    # and add the comparison queries.
    results = results %>% 
      filter(query == unique(results$query)[1]) %>% 
      rbind(results2)
    
    # Sort queries by their average percentage rank throughout search_period
    
    query_order = 
      results %>% arrange(-average_comparison_percentage) %>% 
      pull(query_total_publications) %>% unique()
    
    results$query_total_publications = 
      factor(results$query_total_publications, levels = query_order)
    
    return(results)
  }
