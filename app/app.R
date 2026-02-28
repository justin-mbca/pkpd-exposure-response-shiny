# app/app.R
# Shiny Dashboard for Clinical PK/PD Exposure-Response Analysis
# Author: Senior Clinical PK/PD R Developer

library(shiny)
library(tidyverse)
library(ggplot2)
library(data.table)
library(survival)

# Load data
dm <- fread("data_adam/dm_clean.csv")
exposure <- fread("data_adam/exposure_full.csv")
logit_summary <- fread("data_adam/logit_summary.csv")
cox_summary <- fread("data_adam/cox_summary.csv")

ui <- fluidPage(
  titlePanel("Clinical PK/PD Exposure-Response Analysis Demo"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dose", "Dose Group", choices = unique(dm$DOSE), selected = unique(dm$DOSE), multiple = TRUE),
      sliderInput("cmax", "Cmax Range", min = min(exposure$Cmax), max = max(exposure$Cmax), value = range(exposure$Cmax)),
      sliderInput("auc", "AUC Range", min = min(exposure$AUC), max = max(exposure$AUC), value = range(exposure$AUC))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Data Overview", DT::dataTableOutput("table_dm")),
        tabPanel("PK Visualization", plotOutput("boxplot_cmax")),
        tabPanel("Exposure-Response", plotOutput("scatter_er")),
        tabPanel("Survival Analysis", plotOutput("km_curve"))
      )
    )
  )
)

server <- function(input, output, session) {
  filtered_dm <- reactive({
    dm %>% filter(DOSE %in% input$dose)
  })
  filtered_exposure <- reactive({
    exposure %>% filter(Cmax >= input$cmax[1], Cmax <= input$cmax[2], AUC >= input$auc[1], AUC <= input$auc[2])
  })

  output$table_dm <- DT::renderDataTable({
    filtered_dm()
  })

  output$boxplot_cmax <- renderPlot({
    ggplot(left_join(filtered_exposure(), dm, by = "USUBJID"), aes(x = factor(DOSE), y = Cmax)) +
      geom_boxplot() +
      labs(title = "Cmax by Dose Group", x = "Dose", y = "Cmax")
  })

  output$scatter_er <- renderPlot({
    ggplot(left_join(filtered_exposure(), dm, by = "USUBJID"), aes(x = Cmax, y = RESPONSE)) +
      geom_jitter(width = 0.1, height = 0.05) +
      labs(title = "Exposure-Response Scatter Plot", x = "Cmax", y = "Response")
  })

  output$km_curve <- renderPlot({
    exp_data <- filtered_exposure() %>% mutate(EXP_Q = ntile(AUC, 4))
    fit <- survfit(Surv(SURV_TIME, STATUS) ~ EXP_Q, data = exp_data)
    plot(fit, col = 1:4, lwd = 2, xlab = "Time", ylab = "Survival Probability", main = "Kaplan-Meier Curve by Exposure Quartile")
    legend("bottomleft", legend = paste("Quartile", 1:4), col = 1:4, lwd = 2)
  })
}

shinyApp(ui, server)
