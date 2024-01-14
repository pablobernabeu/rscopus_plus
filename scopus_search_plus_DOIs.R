
# Get DOIs from scopus_search_plus and save them in a CSV file.

scopus_search_plus_DOIs = 
  
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
    
    # Read in 'scopus_search_plus' function
    source('https://raw.githubusercontent.com/pablobernabeu/rscopus_plus/main/scopus_search_plus.R')
    
    require(dplyr)
    
    # Use tryCatch() to handle errors in scopus_search_plus
    results = tryCatch({
      scopus_search_plus(query, search_period, quota, verbose = verbose)
    }, error = function(e) {
      print(paste("Error in nested function 'scopus_search_plus': ", e$message))  # Print error message to console
    })
    
    DOIs = results[complete.cases(results$doi), 'doi']
    
    if(isTRUE(console_print_DOIs)) cat(DOIs, '', sep = '\n')
    
    date_time = as.character(format(Sys.time(), '%Y-%m-%d %H%M'))
    
    if(isTRUE(save_date_time_file)) {
      fileConn = file(paste0(path, 'date and time of previous retrieval of DOIs.txt'))
      writeLines(date_time, fileConn)
      close(fileConn)
    }
    
    file = paste0(path, 'DOIs, ', date_time, '.csv')
    
    write.csv(unique(DOIs), file, row.names = FALSE)
  }
