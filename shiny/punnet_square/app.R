library(shiny)

####
#### TODO: fix duplicate row names
####


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  tags$head(
    tags$style(HTML("
      th, td {
        text-align: center;
        padding: 15px;
      }

      td:hover {background-color: #f5f5f5}

      body {
        background-color: #fff;
      }
      "))
  ),
  
  # Application title
  titlePanel("Pullet Square"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      textInput("mom","Maternal Genotype",value = "AB"),
      textInput("dad","Paternal Genotype",value = "CD")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      uiOutput("offspring")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  library(xtable)
  
  bold <- function(x){
    paste0('<font color="#3182bd"><b>', x, '</b></font>') }
  
  uniqueify <- function(x){
    if( length(unique(x)) == length(x) )
      return(x)
    x <- make.unique(x,sep="<sub>")
    reps <- stringi::stri_detect(x,fixed="<sub>")
    for( i in 1:length(x)){
      if( reps[i] == TRUE)
        x[i] <- paste(x[i],"</sub>",sep="")
    }
    return( x )
  }
  
  output$offspring <- renderUI({
    
    mom <- as.character(strsplit(as.character(input$mom), split="")[[1]])
    dad <- as.character(strsplit(as.character(input$dad), split="")[[1]])
    if( length(mom)>0 & length(dad)>0 ) {
      x <- matrix(NA,nrow=length(dad),ncol=length(mom))
      for( i in 1:length(mom)){
        for( j in 1:length(dad)){
          x[j,i] <- paste(sort(c(mom[i],dad[j])),collapse="")
        }
      }
      
      df <- as.data.frame( x )
      names(df) <- uniqueify(mom)
      rownames(df) <- uniqueify(dad)
      tab <- xtable(df) 
      align(tab) <- paste(c("c|",rep("c",length(mom))),collapse="")
      
      caption <- paste("Offspring genotypes for ",input$mom," x ", input$dad," mating.",sep="")
      
      
      
      p <- print( xtable(df,caption=caption), type="html",
                  sanitize.rownames.function=bold,
                  sanitize.colnames.function=bold,
                  print.results = FALSE,
                  caption.placement="top")
      HTML( p )
      
    }
    
  } )
}

# Run the application 
shinyApp(ui = ui, server = server)

