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
  fluidRow(
    column(
      width = 3,
      wellPanel(
        selectInput("dose", "Dose Group", choices = unique(dm$DOSE), selected = unique(dm$DOSE), multiple = TRUE),
        sliderInput("cmax", "Cmax Range", min = floor(min(exposure$Cmax)), max = ceiling(max(exposure$Cmax)), value = c(floor(min(exposure$Cmax)), ceiling(max(exposure$Cmax)))),
        sliderInput("auc", "AUC Range", min = floor(min(exposure$AUC)), max = ceiling(max(exposure$AUC)), value = c(floor(min(exposure$AUC)), ceiling(max(exposure$AUC)))),
        selectInput("subject", "Select Subject for AUC Plot", choices = unique(dm$USUBJID), selected = unique(dm$USUBJID)[1]),
        tags$hr(),
        tags$b("Variable Definitions and Logic:"),
        tags$ul(
          tags$li(tags$b("Dose Group:"), " Subjects are assigned to different dose groups (e.g., 50, 100, 200 mg). Higher doses generally result in higher drug concentrations and greater exposure."),
          tags$li(tags$b("Cmax:"), " The maximum (peak) concentration of drug in blood after dosing. Higher doses typically lead to higher Cmax. The Cmax range slider allows you to filter subjects by their peak concentration."),
          tags$li(tags$b("AUC (Area Under the Curve):"), " The total drug exposure over time, calculated as the area under the concentration-time curve. Higher doses result in greater AUC. The AUC range slider lets you filter subjects by their overall exposure."),
          tags$li(tags$b("Logic:"), " Dose is a key driver of both Cmax and AUC. By adjusting the dose group, Cmax range, and AUC range, you can explore how increasing dose affects PK metrics and clinical outcomes. Filtering helps identify subgroups, outliers, and relationships between exposure and response.")
        )
      )
    ),
    column(
      width = 9,
      tabsetPanel(
        tabPanel("Data Overview",
          tags$div(
            tags$h4("Tab: Data Overview"),
            tags$p("View subject demographics and dosing information. Use filters to explore specific dose groups. Data table is interactive for sorting and searching."),
            shiny::wellPanel(
              tags$b("Interpretation Guidance:"),
              tags$p("Check for expected subject distribution across dose groups. Confirm demographic balance and dosing compliance.")
            )
          ),
          DT::dataTableOutput("table_dm")
        ),
        tabPanel("PK Visualization",
          tags$div(
            tags$h4("Tab: PK Visualization"),
            tags$p("Visualize Cmax distribution by dose group. Filter by dose, Cmax, and AUC to explore PK variability and group differences."),
            shiny::wellPanel(
              tags$b("Interpretation Guidance:"),
              tags$p("Boxplots should show increasing Cmax with higher dose. Use AUC plots to check for expected PK profiles and outliers.")
            ),
            plotOutput("boxplot_cmax"),
            tags$br(),
            tags$h5("Concentration-Time Profile with AUC (Selected Subject)"),
            plotOutput("auc_plot")
          )
        ),
        tabPanel("Exposure-Response",
          tags$div(
            tags$h4("Tab: Exposure-Response"),
            tags$p("Explore the relationship between drug exposure (Cmax) and clinical response. Scatter plot updates with filters for dose and exposure metrics."),
            shiny::wellPanel(
              tags$b("Interpretation Guidance:"),
              tags$p("Look for increasing response rates with higher Cmax. Outliers or flat trends may indicate limited exposure-response effect.")
            )
          ),
          plotOutput("scatter_er")
        ),
        tabPanel("Survival Analysis",
          tags$div(
            tags$h4("Tab: Survival Analysis"),
            tags$p("View Kaplan-Meier survival curves by exposure quartile. Assess survival probabilities and compare across exposure levels."),
            shiny::wellPanel(
              tags$b("Interpretation Guidance:"),
              tags$p("Higher exposure quartiles should show improved or similar survival. Large differences may indicate exposure-dependent efficacy.")
            )
          ),
          plotOutput("km_curve")
        ),
        tabPanel("Safety Analysis",
          tags$div(
            tags$h4("Tab: Safety Analysis"),
            tags$p("Review adverse event (AE) rates by dose and exposure quartile. Assess safety profile across groups."),
            shiny::wellPanel(
              tags$b("Interpretation Guidance:"),
              tags$p("Check for increasing AE rates with higher dose or exposure. Consistent rates suggest no new safety signal.")
            )
          ),
          plotOutput("ae_rate_dose"),
          plotOutput("ae_rate_expq")
        ),
        tabPanel("QC Results",
          tags$div(
            tags$h4("Tab: QC Results"),
            tags$p("Automated QC checks for missing values and outliers in exposure data."),
            shiny::wellPanel(
              tags$b("Interpretation Guidance:"),
              tags$p("Ideally, there should be no critical missing values or outliers. Review flagged records for data integrity.")
            )
          ),
          DT::dataTableOutput("qc_missing"),
          DT::dataTableOutput("qc_outliers")
        ),
        tabPanel("Documentation",
          tags$div(
            tags$h4("Project Workflow & Supporting Files"),
            tags$p("This tab summarizes the end-to-end workflow and provides links to key supporting files in the GitHub repository."),
            tags$ol(
              tags$li("Data Simulation: ",
                tags$a(href = "https://github.com/justin-mbca/pkpd-exposure-response-shiny/blob/main/R/data_simulation.R", "R/data_simulation.R", target = "_blank")),
              tags$li("Data Cleaning & QC: ",
                tags$a(href = "https://github.com/justin-mbca/pkpd-exposure-response-shiny/blob/main/R/data_cleaning.R", "R/data_cleaning.R", target = "_blank")),
              tags$li("PK Derivations: ",
                tags$a(href = "https://github.com/justin-mbca/pkpd-exposure-response-shiny/blob/main/R/derivations_exposure.R", "R/derivations_exposure.R", target = "_blank")),
              tags$li("Exposure-Response Modeling: ",
                tags$a(href = "https://github.com/justin-mbca/pkpd-exposure-response-shiny/blob/main/R/modeling_exposure_response.R", "R/modeling_exposure_response.R", target = "_blank")),
              tags$li("TLF Generation: ",
                tags$a(href = "https://github.com/justin-mbca/pkpd-exposure-response-shiny/blob/main/R/tlf_generation.R", "R/tlf_generation.R", target = "_blank")),
              tags$li("QC Validation: ",
                tags$a(href = "https://github.com/justin-mbca/pkpd-exposure-response-shiny/blob/main/R/qc_validation.R", "R/qc_validation.R", target = "_blank")),
              tags$li("Quarto Report: ",
                tags$a(href = "https://github.com/justin-mbca/pkpd-exposure-response-shiny/blob/main/report/analysis_report.qmd", "report/analysis_report.qmd", target = "_blank")),
              tags$li("README & Overview: ",
                tags$a(href = "https://github.com/justin-mbca/pkpd-exposure-response-shiny/blob/main/README.md", "README.md", target = "_blank"))
            ),
            tags$br(),
            tags$p("All files are available in the GitHub repository: ",
              tags$a(href = "https://github.com/justin-mbca/pkpd-exposure-response-shiny", "https://github.com/justin-mbca/pkpd-exposure-response-shiny", target = "_blank"))
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
      ae <- fread("data_sdtm/ae.csv")
      qc_missing <- fread("data_adam/qc_missing_exposure.csv")
      qc_outliers <- fread("data_adam/qc_outliers.csv")
      # Safety AE rate by dose
      output$ae_rate_dose <- renderPlot({
        ae_rate <- ae[, .(AE_Rate = mean(AE_YN == 1, na.rm = TRUE)), by = DOSE]
        ggplot(ae_rate, aes(x = factor(DOSE), y = AE_Rate * 100)) +
          geom_bar(stat = "identity", fill = "#e6550d") +
          labs(title = "AE Rate by Dose Group", x = "Dose", y = "AE Rate (%)") +
          ylim(0, 100)
      })
      # Safety AE rate by exposure quartile
      output$ae_rate_expq <- renderPlot({
        # Merge AE with exposure to get AUC
        ae_exp <- merge(ae, exposure, by = "USUBJID", all.x = TRUE)
        ae_exp <- ae_exp[!is.na(AUC)]
        ae_exp[, EXP_Q := ntile(AUC, 4)]
        ae_rate_q <- ae_exp[, .(AE_Rate = mean(AE_YN == 1, na.rm = TRUE)), by = EXP_Q]
        ggplot(ae_rate_q, aes(x = factor(EXP_Q), y = AE_Rate * 100)) +
          geom_bar(stat = "identity", fill = "#e6550d") +
          labs(title = "AE Rate by Exposure Quartile", x = "Exposure Quartile (AUC)", y = "AE Rate (%)") +
          ylim(0, 100)
      })
      # QC tables
      output$qc_missing <- DT::renderDataTable({
        qc_missing
      })
      output$qc_outliers <- DT::renderDataTable({
        qc_outliers
      })
    pc <- fread("data_adam/pc_clean.csv")
    output$auc_plot <- renderPlot({
      subj_data <- pc[USUBJID == input$subject]
      ggplot(subj_data, aes(x = TIME, y = CONC)) +
        geom_line(color = "#2c7fb8", size = 1.2) +
        geom_point(color = "#2c7fb8") +
        geom_area(fill = "#a6bddb", alpha = 0.5) +
        labs(title = paste("AUC Calculation for", input$subject), x = "Time (h)", y = "Concentration")
    })
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
