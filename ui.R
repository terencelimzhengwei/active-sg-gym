library(shiny)
library(shinydashboard)
library(mongolite)
library(plotly)
library(dplyr)
library(tidyr)

header <- dashboardHeader(title="ActiveSG Gym Capacity",titleWidth=250)
sideBar <- dashboardSidebar(width=250,
                            sidebarMenu(
                                menuItem("Real-Time Capacity",tabName="realTime",icon=icon("line-chart")),
                                menuItem("Long-term Capacity Trend",tabName="longTerm",icon=icon("bar-chart")),
                                menuItem("About",tabName="about",icon=icon("info-circle")))
)
body <- dashboardBody(
    tabItems(
        tabItem(
            tabName="realTime",
            column(8,
                   box(width=NULL,status="primary",title="Real Time Comparison Plots", solidHeader=TRUE,
                       plotlyOutput("comparisonPlot")
                   ),
                   fluidRow(
                       box(width=6,status="warning",title="Comparison Inputs",solidHeader = TRUE,
                           uiOutput("selectGym1"),
                           uiOutput("selectGym2")
                       ),
                       box(width=6,status="info",title="About",solidHeader = TRUE,
                           p("This section shows the real time capacity of ActiveSG Gyms in Singapore (updated per minute). Please be patient as the data takes some time to load."),
                           br(),
                           p("If you want to compare the capacity of various gyms, please change the selection inputs accordingly. I hope this application helps you decide on the best
                             time/location for your workout.")
                       )
                       
                   )
            ),
            column(4,
                   box(width = NULL,status = "info", title="Real-Time Capacity", solidHeader=TRUE,
                       uiOutput("realTimeTable")
                   )
            )
        ),
        tabItem(
            tabName="longTerm",
            column(8,
                   box(width=NULL,status="primary",title="Long Term Trends", solidHeader=TRUE,
                       plotlyOutput("longTerm")
                   )
            ),
            column(4,
                   box(width = NULL,status = "warning", title="About", solidHeader=TRUE,
                       p("This section shows the long term trend of gym capacity over the past few months. Please be patient as the charts takes some time to load."),
                       br(),
                       p("The orange points represent the actual data points collected.
                          The darker the colour, the more frequent the occurence of that capacity."),
                       br(),
                       p("The black line represents the general trend of capacity based on the data."),
                       br(),
                       p("To view the trends of gym capacity for different gyms on different days, please change the inputs accordingly.")
                   ),
                   box(width = NULL,status = "info", title="Inputs", solidHeader=TRUE,
                       uiOutput("longGym"),
                       uiOutput("longDay")
                   )
            )
            
        ),
        tabItem(
            tabName="about",
            column(4,
                   box(width = NULL,status = "primary", title="About me", solidHeader=TRUE,
                       p("Summary : Just an average joe who likes to learn more about anything techy:D"),
                       br(),
                       p("1. Terence is what people call me."),
                       p("2. National University of Singapore is where I come from."),
                       p("3. Industrial and Systems Engineering is what I study.")
                   ),
                   box(width = NULL,status = "warning", title="Project Description", solidHeader=TRUE,
                       p("Wouldn't it be nice if you knew when the gym was the least crowded so you could have all the weights to yourself? 
                         That was how this whole project idea started."),
                       br(),
                       p("In order to analyse the gym capacity trends of ActiveSG gyms in Singapore, I created a script to collect data of ActiveSG Gym Capacity automatically
                         using Python and running it on my handy dandy raspberry pi as a cron job."),
                       br(),
                       p("The data collected is then used to create the visualisations that you see on this website. This website is built using Shiny and the source code
                          can be found at the link below"),
                       a(href="https://github.com/terencelimzhengwei/active-sg-gym","Click here for source code!")
                       )
            )
        )
    )
)

shinyUI(dashboardPage(
    header,
    sideBar,
    body
))