
# Compare counts of publications on various topics during a certain period.

scopus_comparison = 
  
  function( reference_query, 
            comparison_terms, 
            search_period, 
            quota, 
            reference_query_field_tag = NULL,
            verbose = TRUE ) {
    
    require(rscopus)
    
    # Error if API key missing
    if(!have_api_key()) {
      stop('The login key for the Scopus API has not been read in. Find out more at \n',
           '  https://cran.r-project.org/web/packages/rscopus/vignettes/api_key.html')
    }
    
    require(stringr)      # text processing
    require(dplyr)        # data wrangling
    require(formattable)  # number formatting
    
    # If reference_query_field_tag has been supplied, save the original reference_query
    # for later use in the abridged query label, and wrap reference_query in the tag. 
    
    original_reference_query = reference_query
    
    if(!is.null(reference_query_field_tag)) {
      reference_query = paste0(reference_query_field_tag, '(', reference_query, ')')
    }
    
    # Compose comparison queries by preceding each comparison term by the 
    # reference query. In this way, the `comparison_terms` input (e.g., 
    # "'effect size'") is not searched for alone, but it is always preceded 
    # by the reference query (e.g., "'language learning' 'effect size'").
    
    queries = reference_query
    
    for(i_term in seq_along(comparison_terms)) {
      queries = c(queries, paste(reference_query, comparison_terms[i_term]))
    }
    
    results = data.frame( query = as.character(), 
                          abridged_query = as.character(), 
                          year = as.numeric(), 
                          publications = as.character() )
    
    # Iterate over queries
    for(i_query in seq_along(queries)) {
      
      query = queries[i_query]
      
      # Iterate over search_period
      for(i_year in seq_along(search_period)) {
        
        year = search_period[i_year]
        
        # Current year must be transformed to search_period up to the 
        # following year to allow `search_scopus` function to work.
        
        i_search_period = paste(year, year+1, sep = '-')
        
        # Use tryCatch() to handle errors in scopus_search. Errors arise when 
        # there are no publications, in which case a zero is registered. 
        
        publications = tryCatch({
          
          res = scopus_search(query = query, max_count = quota, count = quota, 
                              date = i_search_period, verbose = verbose)
          
          res$total_results # output
          
        }, error = function(e) {  # If error, register 0 publications
          
          0 # output
        })
        
        results = results %>%
          
          rbind( data.frame(query, year, publications) %>% 
                   
                   mutate( abridged_query = 
                             
                             case_when( query == reference_query ~ original_reference_query, 
                                        
                                        query != reference_query ~ 
                                          str_replace(query, fixed(reference_query), 
                                                      "[reference query] + '") %>%
                                          str_replace("' ", "'") %>% paste0("'"), 
                                        
                                        .default = query )
                   )
          )
      }
    }
    
    # Compute publication count over the whole search_period
    
    results = results %>% 
      group_by(query) %>% 
      mutate(total_publications = sum(publications))
    
    # Create columns containing each query and its total publication count
    
    results = results %>% mutate(
      
      query_total_publications = 
        paste0("'", query, "'", ' [', 
               formattable::comma(total_publications, digits = 0), ']'),
      
      abridged_query_total_publications = 
        
        case_when( query == reference_query ~ 
                     paste0("'", original_reference_query, "'", ' [', 
                            formattable::comma(total_publications, digits = 0), ']'), 
                   
                   query != reference_query ~ 
                     paste0(abridged_query, ' [', 
                            formattable::comma(total_publications, digits = 0), ']'), 
                   
                   .default = NA )
    )
    
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
