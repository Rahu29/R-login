library(shiny)
library(shinydashboard)
library(DT)
library(shinyjs)
library(sodium)

# Main login screen
loginpage <- div(id = "loginpage", style = "width: 500px; max-width: 100%; margin: 0 auto; padding: 20px;",
                 wellPanel(
                   tags$h2("LOG IN", class = "text-center", style = "padding-top: 0;color:#333; font-weight:600;"),
                   textInput("userName", placeholder="Username", label = tagList(icon("user"), "Username")),
                   passwordInput("passwd", placeholder="Password", label = tagList(icon("unlock-alt"), "Password")),
                   br(),
                   div(
                     style = "text-align: center;",
                     actionButton("login", "SIGN IN", style = "color: white; background-color:#3c8dbc;
                                 padding: 10px 15px; width: 150px; cursor: pointer;
                                 font-size: 18px; font-weight: 600;"),
                     shinyjs::hidden(
                       div(id = "nomatch",
                           tags$p("Oops! Incorrect username or password!",
                                  style = "color: red; font-weight: 600; 
                                            padding-top: 5px;font-size:16px;", 
                                  class = "text-center"))),
                     br(),
                     br(),
                     tags$code("Username: myuser  Password: mypass"),
                     br(),
                     tags$code("Username: myuser1  Password: mypass1")
                   ))
)

credentials = data.frame(
  username_id = c("myuser", "myuser1"),
  passod   = sapply(c("mypass", "mypass1"),password_store),
  permission  = c("basic", "advanced"), 
  stringsAsFactors = F
)

header <- dashboardHeader( title = "Simple Dashboard", uiOutput("logoutbtn"))

sidebar <- dashboardSidebar(uiOutput("sidebarpanel")) 
body <- dashboardBody(shinyjs::useShinyjs(), uiOutput("body"))
ui<-dashboardPage(header, sidebar, body, skin = "blue")

server <- function(input, output, session) {
  
  login = FALSE
  USER <- reactiveValues(login = login)
  
  observe({ 
    if (USER$login == FALSE) {
      if (!is.null(input$login)) {
        if (input$login > 0) {
          Username <- isolate(input$userName)
          Password <- isolate(input$passwd)
          if(length(which(credentials$username_id==Username))==1) { 
            pasmatch  <- credentials["passod"][which(credentials$username_id==Username),]
            pasverify <- password_verify(pasmatch, Password)
            if(pasverify) {
              USER$login <- TRUE
            } else {
              shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
              shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
            }
          } else {
            shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
            shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
          }
        } 
      }
    }    
  })
  
  output$logoutbtn <- renderUI({
    req(USER$login)
    tags$li(a(icon("fa fa-sign-out"), "Logout", 
              href="javascript:window.location.reload(true)"),
            class = "dropdown", 
            style = "background-color: #eee !important; border: 0;
                    font-weight: bold; margin:5px; padding: 10px;")
  })
  
  output$sidebarpanel <- renderUI({
    if (USER$login == TRUE ){ 
      sidebarMenu(
        menuItem("Main Page", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("Second Page", tabName = "second", icon = icon("th"))
      )
    }
  })
  
  output$body <- renderUI({
    if (USER$login == TRUE ) {
      tabItems(
      
      # First tab
      tabItem(tabName ="dashboard", class = "active",
              fluidRow(
                box(width = 12, dataTableOutput('results'))
              )),
      
      # Second tab
      tabItem(tabName = "second",
              fluidRow(
                box(width = 12, dataTableOutput('results2'))
              )
      ))
      
    }
    else {
      loginpage
    }
  })
  
  output$results <-  DT::renderDataTable({
    datatable(iris, options = list(autoWidth = TRUE,
                                   searching = FALSE))
  })
  
  output$results2 <-  DT::renderDataTable({
    datatable(mtcars, options = list(autoWidth = TRUE,
                                   searching = FALSE))
  })
  
  
}

runApp(list(ui = ui, server = server), launch.browser = TRUE)

 
How to customize the program
In the above program, two user names and passwords are defined
Username : myuser Password : mypass Username : myuser1 Password : mypass1. To change them, you can edit the following code in R program.
 
credentials = data.frame(
  username_id = c("myuser", "myuser1"),
  passod   = sapply(c("mypass", "mypass1"),password_store),
  permission  = c("basic", "advanced"), 
  stringsAsFactors = F
  )
In order to modify sidebar section, you can edit the following section of code.
    if (USER$login == TRUE ){ 
      sidebarMenu(
        menuItem("Main Page", tabName = "dashboard", icon = icon("dashboard"))
      )
    }
In order to edit main body of the app, you can make modification in the following section of code.
  if (USER$login == TRUE ) {
      tabItem(tabName ="dashboard", class = "active",
              fluidRow(
                box(width = 12, dataTableOutput('results'))
              ))
    }
    else {
      loginpage
    }
Suppose you want to show multiple tabs if permission level is set "advanced". Otherwise show a single tab. If you login with credentials Username : myuser1 Password : mypass1, you would find two tabs. Else it would show only one tab named "Main Page". Replace renderUI function of output$sidebarpanel and output$body with the following script.
  output$sidebarpanel <- renderUI({
    if (USER$login == TRUE ){ 
      if (credentials[,"permission"][which(credentials$username_id==input$userName)]=="advanced") {
        sidebarMenu(
        menuItem("Main Page", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("About Page", tabName = "About", icon = icon("th"))
        )
      }
      else{
        sidebarMenu(
          menuItem("Main Page", tabName = "dashboard", icon = icon("dashboard"))
        )
        
      }
    }
  })
  
  
  output$body <- renderUI({
    if (USER$login == TRUE ) {
    if (credentials[,"permission"][which(credentials$username_id==input$userName)]=="advanced") {
    tabItems(
              tabItem(
               tabName ="dashboard", class = "active",
               fluidRow(
                box(width = 12, dataTableOutput('results'))
              ))
        ,
          tabItem(
            tabName ="About",
            h2("This is second tab")
              )
    )
    } 
      else {
        tabItem(
          tabName ="dashboard", class = "active",
          fluidRow(
            box(width = 12, dataTableOutput('results'))
          ))
              }
    
    }
    else {
      loginpage
    }
  })