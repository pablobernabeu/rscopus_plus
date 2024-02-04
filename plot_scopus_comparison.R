
# Plot output from scopus_comparison()

plot_scopus_comparison = function(data) {
  
  require(stringr)
  require(ggplot2)
  require(geomtextpath)
  require(ggtext)
  
  # Colour reference query in dark blue
  
  data = data %>% mutate( 
    abridged_query_total_publications = 
      case_when(is.na(comparison_percentage) ~ 
                  abridged_query_total_publications %>%
                  str_replace("^'", "'<span style = 'color: darkblue;'>") %>%
                  str_replace(fixed("' ["), "</span>' ["), 
                .default = abridged_query_total_publications)
  )
  
  plot_data = data %>% 
    
    # Remove the reference query, as it doesn't have any comparison percentage
    filter(!is.na(comparison_percentage)) %>%
    
    ggplot(aes(year, comparison_percentage, colour = abridged_query_total_publications)) +
    scale_x_continuous(breaks = scales::breaks_pretty(10), expand = expansion(0.01)) +
    scale_y_continuous(expand = expansion(0.02), n.breaks = 8,
                       labels = scales::label_percent(accuracy = 1, scale = 1)) +
    geom_line(linewidth = 2, alpha = 0.12) + 
    guides(colour = guide_legend(override.aes = list(alpha = 1))) +
    geom_textpath(aes(label = abridged_query_total_publications, 
                      color = abridged_query_total_publications), 
                  linetype = 0, text_smoothing = 40, spacing = 80, 
                  show.legend = FALSE) +
    ggtitle( paste0( 'Comparisons to reference query ',
                     data %>%
                       filter(is.na(comparison_percentage)) %>%
                       pull(abridged_query_total_publications) %>% 
                       unique() ) ) +
    ylab(paste0('% relative to ', data[1, 'abridged_query_total_publications'])) +
    xlab('Year') + ylab('Percentage of publications relative to reference query') + 
    theme_minimal() + 
    theme(plot.title.position = 'plot', plot.title = element_markdown(hjust = 0.5), 
          plot.subtitle = element_text(colour = 'grey55', hjust = .5, 
                                       margin = margin(3, 0, 2, 0)),
          axis.title.x = element_text(size = 12, margin = margin(5, 0, 0, 0, 'pt')), 
          axis.title.y = element_text(size = 12, margin = margin(0, 6, 0, 0, 'pt')), 
          axis.text.x = element_text(size = 10, margin = margin(0, 0, 2, 0)), 
          axis.text.y = element_text(size = 10, margin = margin(0, 0, 0, 2)),
          legend.text = element_text(size = 11, margin = margin(4, 0, 4, -5)),
          legend.margin = margin(-2, 19, 6, 3), legend.box.margin = margin(5, 1, 0, 1),
          legend.title = element_blank(), legend.position = 'none', 
          legend.direction = 'vertical', legend.key.width = unit(40, 'pt'), 
          legend.background = element_rect(color = 'grey90', fill = 'grey98'), 
          panel.grid.minor = element_blank(), plot.margin = unit(c(8, 0, 8, 8), 'pt'))
}