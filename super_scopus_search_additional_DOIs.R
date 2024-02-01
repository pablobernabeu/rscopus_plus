
# Search for additional DOIs after running 
# `scopus_search_plus_DOIs(save_date_time_file = TRUE)`.
#  Save the additional DOIs in a CSV file, and 
# save all DOIS in another CSV file.

scopus_search_plus_additional_DOIs = 
  
  function( query, 
            search_period, 
            quota,                        # Scopus API quota 
            path,                         # directory path
            save_date_time_file = TRUE,   # save date and time in a text file
            verbose = TRUE,               # print progress in R console
            console_print_DOIs = FALSE    # print DOIs in R console
  ) {
    
    require(rscopus)
    
    # Error if API key missing
    if(!have_api_key()) {
      stop('The login key for the Scopus API has not been read in. Find out more at \n',
           '  https://cran.r-project.org/web/packages/rscopus/vignettes/api_key.html')
    }
    
    # Read in 'scopus_search_plus_DOIs' function
    source('https://raw.githubusercontent.com/pablobernabeu/rscopus_plus/main/scopus_search_plus_DOIs.R')
    
    require(dplyr)
    
    # Previous DOIs
    
    date_time_last_access = 
      readLines(paste0(path, 'date and time of previous retrieval of DOIs.txt'))
    
    last_file = paste0(path, 'DOIs, ', date_time_last_access, '.csv')
    
    previous_DOIs = read.csv(last_file)
    
    # Latest DOIs
    
    # Use tryCatch() to handle errors in scopus_search_plus_DOIs
    results = tryCatch({
      
      scopus_search_plus(query, search_period, quota, verbose = verbose)
      
    }, error = function(e) {  # Print error message to console
      print(paste("Error in nested function 'scopus_search_plus_DOIs':", e$message))
    })
    
    DOIs = results[complete.cases(results$doi), 'doi']
    
    date_time = as.character(format(Sys.time(), '%Y-%m-%d %H%M'))
    
    file = paste0(path, 'DOIs, ', date_time, '.csv')
    
    write.csv(unique(DOIs), file, row.names = FALSE)
    
    # Find the DOIs that were not in the previous retrieval
    
    additional_DOIs = DOIs[!DOIs %in% previous_DOIs$x] 
    
    unique(additional_DOIs) %>%
      write.csv(paste0(path, 'additional DOIs, ', 
                       date_time, '.csv'), 
                row.names = FALSE)
    
    if(isTRUE(save_date_time_file)) {
      fileConn = file(paste0(path, 'date and time of previous retrieval of DOIs.txt'))
      writeLines(date_time, fileConn)
      close(fileConn)
    }
    
    if(isTRUE(console_print_DOIs)) cat(additional_DOIs, '', sep = '\n')
  }
