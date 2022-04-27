argonSidebar <- argonDashSidebar(
  tags$head(tags$style(
    type="text/css",
    "#my_sidebar img {max-width: 500px; width: 150px; height: auto}
    @media(max-width:767.98px){
      #my_sidebar img {width: 100px;}
    }
    "
  ),
  tags$style("
  @media(max-width:767.98px){
    #sidenav-collapse-main {
    position: relative;
}
.navbar-collapse .collapse-brand img {

    width: 46px!important;
}
  }
  "),
  tags$style(".navbar-vertical.navbar-expand-md .navbar-brand-img {
  max-height: 10rem;
}"),tags$style(".navbar-vertical.navbar-expand-md {
    position: fixed;
    top: 0;
    bottom: 0;
    display: block;
    overflow-y: auto;
    width: 100%;
    max-width: 250px;
    padding-right: 1.5rem;
    padding-left: 1.5rem;
    overflow-y: unset;
}
    @media(max-width:767.98px){

      .navbar-vertical.navbar-expand-md {position: relative;max-width: 100%;}
      .d-md-none {display: none;}
    }
")),
  
  
  vertical = TRUE,
  skin = "light",
  background = "white",
  size = "md",
  side = "left",
  id = "my_sidebar",
  brand_url = "https://www.linkedin.com/in/cyprien-cambus/",
  brand_logo = 'https://i.ibb.co/ZH2dJKm/hex-Twitter-Feelings.png',
  
  br(), br(),br(), 

  argonSidebarHeader(title = "Main Menu"),
  argonSidebarMenu(
    argonSidebarItem(
      tabName = "tweet_discover",
      icon = argonIcon(name = "compass-04", color = "info"),
      "Discover"
    ),
    argonSidebarItem(
      tabName = "maps",
      icon = argonIcon(name = "planet", color = "green"),
      "Map them!"
    ),
    argonSidebarItem(
      tabName = "cluster",
      icon = argonIcon(name = "planet", color = "blue"),
      "Retweet"
    ),
    argonSidebarItem(
      tabName = "about_me",
      icon = argonIcon(name = "badge", color = "warning"),
      "About me"
    ),
    argonSidebarItem(
      tabName = "links",
      icon = argonIcon(name = "bold-right", color = "default"),
      "Links"
    )
    # argonSidebarItem(
    #   tabName = "tabs",
    #   icon = argonIcon(name = "planet", color = "warning"),
    #   "Tabs"
    # ),
    # argonSidebarItem(
    #   tabName = "alerts",
    #   icon = argonIcon(name = "bullet-list-67", color = "danger"),
    #   "Alerts"
    # ),
    # argonSidebarItem(
    #   tabName = "medias",
    #   icon = argonIcon(name = "circle-08", color = "success"),
    #   "Medias"
    # ),
    # argonSidebarItem(
    #   tabName = "items",
    #   icon = argonIcon(name = "ui-04", color = "pink"),
    #   "Other items"
    # ),
    # argonSidebarItem(
    #   tabName = "effects",
    #   icon = argonIcon(name = "atom", color = "black"),
    #   "CSS effects"
    # ),
    # argonSidebarItem(
    #   tabName = "sections",
    #   icon = argonIcon(name = "credit-card", color = "grey"),
    #   "Sections"
    # )
  )

)