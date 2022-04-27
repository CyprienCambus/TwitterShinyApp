
if (!Sys.info()[['user']] == 'cyprien-cambus'){
  # When running on shinyapps.io, create a virtualenv
  envs<-reticulate::virtualenv_list()
  if(!'venv_shiny_app' %in% envs)
  {
    reticulate::virtualenv_create(envname = 'venv_shiny_app',
                                  python = "/usr/bin/python3")
    reticulate::virtualenv_install('venv_shiny_app',
                                   packages = c('numpy',
                                                'nltk',
                                                "langdetect",
                                                "pycountry",
                                                "sklearn",
                                                "tweepy",
                                                "text2emotion",
                                                "deep_translator",
                                                'pandas',
                                                "textblob"))
  }
}


git_refs <- function(){
  shiny::tagList(br(), br(), br(),
                 tags$a(target = "_blank",
                        href = "https://linkedin.com/in/cyprien-cambus",
                        HTML('<h3>Linkedin<i class="material-icons"></i></h3>')),
                 br(), br(), 
                 tags$a(target = "_blank",
                        href = "https://github.com",
                        HTML('<h3>GitHub<i class="material-icons"></i></h3>')),
                 "Coming soon",
                 br(),
                 br(),
                 br(),
                 tags$a(target = "_blank",
                        href = "https://www.data.gouv.fr/fr/pages/donnees-coronavirus/",
                        HTML('<h3>Data sources<i class="material-icons"></i></h3>'))
  )
}


PYTHON_DEPENDENCIES <- c('numpy',
                         'nltk',
                         "langdetect",
                         "pycountry",
                         "sklearn",
                         "tweepy",
                         "text2emotion",
                         "deep_translator",
                         'pandas',
                         "textblob")


load.emojifont("EmojiOne.ttf")


library(sigmajs)
library(shiny)
library(dplyr)
library(argonR)
library(argonDash)
library(magrittr)
library(shinyWidgets)
library(echarts4r)
library(reticulate)
library(echarts4r.assets)
library(emojifont)
library(shinycssloaders)
library(rtweet)
library(igraph)
library(tidyverse)
library(graphTweets)

consumerKey = "YOUR_CONSUMER_KEY"
consumerSecret = "YOUR_CONSUMER_SECRET"
accessToken = "YOUR_ACCES_TOKEN"
accessTokenSecret = "YOUR_ACCES_TOKEN_SECRET"
## Create Twitter token
token_R <- create_token(
  app = "cyprien",
  consumer_key = consumerKey,
  consumer_secret = consumerSecret,
  access_token =accessToken,
  access_secret = accessTokenSecret)

reticulate::source_python('python/get_sentiments.py')
load("data/woeid_data.RData")
load("data/table_lang.RData")
load("data/geocoded_data.RData")


countries <- sort(woeid_data$country, decreasing = FALSE)
# template
source("sidebar.R")
source("header.R")
source("footer.R")

source("customFunctions/custom.R")


js <- '

$(window).on("message", function(e) {

  var oe = e.originalEvent;

  if (oe.origin !== "https://twitframe.com")

    return;


  if (oe.data.height && oe.data.element.id === "tweet1" ){


    $("#tweet1").css("height", parseInt(oe.data.height) + "px");

  }else if(oe.data.height && oe.data.element.id === "tweet2" ){

    $("#tweet2").css("height", parseInt(oe.data.height) + "px");

  }else if(oe.data.height && oe.data.element.id === "tweet3" ){

    $("#tweet3").css("height", parseInt(oe.data.height) + "px");

  }else if(oe.data.height && oe.data.element.id === "tweet4" ){

    $("#tweet4").css("height", parseInt(oe.data.height) + "px");

  }else if(oe.data.height && oe.data.element.id === "tweet5" ){

    $("#tweet5").css("height", parseInt(oe.data.height) + "px");

  }else if(oe.data.height && oe.data.element.id === "tweet6" ){

    $("#tweet6").css("height", parseInt(oe.data.height) + "px");

  }else if(oe.data.height && oe.data.element.id === "tweet7" ){

    $("#tweet7").css("height", parseInt(oe.data.height) + "px");

  }else if(oe.data.height && oe.data.element.id === "tweet8" ){

    $("#tweet8").css("height", parseInt(oe.data.height) + "px");

  }

});'
