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
                   box(width=NULL,status="warning",title="Comparison Inputs",solidHeader = TRUE,
                       uiOutput("selectGym1"),
                       uiOutput("selectGym2")
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
                   box(width = NULL,status = "info", title="Inputs", solidHeader=TRUE,
                       uiOutput("longGym"),
                       uiOutput("longDay")
                   )
            )
            
        ),
        tabItem(
            tabName="about"
        )
    )
)

shinyUI(dashboardPage(
    header,
    sideBar,
    body
))