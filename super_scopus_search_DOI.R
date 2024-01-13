
# Get DOIs from super_scopus_search()

super_scopus_search_DOI = 
  
  function( query, 
            search_period, 
            quota,  # Scopus API quota 
            path,   # directory path
            save_date_time_file = FALSE,  # save date and time in a text file
            console_print = FALSE         # print DOIs in R console
  ) {
    
    require(rscopus)
    
    if(have_api_key()) {  # error if API key missing
      
      # Read in 'super_scopus_search' function
      source('https://raw.githubusercontent.com/pablobernabeu/super_scopus_search/main/super_scopus_search.R')
      
      library(dplyr)
      
      results = super_scopus_search(query, search_period, quota)
      
      date_time = as.character(format(Sys.time(), "%d%m%Y %H%M"))
      
      if(isTRUE(save_date_time_file)) {
        fileConn = file(paste0(path, 'date and time from last retrieval of DOIs.txt'))
        writeLines(date_time, fileConn)
        close(fileConn)
      }
      
      DOIs = results[complete.cases(results$doi), 'doi']
      
      if(isTRUE(console_print)) cat(DOIs, sep = '\n')
      
      file = paste0(path, 'DOIs, ', date_time, '.csv')
      
      write.csv(DOIs, file, row.names = FALSE)
      
    }
  }
