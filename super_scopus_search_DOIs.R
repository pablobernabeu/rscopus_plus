
# Get DOIs from super_scopus_search and save them in a CSV file.

super_scopus_search_DOIs = 
  
  function( query, 
            search_period, 
            quota,  # Scopus API quota 
            path,   # directory path
            save_date_time_file = FALSE,  # save date and time in a text file
            console_print_DOIs = FALSE    # print DOIs in R console
  ) {
    
    require(rscopus)
    
    if(!have_api_key()) {  # error if API key missing
      
      stop('The login key for the Scopus API has not been read in. Find out more at \n',
           'https://cran.r-project.org/web/packages/rscopus/vignettes/api_key.html')
      
    } else {
      
      # Read in 'super_scopus_search' function
      source('https://raw.githubusercontent.com/pablobernabeu/super_scopus_search/main/super_scopus_search.R')
      
      require(dplyr)
      
      # Use tryCatch() to handle errors in super_scopus_search
      res = tryCatch({
        results = super_scopus_search(query, search_period, quota)
      }, error = function(e) {
        print(paste("Error in nested function 'super_scopus_search': ", e$message))  # Print error message to console
      })
      
      DOIs = results[complete.cases(results$doi), 'doi']
      
      if(isTRUE(console_print_DOIs)) cat(DOIs, sep = '\n')
      
      date_time = as.character(format(Sys.time(), '%Y-%m-%d %H%M'))
      
      if(isTRUE(save_date_time_file)) {
        fileConn = file(paste0(path, 'date and time of previous retrieval of DOIs.txt'))
        writeLines(date_time, fileConn)
        close(fileConn)
      }
      
      file = paste0(path, 'DOIs, ', date_time, '.csv')
      
      write.csv(DOIs, file, row.names = FALSE)
    }
  }
