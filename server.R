library(shiny)
library(shinydashboard)
library(mongolite)
library(plotly)
library(dplyr)
library(tidyr)



longData <-read.csv("./chartGym.csv",header=TRUE,colClasses = c("factor","numeric","factor","numeric"))

shinyServer(function(input,output,session){
    con <- mongo("results",url="mongodb://public:public@ds037415.mongolab.com:37415/gym")
    
    getNewData <- function(){
        my_data <- con$find(limit=720,sort='{"$natural":-1}')
        new_data <- my_data$results
        new_data$time <- as.POSIXct(my_data$time,format="%a, %d %b %Y %H:%M:%S +0000")
        rm(my_data)
        new_data <- gather(new_data,"gym","percentage",1:16)
        new_data$percentage<-as.numeric(sub("%", "", new_data$percentage))
        new_data$gym <- sapply(new_data$gym,niceName)
        new_data$gym <- factor(new_data$gym)
        return (new_data)
    }
    
    getReactiveData <- reactive({
        invalidateLater(60000,session)
        getNewData()})
    
    getAllLatestData<- reactive({
        new_data <- getReactiveData()
        latestTime <- max(new_data$time)
        new_data1 <- new_data %>%
            filter(time==latestTime) %>%
            arrange(desc(percentage))
        new_data1
    })
    
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
    
    output$comparisonPlot <- renderPlotly({
        new_data <- getReactiveData()
        new_data <- filter(new_data,gym==input$gym1|gym==input$gym2)
        g<-ggplot(new_data,aes(time,percentage,col=gym))+geom_line(size=0.01)+ggtitle(paste(input$gym1,"vs",input$gym2))
        ggplotly(g)
    })
    
    output$selectGym1 <- renderUI({
        newData <- c("Bishan","Bedok","Bukit Gombak","Choa Chu Kang","Clementi",
                     "Delta","Hougang","Jurong East","Jurong West","Pasir Ris",
                     "Seng Kang","Tampines","Toa Payoh", "Woodlands","Yio Chu Kang",
                     "Yishun")
        selectInput("gym1", "First Gym", choices = newData, selected = newData[1])
    })
    output$longGym <- renderUI({
        newData <- c("Bishan","Bedok","Bukit Gombak","Choa Chu Kang","Clementi",
                     "Delta","Hougang","Jurong East","Jurong West","Pasir Ris",
                     "Seng Kang","Tampines","Toa Payoh", "Woodlands","Yio Chu Kang",
                     "Yishun")
        selectInput("longGym", "Select Gym", choices = newData, selected = newData[1])
    })
    
    output$longDay <- renderUI({
        newData <- c("Sun","Mon","Tues","Wed","Thurs","Fri","Sat","Sun")
        selectInput("longDay", "Select Day", choices = newData, selected = newData[5])
    })
    output$selectGym2 <- renderUI({
        newData <- c("Bishan","Bedok","Bukit Gombak","Choa Chu Kang","Clementi",
                     "Delta","Hougang","Jurong East","Jurong West","Pasir Ris",
                     "Seng Kang","Tampines","Toa Payoh", "Woodlands","Yio Chu Kang",
                     "Yishun")
        selectInput("gym2", "Second Gym", choices = newData, selected = newData[1])
    })
    
    output$longTerm <- renderPlotly({
        newData <- longData[longData$gym==input$longGym&longData$day==input$longDay,]
        g <- ggplot(newData,aes(hour,percentage))+geom_point(col="orange",alpha=0.04)+
            geom_smooth(col="black",alpha=0.4,size=0.01)+
            ggtitle(paste(input$longGym,"Capacity on",input$longDay))
        ggplotly(g)
        
    })
    
    output$realTimeTable <- renderUI({
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