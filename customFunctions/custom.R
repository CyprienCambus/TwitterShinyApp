argonProfile <- function(..., title = NULL, subtitle = NULL, src = NULL, url = NULL,
                         url_1 = NULL, url_2 = NULL) {
  htmltools::tags$div(
    class = "card card-profile shadow",
    htmltools::tags$div(
      class = "px-4",
      # header
      htmltools::tags$div(
        class = "row justify-content-center",
        # profile image
        htmltools::tags$div(
          class = "col-lg-3 order-lg-2",
          htmltools::tags$div(
            class = "card-profile-image",
            htmltools::a(
              href = NULL,
              htmltools::img(src = src, class = "rounded-circle")
            )
          )
        ),
        # button
        htmltools::tags$div(
          class = "col-lg-4 order-lg-3 text-lg-right align-self-lg-center",
          htmltools::tags$div(
            class = "card-profile-actions py-4 mt-lg-0"
          )
        ),
        # stat items
        argonProfileStats(
          argonProfileStat(
            value = "",
            description = ""
          )
        )
      ),
      
      # Title
      br(),
      htmltools::tags$div(
        class = "text-center mt-5",
        htmltools::h3(title),
        htmltools::tags$div(class = "h6 font-weight-300", subtitle)
      ),
      
      # Content
      htmltools::tags$div(
        class = "mt-5 py-5 border-top text-center",
        htmltools::tags$div(
          class = "row justify-content-center",
          htmltools::tags$div(
            class = "col-lg-9",
            htmltools::p(...),
            htmltools::a(href = url, target = "_blank", "Visit my Covid Dashboard App")
          )
        )
      )
    )
  )
}
