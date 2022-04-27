server = function(input, output, session) {
  
  
  virtualenv_dir = Sys.getenv('VIRTUALENV_NAME')
  python_path = Sys.getenv('PYTHON_PATH')
  
  #Create virtual env and install dependencies
  reticulate::virtualenv_create(envname = virtualenv_dir, python = python_path)
  reticulate::virtualenv_install(virtualenv_dir, packages = PYTHON_DEPENDENCIES, ignore_installed=TRUE)
  reticulate::use_virtualenv(virtualenv_dir, required = T)
  
  
  trends <- reactive({
    
    woeids_concern <- woeid_data %>% filter(country %in% input$country_select)
    
    res <- try(get_trends(c(woeids_concern$woeid)))
    
    if (class(res) == "try-error"){
      
      return(NULL)
      
    }else{
      
      return(res)}
    
  })
  
  
  hashtags_selectionnes <- reactive({
    
    
    
    
    if (length(input$hashtag_select) == 0){
      return(NULL)
    }else if (length(input$hashtag_select) == 1){
      
      if (substr(input$hashtag_select[1],1,1) == "#"){
        return(input$hashtag_select[1])
      }else{
        return(paste("#", input$hashtag_select[1],sep = ""))
      }
      
    }else{
      vec_res <- rep(NA, length(input$hashtag_select))
      
      for (i in c(1:length(input$hashtag_select))){
        if (substr(input$hashtag_select[i],1,1) == "#"){
          
          vec_res[i] <- input$hashtag_select[i]
          
        }else{
          
          vec_res[i] <- paste("#",input$hashtag_select[i], sep = "")
          
        }
      }
      return(paste(vec_res,collapse=" OR "))
      
    }
    
    
    
    
  })
  
  
  data_tweet <- reactive({
    
    
    
    if (input$pop_tweet == TRUE & input$lang_select == "All"){
      
      out <- try(get_sentiment(hashtags_selectionnes(), 50, popular = "popular"))
      
    }else if (input$pop_tweet == TRUE & input$lang_select != "All"){
      
      out <- try(get_sentiment(hashtags_selectionnes(), 50, popular = "popular", langage = table_lang[which(table_lang$libelle == input$lang_select),"code"]))
      
    }else if (input$pop_tweet == FALSE & input$lang_select == "All"){
      
      out <- try(get_sentiment(hashtags_selectionnes(), 50))
      
    }else{
      
      out <- try(get_sentiment(hashtags_selectionnes(), 50, langage = table_lang[which(table_lang$libelle == input$lang_select),"code"]))
      
    }
    
    if (class(out) == "try-error"){
      
      return(NULL)
      
    }else{
      return(out)
    }         
    
    
    
    
  })
  
  observe({
    updateSelectizeInput(session, 'hashtag_select', choices = trends(),selected = trends()[1],server =TRUE)
    updateSelectInput(session, 'hashtag_select_network', choices = trends(),selected = trends()[1])
    updateSelectizeInput(session, 'hashtag_select_mpa', choices = geocoded_data$hashtag ,server =TRUE)
    updatePickerInput(session, "country_select")
    updateSelectInput(session, "lang_select")
    updateMaterialSwitch(session, "pop_tweet")
  })
  
  
  output$sentiments_plot <- renderEcharts4r({
    
    if (is.null(data_tweet())){
      return(NULL)
    }else{
      b <- data_tweet()[[2]]
      b$Sentiment <- rownames(b)
      
      res <- b %>% 
        e_charts(Sentiment) %>%
        e_pie(Percentage, radius = c("50%", "70%")) %>%  e_labels(show = TRUE,formatter = "{d}%",position = "outside") %>%
        e_legend(right = 0, 
                 orient = "vertical") %>% e_title("Sentiments felt in tweets")
      
      return(res)
      
    }
    
    
  })
  
  
  output$language_plot <- renderEcharts4r({
    
    
    if (is.null(data_tweet())){
      return(NULL)
    }else{
      
      b <- data_tweet()[[1]] %>% left_join(., table_lang %>% rename(lang = code), by = "lang") %>% mutate(libelle = tidyr::replace_na(libelle, "Other")) %>%
        group_by(libelle) %>% summarise(language = n())
      
      b <- b[order(b$language),]
      
      
      res <- b %>% 
        e_charts(libelle) %>%
        e_bar(language, stack = "grp") %>%
        e_flip_coords() %>% e_labels(show = FALSE) %>% e_title("Who tweeted?") %>% e_y_axis(axisLabel = list(rotate = 45))
      
      return(res)
      
    }
    
  })
  
  
  output$plot_emotion <- renderEcharts4r({
    
    if (is.null(input$outpt_map_clicked_row)){
      return(NULL)
    }else{
      
      data <- geo() %>% arrange(longitude)
      
      data <- data[geo_react(),]
      
      data_emotion <- data.frame(value = unlist(get_emotions(data$texte))) 
      
      data_emotion$emotion <- rownames(data_emotion)
      
      
      data_emotion <- data_emotion %>% mutate(emoj = case_when(emotion == "Angry" ~ "\U0001f624\nAngry",
                                                               emotion == "Surprise" ~ "\U0001f62E\nSurprise",
                                                               emotion == "Sad" ~ "\U0001f622\nSad",
                                                               emotion == "Happy" ~ "\U0001f600\nHappy",
                                                               emotion == "Fear" ~ "\U0001f631\nFear"))
      
      data_emotion$emoj <- as.factor(data_emotion$emoj)
      
      res <- data_emotion %>% 
        e_charts(emoj) %>%
        e_bar(value, stack = "grp") %>%
        e_flip_coords() %>% e_labels(show = FALSE) %>% e_title("Emotions in tweet") %>% e_y_axis(axisLabel = list(rotate = 45)) %>% e_x_axis(axisLabel = "") %>%
        e_legend(show = FALSE)
      
      return(res)
      
    }
    
    
  })
  
  
  random_neg <- eventReactive(input$random_negs,{
    len <- nrow(data_tweet()[[1]] %>% filter(sentiment == "negative"))
    
    if (len >= 3){
      
      out <- sample(c(1:len), 3, replace = FALSE)
      
      
    }else{
      out <- sample(c(1:len), 3, replace = TRUE)
      
      
    }
    
    return(out)
  })
  
  
  
  random_pos <- eventReactive(input$random_poss,{
    len <- nrow(data_tweet()[[1]] %>% filter(sentiment == "positive"))
    
    if (len >= 3){
      
      out <- sample(c(1:len), 3, replace = FALSE)
      
    }else{
      out <- sample(c(1:len), 3, replace = TRUE)
      
    }
    
    return(out)
  })
  
  
  
  
  
  output$tweet_neg1 <- renderUI({
    
    if (is.null(data_tweet())){
      return(NULL)
    }else{
      
      if (is.na(random_neg()[1])){
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "negative") %>% filter(rownames(.) == 1)
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet1",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          tags$script(HTML(
            '$(document).ready(function(){
          $("iframe#tweet1").on("load", function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: "height" },
              "https://twitframe.com");
          });
          $("#random_negs").on("click", function() {
            var checkExist = setInterval(function() {
             if ($("iframe#tweet1").length && $("iframe#tweet2").length) {
                $("iframe#tweet1").trigger("load");
                $("iframe#tweet2").trigger("load");
                $("iframe#tweet3").trigger("load");
                clearInterval(checkExist);
            }
          }, 100);
          });
        });
        '))
          
        )
        
      }else{
        
        
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "negative") %>% filter(rownames(.) == random_neg()[1])
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet1",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          
          tags$script(HTML(
            '$(document).ready(function(){
          $("iframe#tweet1").on("load", function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: "height" },
              "https://twitframe.com");
          });
          $("#random_negs").on("click", function() {
            var checkExist = setInterval(function() {
             if ($("iframe#tweet1").length && $("iframe#tweet2").length) {
                $("iframe#tweet1").trigger("load");
                $("iframe#tweet2").trigger("load");
                $("iframe#tweet3").trigger("load");
                clearInterval(checkExist);
            }
          }, 100);
          });
        });
        '))
          
        )
        
      }
      
      
      
      
      return(res)
      
    }
    
    
  })
  
  
  output$tweet_neg2 <- renderUI({
    
    if (is.null(data_tweet())){
      return(NULL)
    }else{
      
      if (is.na(random_neg()[1])){
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "negative") %>% filter(rownames(.) == 2)
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet2",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          
          tags$script(HTML(
            "$(document).ready(function(){
          $('iframe#tweet2').on('load', function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: 'height' },
              'https://twitframe.com');
          });
        });"))
          
        )
        
      }else{
        
        
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "negative") %>% filter(rownames(.) == random_neg()[2])
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet2",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          
          tags$script(HTML(
            "$(document).ready(function(){
          $('iframe#tweet2').on('load', function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: 'height' },
              'https://twitframe.com');
          });
        });"))
          
        )
        
      }
      
      
      
      
      return(res)
      
    }
    
    
  })
  
  
  output$tweet_neg3 <- renderUI({
    
    if (is.null(data_tweet())){
      return(NULL)
    }else{
      
      if (is.na(random_neg()[1])){
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "negative") %>% filter(rownames(.) == 3)
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet3",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          
          tags$script(HTML(
            "$(document).ready(function(){
          $('iframe#tweet3').on('load', function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: 'height' },
              'https://twitframe.com');
          });
        });"))
          
        )
        
      }else{
        
        
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "negative") %>% filter(rownames(.) == random_neg()[3])
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet3",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          
          tags$script(HTML(
            "$(document).ready(function(){
          $('iframe#tweet3').on('load', function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: 'height' },
              'https://twitframe.com');
          });
        });"))
          
        )
        
      }
      
      
      
      
      return(res)
      
    }
    
    
  })
  
  
  output$tweet_pos1 <- renderUI({
    
    if (is.null(data_tweet())){
      return(NULL)
    }else{
      
      if (is.na(random_pos()[1])){
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "positive") %>% filter(rownames(.) == 1)
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet4",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          
          tags$script(HTML(
            '$(document).ready(function(){
          $("iframe#tweet4").on("load", function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: "height" },
              "https://twitframe.com");
          });
          $("#random_poss").on("click", function() {
            var checkExist = setInterval(function() {
             if ($("iframe#tweet4").length && $("iframe#tweet5").length && $("iframe#tweet6").length) {
                $("iframe#tweet4").trigger("load");
                $("iframe#tweet5").trigger("load");
                $("iframe#tweet6").trigger("load");
                clearInterval(checkExist);
            }
          }, 100);
          });
        });'))
          
        )
        
      }else{
        
        
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "positive") %>% filter(rownames(.) == random_pos()[1])
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet4",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          tags$script(HTML(
            '$(document).ready(function(){
          $("iframe#tweet4").on("load", function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: "height" },
              "https://twitframe.com");
          });
          $("#random_poss").on("click", function() {
            var checkExist = setInterval(function() {
             if ($("iframe#tweet4").length && $("iframe#tweet5").length && $("iframe#tweet6").length) {
                $("iframe#tweet4").trigger("load");
                $("iframe#tweet5").trigger("load");
                $("iframe#tweet6").trigger("load");
                clearInterval(checkExist);
            }
          }, 100);
          });
        });'))
          
        )
        
      }
      
      
      return(res)
      
    }
    
    
  })
  
  
  
  
  output$tweet_pos2 <- renderUI({
    
    if (is.null(data_tweet())){
      return(NULL)
    }else{
      
      if (is.na(random_pos()[1])){
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "positive") %>% filter(rownames(.) == 2)
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet5",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          
          tags$script(HTML(
            "$(document).ready(function(){
          $('iframe#tweet5').on('load', function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: 'height' },
              'https://twitframe.com');
          });
        });"))
          
        )
        
      }else{
        
        
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "positive") %>% filter(rownames(.) == random_pos()[2])
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet5",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          
          tags$script(HTML(
            "$(document).ready(function(){
          $('iframe#tweet5').on('load', function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: 'height' },
              'https://twitframe.com');
          });
        });"))
          
        )
        
      }
      
      
      return(res)
      
    }
    
    
  })
  
  
  
  
  output$tweet_pos3 <- renderUI({
    
    if (is.null(data_tweet())){
      return(NULL)
    }else{
      
      if (is.na(random_pos()[1])){
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "positive") %>% filter(rownames(.) == 3)
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet6",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          
          tags$script(HTML(
            "$(document).ready(function(){
          $('iframe#tweet6').on('load', function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: 'height' },
              'https://twitframe.com');
          });
        });"))
          
        )
        
      }else{
        
        
        data <- data_tweet()[[1]] %>% mutate(id = as.character(id)) %>% filter(sentiment == "positive") %>% filter(rownames(.) == random_pos()[3])
        
        
        
        tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id"], sep = "")
        url <- URLencode(tweet, reserved = TRUE)
        src <- paste0("https://twitframe.com/show?url=", url)
        
        res <- tagList(
          tags$div(
            class = "content",
            tags$div(tags$iframe(
              id = "tweet6",
              border=0, frameborder=0, height="100%", width=550,
              src = src
            ))
          ),
          
          tags$script(HTML(
            "$(document).ready(function(){
          $('iframe#tweet6').on('load', function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: 'height' },
              'https://twitframe.com');
          });
        });"))
          
        )
        
      }
      
      
      
      
      return(res)
      
    }
    
    
  })
  
  
  geo <- reactive({
    
    if (!is.null(input$hashtag_select_map)){
      
      loc <- geocoded_data %>% mutate(n=1) %>% filter(hashtag %in% c(input$hashtag_select_map))
    }else{
      
      loc <- NULL
    }
    
    return(loc)
    
  })
  
  
  
  output$outpt_map <- renderEcharts4r({
    
    geo() %>%
      e_charts(x = longitude) %>%
      e_globe(
        environment = ea_asset("starfield"),
        base_texture = ea_asset("world"), 
        globeOuterRadius = 100
      ) %>%
      e_scatter_3d(latitude,n, coord_system = "globe", blendMode = 'lighter') %>%
      e_visual_map() 
  })
  
  
  
  
  geo_react <- eventReactive(input$outpt_map_clicked_row,{
    return(input$outpt_map_clicked_row)
  })
  
  
  output$geo_tweet <- renderUI({
    
    if (!is.null(input$outpt_map_clicked_row)){
      
      data <- geo() %>% arrange(longitude)
      
      data <- data[geo_react(),]
      
      
      
      tweet <- paste("https://twitter.com/Twitter/status/", data[1,"id_tweet"], sep = "")
      url <- URLencode(tweet, reserved = TRUE)
      src <- paste0("https://twitframe.com/show?url=", url)
      
      res <- tagList(
        
        tags$div(
          class = "content",
          tags$div(tags$iframe(
            id = "tweet7",
            border=0, frameborder=0, width=550,scrolling="no",
            src = src
          ))
        ),
        tags$script(HTML(
          "$(document).ready(function(){
          $('iframe#tweet7').on('load', function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: 'height' },
              'https://twitframe.com');
          });
        });"))
      )
      
      return(res)
      
    }else{
      
      return(NULL)
    }
  })
  
  
  
  ############## NETWORK ###########
  
  
  data_network <- reactive({
    
    tweets_network <- search_tweets(paste(input$hashtag_select_network," filter:retweets", sep = ''), n = 250, include_rts = TRUE, token = token_R)
    
    
    try(net <- tweets_network %>% 
          gt_edges(screen_name, retweet_screen_name) %>% 
          gt_nodes() %>% 
          gt_collect())
    
    c(edges, nodes) %<-% net
    
    edges$id <- 1:nrow(edges)
    edges$size <- edges$n
    
    nodes$id <- nodes$nodes
    nodes$label <- nodes$nodes
    nodes$size <- nodes$n
    
    nodes <- nodes %>% select(-c(nodes, type, n))
    edges <-edges %>% select(-c(n, size))
    
    return(list(tweets_network, nodes, edges))
    
  })
  
  get_id_tweet <- eventReactive(input$graph_click_node,{
    
    datab <- data_network()[[1]] %>% mutate(mentions_screen_name = str_to_lower(mentions_screen_name))%>%filter(mentions_screen_name == str_to_lower(unlist(input$graph_click_node$id))) %>% arrange(desc(retweet_count)) 
    datab <- datab[1,]
    datab <- datab %>% select(mentions_screen_name, retweet_location, retweet_count, retweet_status_id) %>% distinct(.)
    return(datab)
  })
  
  output$nb_retweet <- renderText({
    return(as.character(get_id_tweet()$retweet_count))
  })
  
  output$loc_retweet <- renderText({
    return(as.character(get_id_tweet()$retweet_location))
  })
  
  
  output$tweet_network_display <- renderUI({
    
    
    
    tweet <- paste("https://twitter.com/Twitter/status/",get_id_tweet()$retweet_status_id[1] , sep = "")
    url <- URLencode(tweet, reserved = TRUE)
    src <- paste0("https://twitframe.com/show?url=", url)
    
    res <- tagList(
      tags$div(
        class = "content",
        tags$div(tags$iframe(
          id = "tweet8",
          border=0, frameborder=0, height="100%", width=550,
          src = src
        ))
      ),
      tags$script(HTML(
        '$(document).ready(function(){
          $("iframe#tweet8").on("load", function() {
            this.contentWindow.postMessage(
              { element: {id:this.id}, query: "height" },
              "https://twitframe.com");
          });
        });
        '))
      
    )
    
    return(res)
    
    
  })
  
  
  
  output$graph <- renderSigmajs({
    sigmajs() %>%
      sg_nodes(data_network()[[2]], id, size) %>%
      sg_edges(data_network()[[3]], id, source, target) %>%
      sg_events("clickNode") %>%
      sg_layout() %>% 
      sg_cluster(colors = c("#0C46A0FF", "#41A5F4FF")) %>% 
      sg_settings(
        edgeColor = "default",
        defaultEdgeColor = "#d3d3d3"
      ) %>% 
      sg_neighbours() 
  })
  
  
  
  
  
  
}