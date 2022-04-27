argonDashPage(
  title = "Twitter Feelings",
  author = "Cyprien",
  description = "Argon Dash Test",
  tags$head(
    HTML('<link rel="icon" href="twitter_png.png" 
                type="image/png" />'),
    
    tags$style(HTML("
            .form-control.shiny-bound-input {
    width: 100%!important;
    max-width: 400px;
}
@media(max-width:767.98px){
  .content iframe {
    width: 100%;
}
}
.col-sm.offset-sm-2 {
    margin-bottom: 15px;
}
      "))
    
  ),
  sidebar = argonSidebar,
  header = argonHeader,
  body = argonDashBody(
    argonTabItems(
      argonTabItem(
        tabName = "tweet_discover",
        
        # classic cards
        argonH1("Discovering most recent tweets", display = 4),
        argonRow(
          argonCard(
            width = 12,
            src = NULL,
            shadow = TRUE,
            border_level = 2,
            hover_shadow = TRUE,
            title = "Have a look at latest tweets by choosing a hashtag ! ",
            argonRow(
              tags$head(tags$style(type = "text/css", ".form-control.shiny-bound-input {
    width: 100%!important;
    max-width: 400px;
}")),
              argonColumn(
                offset = 2,
                width = 4,
                pickerInput(
                  inputId = "country_select", 
                  label = "Which country do you want to find trends?", 
                  choices = countries, 
                  selected = c("Worldwide", "France"),
                  options = list(
                    `actions-box` = TRUE, 
                    size = 63,
                    `selected-text-format` = "count > 0"
                  ), 
                  multiple = TRUE
                )),
              argonColumn(
                width = 4,
                selectizeInput("hashtag_select", label = "Choose a # or write any ", choices = NULL, selected = NULL, multiple = TRUE,options = list(create = TRUE, placeholder = "#"))
              ),
              argonColumn(
                width = 1,
                dropdownButton(
                  tags$h3("List of Input"),
                  selectInput("lang_select", "Choose tweet only in my language", choices = table_lang$libelle, selected = table_lang$libelle[1], multiple = FALSE),
                  materialSwitch(inputId = "pop_tweet", label = "Show only popular tweet", status = "success"),
                  circle = TRUE, status = "success", icon = icon("cogs"), width = "300px", up = FALSE,
                  tooltip = tooltipOptions(title = "Click to see inputs !")
                  
                )
              )
              
            )
          )
        ),
        argonRow(
          
          argonCard(
            width = 6,
            src = NULL,
            shadow = TRUE,
            hover_shadow = TRUE,
            argonRow(
              echarts4rOutput("sentiments_plot")
              
            )
          ),
          argonCard(
            width = 6,
            src = NULL,
            shadow = TRUE,
            hover_shadow = TRUE,
            argonRow(
              echarts4rOutput("language_plot")
              
            )
          )
          
          
        ),
        argonRow(
          argonColumn(offset = 2,
                      actionBttn(
                        inputId = "random_negs",
                        label = "Random Negative Tweets", 
                        style = "material-flat",
                        color = "danger"
                      )),
          
          argonColumn(offset = 2,
                      actionBttn(
                        inputId = "random_poss",
                        label = "Random Positive Tweets", 
                        style = "material-flat",
                        color = "succes"
                      ))
        ),
        
        argonRow(
          argonColumn(
            width = 6,
            tags$head(
              tags$script(HTML(js)),
              tags$style(HTML(
                "
        .content {
          margin: auto;
          padding: 20px 10px;
          width: 100%;
        }"))
            ),
            
            argonRow(uiOutput("tweet_neg1")),
            argonRow(uiOutput("tweet_neg2")),
            argonRow(uiOutput("tweet_neg3"))
            
          ),
          
          argonColumn(
            width = 6,
            tags$head(
              tags$script(HTML(js)),
              tags$style(HTML(
                "
        .content {
          margin: auto;
          padding: 20px 10px;
          width: 100%;
        }"))
            ),
            
            argonRow(uiOutput("tweet_pos1")),
            argonRow(uiOutput("tweet_pos2")),
            argonRow(uiOutput("tweet_pos3"))
            
          )
        )
      ),
      argonTabItem(
        tabName = "maps",
        
        argonH1("Click on earth points to see tweets", display = 4),
        argonRow(
          argonColumn(
            width = 6,
            argonCard(
              width = 12,
              argonRow(
                argonColumn(
                  width = 12,
                  selectizeInput("hashtag_select_map", label = "Choose among following # ", choices = geocoded_data$hashtag, selected = c(geocoded_data$hashtag), multiple = TRUE,options = list(create = FALSE, placeholder = "#"))
                )
                
              )
            ),
            argonRow(
              argonCard(
                width = 12,
                argonRow(
                  argonColumn(
                    echarts4rOutput('outpt_map')
                  )
                  
                )
              )
            )
          ),
          argonColumn(
            width = 6,
            argonCard(
              width = 12,
              argonRow(
                argonColumn(
                  width = 12,
                  echarts4rOutput("plot_emotion")
                  
                )
                
              )
            ),
            uiOutput("geo_tweet")
          )
          
        )),
      
      argonTabItem(tabName = "cluster",
                   argonH1("Discover most popular tweet and their network !", display = 4),
                   argonRow(
                     argonCard(
                       width = 12,
                       src = NULL,
                       shadow = TRUE,
                       border_level = 2,
                       hover_shadow = TRUE,
                       title = "Choose a hashtag to see popular tweets",
                       argonRow(
                         tags$head(tags$style(type = "text/css", ".form-control.shiny-bound-input {
    width: 100%!important;
    max-width: 400px;
}")),
                         argonColumn(
                           width = 4,
                           selectInput("hashtag_select_network", label = "Choose among the #", choices = NULL, selected = NULL, multiple = FALSE)
                         ),
                         
                         argonColumn(width = 4,
                                     argonInfoCard(
                                       value = textOutput("nb_retweet"), 
                                       title = "Number of retweet", 
                                       icon = icon("percent"), 
                                       icon_background = "info",
                                       gradient = TRUE,
                                       background_color = "orange",
                                       hover_lift = TRUE,
                                       width = 12
                                     )),
                         argonColumn(width = 4,
                                     argonInfoCard(
                                       value = textOutput("loc_retweet"), 
                                       title = "Location",  
                                       icon = argonIcon("planet"), 
                                       icon_background = "danger",
                                       hover_lift = TRUE,
                                       width = 12
                                     ))
                         
                       )
                     )),
                   argonRow(
                     argonColumn(width = 6,
                                 argonCard(
                                   width = 12,
                                   src = NULL,
                                   shadow = TRUE,
                                   border_level = 2,
                                   hover_shadow = TRUE,
                                   withSpinner(sigmajsOutput("graph"))
                                 )),
                     argonColumn(width = 6,
                                 withSpinner(uiOutput("tweet_network_display"))
                                 
                     )
                   )
                   
      )
      
      
      
      
      
      
      
      ,
      argonTabItem(tabName = "about_me",
                   
                   argonRow(
                     argonColumn(
                       width = 12,
                       argonProfile(
                         title = "Cyprien Cambus",
                         subtitle = "Data Scientist",
                         src = "https://i.ibb.co/nrw84Y4/cyp.jpg",
                         url = "https://cyprien-cambus.shinyapps.io/argonapp/",
                         "Working as a Data Scientist for almost 2 years, I love to discover new things and I know that this job allows me to do so. 
                The number of problems that data could solve is infinite.", br(),
                         "Although I learned to program in python at the beginning, I discovered later all the unsuspected power that R allowed, especially in Data Vizualisation and Statistics.
                So I continued to learn and specialize in this language, using it daily in my work. I still discover every day some fantastic packages and framework that can be created thanks to the large R community.
                I became a R loveR for sure."
                       )
                     )
                   )
                   
      ),
      argonTabItem(tabName = "links",
                   br(), br(), br(), br(), br(), br(),
                   
                   argonRow(
                     argonColumn(width = 4,
                                 htmltools::tags$div(
                                   class = "card-profile-image",
                                   htmltools::a(
                                     href = "https://www.linkedin.com/in/cyprien-cambus/",
                                     htmltools::img(src = "https://i.ibb.co/j52LPHt/Linked-In-logo-initials.png", class = "rounded-circle")
                                   )
                                 )
                                 
                     ),
                     argonColumn(width = 4,
                                 htmltools::tags$div(
                                   class = "card-profile-image",
                                   htmltools::a(
                                     href = "https://github.com/CyprienCambus",
                                     htmltools::img(src = "https://i.ibb.co/RY26bnV/800px-Octicons-mark-github-svg.png", class = "rounded-circle")
                                   )
                                 )
                                 
                     ),
                     argonColumn(width = 4,
                                 htmltools::tags$div(
                                   class = "card-profile-image",
                                   htmltools::a(
                                     href = "https://echarts4r.john-coene.com/",
                                     htmltools::img(src = "https://i.ibb.co/rpfvZct/logo.png", class = "fit-picture")
                                   )
                                 )
                                 
                     )
                   ),
                   br(), br(), br(), br(), br(), br(),br(), br(), br(),br(), br(),br(), br(), br(),
                   argonRow(argonColumn(width = 4,
                                        htmltools::tags$div(
                                          class = "card-profile-image",
                                          htmltools::a(
                                            href = "https://github.com/JohnCoene/graphTweets",
                                            htmltools::img(src = "https://i.ibb.co/9Vh1wgN/logo-graph.png", class = "fit-picture")
                                          )
                                        )
                                        
                   ),
                   argonColumn(width = 4,
                               htmltools::tags$div(
                                 class = "card-profile-image",
                                 htmltools::a(
                                   href = "https://github.com/JohnCoene/sigmajs",
                                   htmltools::img(src = "https://i.ibb.co/BwYGvtY/logo-sjs.png", class = "fit-picture")
                                 )
                               )
                               
                   ),
                   argonColumn(width = 4,
                               htmltools::tags$div(
                                 class = "card-profile-image",
                                 htmltools::a(
                                   href = "https://github.com/ropensci/rtweet",
                                   htmltools::img(src = "https://i.ibb.co/YQrH1qT/logo-rtxeet.png", class = "fit-picture")
                                 )
                               )
                               
                   )
                   
                   
                   
                   )
      )
    )
  ),
  footer = argonFooter
)