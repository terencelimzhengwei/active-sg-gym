library(shiny)
library(shinydashboard)
library(mongolite)
library(plotly)
library(dplyr)
library(tidyr)

########## Function to load long term gym data from csv########################

loadLongData <- function(){
    print("Loading Long Term Data")
    return (read.csv("./chartGym.csv",header=TRUE,colClasses = c("factor","numeric","factor","numeric")))
}

########## Load Long Term data ###############################################

longData <- loadLongData()

###################################################

######## Open Database Connection #################

con <- mongo("results",url="mongodb://public:public@ds037415.mongolab.com:37415/gym")

######### List of Gym Names #######################

gymNames <- c("Bishan","Bedok","Bukit Gombak","Choa Chu Kang","Clementi",
             "Delta","Hougang","Jurong East","Jurong West","Pasir Ris",
             "Seng Kang","Tampines","Toa Payoh", "Woodlands","Yio Chu Kang",
             "Yishun")

######## Function to retrieve latest 720 data from database ##################
getNewData <- function(){
    print("Getting new Data")
    my_data <- con$find(limit=720,sort='{"$natural":-1}')
    new_data <- my_data$results
    print("new_data <- my_data$results")
    new_data$time <- as.POSIXct(my_data$time,format="%a, %d %b %Y %H:%M:%S +0000")
    print("convert time")
    rm(my_data)
    print("remove my data")
    new_data <- gather(new_data,"gym","percentage",1:16)
    print("gather data")
    new_data$percentage<-as.numeric(sub("%", "", new_data$percentage))
    print("convert to percentage")
    new_data$gym <- sapply(new_data$gym,niceName)
    print("nicename")
    new_data$gym <- factor(new_data$gym)
    print("factorise")
    return (new_data)
}

######### Function to convert db gym name to presentable name ##################

niceName <-function(gym){
    new_name <-switch(as.character(gym),
                      "bedok"="Bedok",
                      "bishan"="Bishan",
                      "bukit_gombak"="Bukit Gombak",
                      "choa_chu_kang"="Choa Chu Kang",
                      "clementi"="Clementi",
                      "delta"="Delta",
                      "hougang"="Hougang",
                      "jurong_east"="Jurong East",
                      "jurong_west"="Jurong West",
                      "pasir_ris"="Pasir Ris",
                      "seng_kang"="Seng Kang",
                      "tampines"="Tampines",
                      "toa_payoh"="Toa Payoh",
                      "woodlands"="Woodlands",
                      "yio_chu_kang"="Yio Chu Kang",
                      "yishun"="Yishun")
    return(new_name)
}

######## Start Shiny Server ###################################################
shinyServer(function(input,output,session){
    
    
    ### Retrieve latest 720 data every 60 seconds ###
    getReactiveData <- reactive({
        invalidateLater(60000,session)
        print("Retrieving new data")
        getNewData()})
    
    ### From latest 720 data, return only the row with the most current timing ##
    getAllLatestData<- reactive({
        print("Getting Latest new Data")
        new_data <- getReactiveData()
        latestTime <- max(new_data$time)
        new_data1 <- new_data %>%
            filter(time==latestTime) %>%
            arrange(desc(percentage))
        new_data1
    })
    
    ## Get the relevant data required for     ##
    ## realtime data analysis based on inputs ##
    
    getComparisonPlotData <- reactive({
        print("Getting Comparison Plot Data")
        validate(
            need(input$gym1, "Waiting for inputs to register..."),
            need(input$gym2, "Please wait while graph is plotted....")
        )
        new_data <- filter(getReactiveData(),gym==input$gym1|gym==input$gym2)
    })
    
    ## Filter long term data based on inputs
    getLongTermData <- reactive ({
        print("Filtering longterm data based on inputs")
        validate(
            need(input$longGym, "Waiting for inputs to register..."),
            need(input$longDay, "Please wait while graph is plotted....")
        )
        longData[longData$gym==input$longGym&longData$day==input$longDay,]
    })
    
    ## Render real time comparison plot ##
    output$comparisonPlot <- renderPlotly({
        print("Plotting comparison plot real time")
        g<-ggplot(getComparisonPlotData(),aes(time,percentage,col=gym))+geom_line(size=0.01)+ggtitle(paste(input$gym1,"vs",input$gym2))
        ggplotly(g)
    })
    
    ## Render selection for gym 1 input ##
    output$selectGym1 <- renderUI({
        print("Rendering select gym1")
        newData <- gymNames
        selectInput("gym1", "First Gym", choices = newData, selected = newData[1])
    })
    
    ## Render selection for long term gym selection input ##
    output$longGym <- renderUI({
        print("Rendering longterm gym names")
        newData <- gymNames
        selectInput("longGym", "Select Gym", choices = gymNames, selected = gymNames[1])
    })
    
    ## Render selection for long term day selection input ##
    output$longDay <- renderUI({
        print("Rendering longterm gym days")
        newData <- c("Sun","Mon","Tues","Wed","Thurs","Fri","Sat","Sun")
        selectInput("longDay", "Select Day", choices = newData, selected = newData[5])
    })
    
    ## Reneder selection for gym 2 for real time input ##
    output$selectGym2 <- renderUI({
        print("Rendering gym2")
        newData <- gymNames
        selectInput("gym2", "Second Gym", choices = gymNames, selected = gymNames[1])
    })
    
    ## Render long term plot ##
    output$longTerm <- renderPlotly({
        print("Plotting long term data")
        g <- ggplot(getLongTermData(),aes(hour,percentage))+geom_point(col="orange",alpha=0.04)+
            geom_smooth(col="black",alpha=0.4,size=0.01)+
            ggtitle(paste(input$longGym,"Capacity on",input$longDay))
        ggplotly(g)
        
    })
    
    ## Render real time gym capacity table ##
    output$realTimeTable <- renderUI({
        print("Rendering table")
        tableData <- getAllLatestData()
        
        tags$table(class = "table",
                   tags$thead(
                       tags$tr(
                           tags$th("Gym"),
                           tags$th("Percentage"))
                   ),
                   tags$tbody(
                       tags$tr(
                           tags$td(tableData[1,]$gym),
                           tags$td(tableData[1,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[2,]$gym),
                           tags$td(tableData[2,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[3,]$gym),
                           tags$td(tableData[3,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[4,]$gym),
                           tags$td(tableData[4,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[5,]$gym),
                           tags$td(tableData[5,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[6,]$gym),
                           tags$td(tableData[6,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[7,]$gym),
                           tags$td(tableData[7,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[8,]$gym),
                           tags$td(tableData[8,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[9,]$gym),
                           tags$td(tableData[9,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[10,]$gym),
                           tags$td(tableData[10,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[11,]$gym),
                           tags$td(tableData[11,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[12,]$gym),
                           tags$td(tableData[12,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[13,]$gym),
                           tags$td(tableData[13,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[14,]$gym),
                           tags$td(tableData[14,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[15,]$gym),
                           tags$td(tableData[15,]$percentage)
                       ),
                       tags$tr(
                           tags$td(tableData[16,]$gym),
                           tags$td(tableData[16,]$percentage)
                       )
                   )
        )
    })
})