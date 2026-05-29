library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(scales)
library(plotly)

# ============================================================
# COLOR PALETTE
# ============================================================
brand_colors <- c("#FF7651","#F25D71","#D2528D","#A257A4","#7359AA","#315B9F",
                  "#FF9B6E","#F47B8F","#D9689F","#B26DB6","#886BC2","#4A7ABF")
get_cybercolors <- function(n) rep_len(brand_colors, n)

# ============================================================
# LOAD DATA
# ============================================================
if (!file.exists("Sales Data..csv")) stop("Error: Sales Data..csv not found.")
df <- tryCatch({
  read_csv("Sales Data..csv") %>%
    mutate(
      Date      = as.Date(Date),
      Month     = factor(Month, levels = month.name),
      Quarter   = factor(Quarter, levels = c("Q1","Q2","Q3","Q4")),
      Month_Num = as.integer(Month_Num),
      Year      = as.integer(Year)
    )
}, error = function(e) stop(paste("Error loading CSV:", e$message)))

# ============================================================
# CSS – with expand buttons matching value boxes
# ============================================================
modern_css <- HTML("
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');
  * { font-family: 'Inter', 'Segoe UI', sans-serif !important; }
  body, .content-wrapper, .right-side { background: #F8FAFC !important; color: #1E293B !important; }
  
  /* header */
  .main-header .logo {
    width: 280px !important; background: #FFFFFF !important; font-weight: 700 !important;
    font-size: 16px !important; white-space: nowrap !important; overflow: visible !important;
    padding: 0 5px !important; height: 60px !important; line-height: 60px !important;
    color: #0F172A !important; border-bottom: 1px solid #E2E8F0 !important;
  }
  .main-header .navbar {
    margin-left: 280px !important; background: #FFFFFF !important;
    min-height: 55px !important; border-bottom: 1px solid #E2E8F0 !important;
  }
  
  /* sidebar – scrollable and toggle works */
  .main-sidebar {
    width: 280px !important;
    background: #FFFFFF !important;
    border-right: 1px solid #E2E8F0 !important;
    overflow-y: auto !important;
    overflow-x: hidden !important;
    max-height: 100vh !important;
  }
  .sidebar-wrapper {
    padding-bottom: 20px !important;
  }
  
  /* content – reduced top spacing */
  .content-wrapper {
    padding-top: 8px !important;
    margin-left: 280px !important;
    transition: margin-left 0.3s ease !important;
  }
  .sidebar-collapse .content-wrapper {
    margin-left: 0 !important;
  }
  .tab-content {
    padding-top: 0 !important;
  }
  
  /* toggle icon */
  .sidebar-toggle {
    color: #475569 !important;
    background: transparent !important;
  }
  .sidebar-toggle:hover { color: #315B9F !important; background: #F1F5F9 !important; }
  .sidebar-toggle:before {
    content: \"\\f0c9\" !important;
    font-family: \"Font Awesome 5 Free\" !important;
    font-weight: 900 !important;
    font-size: 15px !important;
  }
  .sidebar-toggle .fa, .sidebar-toggle .fas, .sidebar-toggle .far { display: none !important; }
  
  /* sidebar menu – fixed: text on one line, extra top space */
  .sidebar-menu {
    margin: 0;
    padding: 0;
    list-style: none;
    padding-top: 20px !important;
  }
  .sidebar-menu > li {
    margin: 0;
    position: relative;
  }
  .sidebar-menu > li > a {
    display: block;
    padding: 12px 18px 12px 25px !important;
    font-size: 14px !important;
    font-weight: 500 !important;
    color: #334155 !important;
    border-left: 3px solid transparent !important;
    transition: all 0.2s ease;
    white-space: nowrap !important;
    overflow: hidden;
    text-overflow: ellipsis;
    line-height: 1.4 !important;
  }
  /* Allow wrapping on very small screens (e.g., mobile sidebar open) */
  @media (max-width: 768px) {
    .sidebar-menu > li > a {
      white-space: normal !important;
      word-break: break-word;
    }
  }
  .sidebar-menu > li.active > a {
    background: #EFF6FF !important;
    color: #315B9F !important;
    border-left: 3px solid #315B9F !important;
    font-weight: 600 !important;
  }
  .sidebar-menu > li > a:hover {
    background: #F8FAFC !important;
    color: #7359AA !important;
    border-left: 3px solid #A257A4 !important;
  }
  .sidebar-menu > li > a > .fa,
  .sidebar-menu > li > a > .fas,
  .sidebar-menu > li > a > .far {
    margin-right: 8px;
    width: 20px;
    text-align: center;
  }
  .sidebar-menu .treeview-menu > li > a {
    padding-left: 45px !important;
  }
  
  /* value boxes - MORE VISIBLE */
  .small-box {
    border-radius: 20px !important;
    margin-bottom: 12px !important;
    min-height: 40px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 8px 12px !important;
    box-shadow: 0 8px 20px rgba(0,0,0,0.15), 0 2px 4px rgba(0,0,0,0.05) !important;
    border: none !important;
    background: linear-gradient(135deg, #8B5CF6 0%, #6D28D9 100%) !important;
    text-align: center !important;
    transition: transform 0.2s ease, box-shadow 0.2s ease !important;
  }
  .small-box:hover {
    transform: translateY(-3px) !important;
    box-shadow: 0 12px 28px rgba(0,0,0,0.25) !important;
    background: linear-gradient(135deg, #7C3AED 0%, #5B21B6 100%) !important;
  }
  .small-box .inner {
    padding: 0 !important;
    width: 100%;
  }
  .small-box h3 {
    font-size: 22px !important;
    font-weight: 800 !important;
    margin: 0 0 6px 0 !important;
    color: #FFFFFF !important;
    text-shadow: 0 1px 2px rgba(0,0,0,0.2) !important;
    letter-spacing: -0.3px !important;
  }
  .small-box p {
    font-size: 11px !important;
    font-weight: 700 !important;
    letter-spacing: 0.8px !important;
    text-transform: uppercase !important;
    color: #F3E8FF !important;
    margin: 0 !important;
  }
  .small-box .icon {
    display: none !important;
  }
  
  /* EXPAND BUTTONS – matching value boxes */
  .expand-btn {
    background: linear-gradient(135deg, #8B5CF6 0%, #6D28D9 100%) !important;
    color: white !important;
    border: none !important;
    border-radius: 30px !important;
    padding: 4px 14px !important;
    font-size: 11px !important;
    font-weight: 600 !important;
    text-transform: uppercase !important;
    letter-spacing: 0.5px !important;
    transition: transform 0.2s ease, box-shadow 0.2s ease !important;
    box-shadow: 0 2px 6px rgba(0,0,0,0.1) !important;
  }
  .expand-btn:hover {
    transform: translateY(-2px) !important;
    background: linear-gradient(135deg, #7C3AED 0%, #5B21B6 100%) !important;
    box-shadow: 0 6px 14px rgba(0,0,0,0.15) !important;
    color: white !important;
  }
  .expand-btn:active, .expand-btn:focus {
    background: linear-gradient(135deg, #6D28D9 0%, #4C1D95 100%) !important;
    outline: none !important;
  }
  
  /* chart boxes */
  .box { background-color: #FFFFFF !important; border-radius: 16px !important; border: 1px solid #E2E8F0 !important; border-left: 4px solid #315B9F !important; margin-bottom: 20px !important; }
  .box:hover { transform: translateY(-2px) !important; border-left: 4px solid #7359AA !important; }
  .box-header { border-bottom: 1px solid #F1F5F9 !important; padding: 10px 15px !important; background-color: #FAFAFE !important; }
  .box-title { font-weight: 700 !important; font-size: 13px !important; color: #1E293B !important; text-transform: uppercase !important; }
  .box-body { padding: 12px !important; background-color: #FFFFFF !important; }
  
  /* tables */
  .custom-table-wrapper { width: 100%; overflow-x: auto; }
  .custom-table { width: 100%; border-collapse: collapse; font-size: 13px; background: #FFFFFF; border-radius: 12px; }
  .custom-table thead tr { background: linear-gradient(90deg, #315B9F 0%, #7359AA 100%); color: #FFFFFF; }
  .custom-table thead th { padding: 10px 14px; font-size: 11px; text-transform: uppercase; }
  .custom-table tbody td { padding: 10px 14px; }
  .share-badge { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; }
  .progress-bar-wrap { width: 80px; display: inline-block; vertical-align: middle; margin-left: 6px; }
  .progress-bar-bg { background: #E2E8F0; border-radius: 4px; height: 6px; width: 100%; }
  .progress-bar-fill { height: 6px; border-radius: 4px; background: linear-gradient(90deg, #7359AA, #315B9F); }
  .tbl-search { width: 100%; padding: 8px 12px; margin-bottom: 12px; border: 1px solid #CBD5E1; border-radius: 10px; font-size: 13px; }
  .tbl-pagination { display: flex; align-items: center; justify-content: space-between; margin-top: 12px; font-size: 12px; }
  .download-btn { padding: 6px 16px; background: linear-gradient(135deg, #7359AA, #315B9F); color: #FFFFFF; border: none; border-radius: 10px; font-size: 13px; }
  
  /* modal */
  .modal-content { background-color: #FFFFFF !important; border-radius: 20px !important; }
  .modal-header .close { color: #1E293B !important; opacity: 0.8 !important; font-size: 28px !important; }
  .modal .js-plotly-plot .modebar { display: none !important; }
  
  /* mobile */
  @media (max-width: 768px) {
    .main-header .logo { width: 100% !important; text-align: center !important; font-size: 14px !important; }
    .main-header .navbar { margin-left: 0 !important; }
    .content-wrapper { margin-left: 0 !important; padding-top: 8px !important; }
    .main-sidebar { width: 280px !important; }
    .small-box h3 { font-size: 18px !important; }
    .small-box p { font-size: 9px !important; }
    .expand-btn { font-size: 9px !important; padding: 3px 10px !important; }
    .box-body { padding: 8px !important; }
    .col-sm-1,.col-sm-2,.col-sm-3,.col-sm-4,.col-sm-5,.col-sm-6,
    .col-sm-7,.col-sm-8,.col-sm-9,.col-sm-10,.col-sm-11,.col-sm-12 { padding-left: 5px !important; padding-right: 5px !important; }
    .row { margin-left: 0 !important; margin-right: 0 !important; }
  }
")

fast_resize_js <- tags$script(HTML("
  $(document).ready(function(){
    function resizeAllPlots() {
      document.querySelectorAll('.plotly-graph-div').forEach(function(div){
        if (div && div._fullLayout) Plotly.relayout(div, {autosize: true});
      });
      $(window).trigger('resize');
    }
    $(document).on('shown.bs.modal', function() { setTimeout(resizeAllPlots, 200); });
    $(window).on('resize', function() { setTimeout(resizeAllPlots, 100); });
    $(document).on('click', '.sidebar-toggle', function() { setTimeout(resizeAllPlots, 400); });
    setTimeout(resizeAllPlots, 500);
  });
"))

# ============================================================
# HELPER FUNCTIONS (clean HTML generation)
# ============================================================
build_segment_table_html <- function(df_input) {
  total <- sum(df_input$Total_Sale_BDT, na.rm = TRUE)
  s <- df_input %>%
    group_by(Customer_Segment) %>%
    summarise(
      sales_m = round(sum(Total_Sale_BDT) / 1e6, 2),
      orders = n(),
      avg_ord = round(mean(Total_Sale_BDT), 0),
      share = if (total > 0) round(sum(Total_Sale_BDT) / total * 100, 1) else 0,
      .groups = "drop"
    ) %>%
    arrange(desc(sales_m))
  
  max_sales <- max(s$sales_m, 1)
  rows <- c()
  for (i in 1:nrow(s)) {
    seg <- s$Customer_Segment[i]
    sales_m <- s$sales_m[i]
    orders <- s$orders[i]
    avg_ord <- s$avg_ord[i]
    share <- s$share[i]
    badge <- if (share >= 30) "high" else if (share >= 20) "med" else "low"
    bar_width <- round(sales_m / max_sales * 100)
    
    row_html <- paste0(
      '<tr>',
      '<td><strong>', seg, '</strong></td>',
      '<td class="num">৳', format(sales_m, nsmall = 1), 'M',
      '<span class="progress-bar-wrap">',
      '<span class="progress-bar-bg">',
      '<span class="progress-bar-fill" style="width:', bar_width, '%"></span>',
      '</span></span></td>',
      '<td class="num">', format(orders, big.mark = ","), '</td>',
      '<td class="num">৳', format(avg_ord, big.mark = ","), '</td>',
      '<td class="badge-cell"><span class="share-badge ', badge, '">', share, '%</span></td>',
      '</tr>'
    )
    rows <- c(rows, row_html)
  }
  
  paste0(
    '<div class="custom-table-wrapper">',
    '<table class="custom-table">',
    '<thead><tr><th>Segment</th><th>Total Sales</th><th>Orders</th><th>Avg Order</th><th>Share</th></tr></thead>',
    '<tbody>', paste(rows, collapse = ""), '</tbody>',
    '</table></div>'
  )
}

build_data_table_html <- function(df_input, page = 1, search = "", page_size = 10) {
  d <- df_input %>%
    select(Date, Year, Quarter, Month, Region, Vendor, Category, Product,
           Customer_Segment, Sales_Channel, Quantity, Unit_Price_BDT, Total_Sale_BDT)
  
  if (nchar(search) > 0) {
    search_lower <- tolower(search)
    d <- d %>%
      filter(
        grepl(search_lower, tolower(as.character(Date))) |
          grepl(search_lower, tolower(Region)) |
          grepl(search_lower, tolower(Vendor)) |
          grepl(search_lower, tolower(Category)) |
          grepl(search_lower, tolower(Product)) |
          grepl(search_lower, tolower(Customer_Segment)) |
          grepl(search_lower, tolower(Sales_Channel))
      )
  }
  
  total_rows <- nrow(d)
  total_pages <- max(1, ceiling(total_rows / page_size))
  page <- min(max(1, page), total_pages)
  start_row <- (page - 1) * page_size + 1
  end_row <- min(page * page_size, total_rows)
  
  if (total_rows > 0) {
    d_page <- d[start_row:end_row, ]
  } else {
    d_page <- d[0, ]
  }
  
  rows <- c()
  for (i in 1:nrow(d_page)) {
    r <- d_page[i, ]
    row_html <- paste0(
      '<tr>',
      '<td>', r$Date, '</td>',
      '<td class="num">', r$Year, '</td>',
      '<td>', r$Quarter, '</td>',
      '<td>', r$Month, '</td>',
      '<td>', r$Region, '</td>',
      '<td>', r$Vendor, '</td>',
      '<td>', r$Category, '</td>',
      '<td>', r$Product, '</td>',
      '<td>', r$Customer_Segment, '</td>',
      '<td>', r$Sales_Channel, '</td>',
      '<td class="num">', r$Quantity, '</td>',
      '<td class="num">৳', format(as.numeric(r$Unit_Price_BDT), big.mark = ",", nsmall = 0), '</td>',
      '<td class="num">৳', format(as.numeric(r$Total_Sale_BDT), big.mark = ",", nsmall = 0), '</td>',
      '</tr>'
    )
    rows <- c(rows, row_html)
  }
  
  page_info <- if (total_rows == 0) "No records found" else
    paste0("Showing ", start_row, "–", end_row, " of ", format(total_rows, big.mark = ","), " records")
  
  prev_disabled <- if (page <= 1) "disabled" else ""
  next_disabled <- if (page >= total_pages) "disabled" else ""
  
  table_html <- paste0(
    '<div class="custom-table-wrapper">',
    '<table class="custom-table" style="font-size:12px;">',
    '<thead><tr>',
    '<th>Date</th><th>Year</th><th>Qtr</th><th>Month</th>',
    '<th>Region</th><th>Vendor</th><th>Category</th><th>Product</th>',
    '<th>Segment</th><th>Channel</th><th>Qty</th><th>Unit Price</th><th>Total Sale</th>',
    '</tr></thead><tbody>'
  )
  
  if (length(rows) > 0) {
    table_html <- paste0(table_html, paste(rows, collapse = ""))
  } else {
    table_html <- paste0(table_html, '<tr><td colspan="13" style="text-align:center;color:#94A3B8;padding:30px;">No records found</td></tr>')
  }
  
  table_html <- paste0(
    table_html,
    '</tbody></table></div>',
    '<div class="tbl-pagination">',
    '<span>', page_info, '</span>',
    '<div style="display:flex;gap:8px;">',
    '<button onclick="Shiny.setInputValue(\'data_page\', ', max(1, page - 1), ', {priority: \'event\'})" ', prev_disabled, '>← Prev</button>',
    '<button onclick="Shiny.setInputValue(\'data_page\', ', min(total_pages, page + 1), ', {priority: \'event\'})" ', next_disabled, '>Next →</button>',
    '</div></div>'
  )
  
  return(table_html)
}

expand_button <- function(input_id, label = "⛶ Expand") {
  div(style = "text-align:right; margin-top:4px;", actionButton(input_id, label, class = "expand-btn"))
}

# ============================================================
# UI
# ============================================================
ui <- dashboardPage(
  dashboardHeader(title = tags$div(tags$span("iNS8Gain", style = "color:#0F172A;font-weight:700;")), titleWidth = 300),
  dashboardSidebar(
    width = 280,
    tags$head(tags$style(modern_css), fast_resize_js),
    sidebarMenu(
      menuItem("📊 OVERVIEW",          tabName = "overview"),
      menuItem("📦 REGION & PRODUCTS", tabName = "region_product"),
      menuItem("👥 CUSTOMERS",         tabName = "customer"),
      menuItem("📋 DATA",              tabName = "data")
    ),
    hr(),
    div(
      style = "padding:0 20px;",
      h5("FILTERS", style = "color:#475569;font-weight:700;"),
      selectInput("year_filter",     "YEAR",     choices = c("All", unique(df$Year)),    selected = "All"),
      selectInput("month_filter",    "MONTH",    choices = c("All", month.name),         selected = "All"),
      selectInput("quarter_filter",  "QUARTER",  choices = c("All", levels(df$Quarter)), selected = "All"),
      selectInput("region_filter",   "REGION",   choices = c("All", unique(df$Region)),  selected = "All"),
      selectInput("category_filter", "CATEGORY", choices = c("All", unique(df$Category)),selected = "All")
    )
  ),
  dashboardBody(
    tags$head(tags$style(modern_css)),
    tabItems(
      tabItem("overview",
              fluidRow(
                column(3, uiOutput("total_sales_box_ui")),
                column(3, uiOutput("most_sold_category_box_ui")),
                column(3, uiOutput("best_vendor_box_ui")),
                column(3, uiOutput("top_region_box_ui"))
              ),
              fluidRow(
                column(3, uiOutput("mom_change_box_ui")),
                column(3, uiOutput("avg_sales_box_ui")),
                column(3, uiOutput("total_orders_box_ui")),
                column(3, uiOutput("most_sold_product_box_ui"))
              ),
              br(),
              fluidRow(
                column(7, box(title = "MONTHLY SALES TREND", width = 12,
                              plotlyOutput("monthly_trend_plot", height = "350px"),
                              expand_button("expand_monthly"))),
                column(5, box(title = "SALES CHANNEL", width = 12,
                              plotlyOutput("channel_plot", height = "350px"),
                              expand_button("expand_channel")))
              ),
              fluidRow(
                column(5, box(title = "CUSTOMER SEGMENT", width = 12,
                              plotlyOutput("segment_plot", height = "350px"),
                              expand_button("expand_segment"))),
                column(7, box(title = "TOP 5 VENDORS", width = 12,
                              plotlyOutput("top_vendor_plot", height = "350px"),
                              expand_button("expand_top_vendor")))
              )
      ),
      tabItem("region_product",
              fluidRow(
                column(6, box(title = "SALES BY REGION", width = 12,
                              plotlyOutput("region_plot", height = "350px"),
                              expand_button("expand_region"))),
                column(6, box(title = "SALES BY CATEGORY", width = 12,
                              plotlyOutput("category_plot", height = "350px"),
                              expand_button("expand_category")))
              ),
              fluidRow(
                column(6, box(title = "TOP 10 VENDORS", width = 12,
                              plotlyOutput("vendor_plot", height = "350px"),
                              expand_button("expand_vendor"))),
                column(6, box(title = "TOP PRODUCTS", width = 12,
                              selectInput("selected_category", "SELECT CATEGORY",
                                          choices = unique(df$Category),
                                          selected = unique(df$Category)[1]),
                              plotlyOutput("top_products_plot", height = "350px"),
                              expand_button("expand_products")))
              )
      ),
      tabItem("customer",
              fluidRow(
                column(12, box(title = "QUARTERLY PERFORMANCE BY SEGMENT", width = 12,
                               plotlyOutput("quarter_segment_plot", height = "350px"),
                               expand_button("expand_quarter")))
              ),
              fluidRow(
                column(12, box(title = "SEGMENT SUMMARY", width = 12,
                               uiOutput("segment_summary_table")))
              )
      ),
      tabItem("data",
              fluidRow(
                column(12, box(title = "SALES DATA EXPLORER", width = 12,
                               tags$input(id = "data_search", type = "text",
                                          placeholder = "🔍  Search...", class = "tbl-search",
                                          oninput = "Shiny.setInputValue('data_search_val', this.value, {priority:'event'})"),
                               uiOutput("data_table_ui"), br(),
                               downloadButton("download_data", "⬇ DOWNLOAD CSV", class = "download-btn")
                ))
              )
      )
    )
  )
)

# ============================================================
# SERVER
# ============================================================
server <- function(input, output, session) {
  
  is_mobile <- reactive({
    w <- session$clientData$output_monthly_trend_plot_width
    if (is.null(w)) FALSE else w < 600
  })
  
  filtered_df <- reactive({
    d <- df
    if (input$year_filter != "All") d <- d %>% filter(Year == input$year_filter)
    if (input$month_filter != "All") d <- d %>% filter(Month == input$month_filter)
    if (input$quarter_filter != "All") d <- d %>% filter(Quarter == input$quarter_filter)
    if (input$region_filter != "All") d <- d %>% filter(Region == input$region_filter)
    if (input$category_filter != "All") d <- d %>% filter(Category == input$category_filter)
    d
  })
  
  data_page <- reactiveVal(1)
  data_search <- reactiveVal("")
  observeEvent(input$data_page, { data_page(input$data_page) })
  observeEvent(input$data_search_val, { data_search(input$data_search_val); data_page(1) })
  observeEvent(filtered_df(), { data_page(1) })
  
  output$segment_summary_table <- renderUI({
    req(filtered_df())
    HTML(build_segment_table_html(filtered_df()))
  })
  
  output$data_table_ui <- renderUI({
    req(filtered_df())
    HTML(build_data_table_html(filtered_df(), data_page(), data_search(), 10))
  })
  
  output$download_data <- downloadHandler(
    filename = function() paste0("sales_data_", Sys.Date(), ".csv"),
    content = function(file) write.csv(filtered_df(), file, row.names = FALSE)
  )
  
  custom_value_box <- function(value, subtitle) {
    tags$div(class = "small-box", tags$div(class = "inner", tags$h3(value), tags$p(subtitle)))
  }
  
  output$total_sales_box_ui <- renderUI({
    v <- sum(filtered_df()$Total_Sale_BDT, na.rm = TRUE)
    custom_value_box(paste0("৳", format(round(v / 1e6, 1), big.mark = ","), "M"), "TOTAL REVENUE")
  })
  output$most_sold_category_box_ui <- renderUI({
    v <- tryCatch(filtered_df() %>% group_by(Category) %>% summarise(s = sum(Total_Sale_BDT)) %>% arrange(desc(s)) %>% slice(1) %>% pull(Category), error = function(e) "None")
    custom_value_box(v, "TOP CATEGORY")
  })
  output$best_vendor_box_ui <- renderUI({
    v <- tryCatch(filtered_df() %>% group_by(Vendor) %>% summarise(s = sum(Total_Sale_BDT)) %>% arrange(desc(s)) %>% slice(1) %>% pull(Vendor), error = function(e) "None")
    custom_value_box(v, "BEST VENDOR")
  })
  output$top_region_box_ui <- renderUI({
    v <- tryCatch(filtered_df() %>% group_by(Region) %>% summarise(s = sum(Total_Sale_BDT)) %>% arrange(desc(s)) %>% slice(1) %>% pull(Region), error = function(e) "None")
    custom_value_box(v, "TOP REGION")
  })
  output$mom_change_box_ui <- renderUI({
    mt <- filtered_df() %>% group_by(Month_Num) %>% summarise(s = sum(Total_Sale_BDT), .groups = "drop") %>% arrange(Month_Num)
    if (nrow(mt) < 2) return(custom_value_box("N/A", "MOM CHANGE"))
    chg <- (mt$s[nrow(mt)] - mt$s[nrow(mt) - 1]) / mt$s[nrow(mt) - 1] * 100
    custom_value_box(paste0(ifelse(chg >= 0, "+", ""), round(chg, 1), "%"), "MOM CHANGE")
  })
  output$avg_sales_box_ui <- renderUI({
    v <- mean(filtered_df()$Total_Sale_BDT, na.rm = TRUE)
    if (is.na(v)) v <- 0
    custom_value_box(paste0("৳", format(round(v, 0), big.mark = ",")), "AVG ORDER VALUE")
  })
  output$total_orders_box_ui <- renderUI({
    custom_value_box(format(nrow(filtered_df()), big.mark = ","), "TOTAL ORDERS")
  })
  output$most_sold_product_box_ui <- renderUI({
    v <- tryCatch(filtered_df() %>% group_by(Product) %>% summarise(q = sum(Quantity)) %>% arrange(desc(q)) %>% slice(1) %>% pull(Product), error = function(e) "None")
    disp <- ifelse(nchar(v) > 30, paste0(substr(v, 1, 27), "..."), v)
    custom_value_box(disp, "MOST SOLD PRODUCT")
  })
  
  white_bg_layout <- function(p, is_modal = FALSE) {
    m <- if (is_modal) list(l = 60, r = 15, t = 25, b = 80)
    else if (is_mobile()) list(l = 40, r = 10, t = 20, b = 45)
    else list(l = 70, r = 40, t = 50, b = 60)
    p %>% layout(
      paper_bgcolor = "#FFFFFF", plot_bgcolor = "#FFFFFF",
      hoverlabel = list(bgcolor = "#1E293B", font = list(color = "#FFFFFF")),
      margin = m, autosize = TRUE
    )
  }
  reg_plot <- function(p) p
  
  # ========== MONTHLY TREND ==========
  get_monthly_plot <- function(is_modal = FALSE) {
    d <- filtered_df() %>%
      group_by(Month_Num, Month) %>%
      summarise(Sales = sum(Total_Sale_BDT), .groups = "drop") %>%
      arrange(Month_Num)
    if (!nrow(d)) return(plot_ly() %>% layout(annotations = list(text = "No data", x = 0.5, y = 0.5, showarrow = F)))
    d <- d %>% mutate(Sales_M = Sales / 1e6)
    peak <- d[which.max(d$Sales), ]
    low <- d[which.min(d$Sales), ]
    mc <- rep("#7359AA", nrow(d))
    if (nrow(peak) > 0) mc[which(d$Month_Num == peak$Month_Num)] <- "#FF7651"
    if (nrow(low) > 0) mc[which(d$Month_Num == low$Month_Num)] <- "#F25D71"
    p <- plot_ly(d, x = ~Month_Num, y = ~Sales_M, type = "scatter", mode = "lines+markers",
                 line = list(color = "#315B9F", width = if (is_modal) 2.5 else 2),
                 marker = list(size = if (is_modal) 10 else if (is_mobile()) 7 else 10, color = mc),
                 hovertemplate = "<b>%{text}</b><br>Sales: ৳%{y:.1f}M<extra></extra>", text = ~Month)
    if (nrow(peak) > 0) {
      p <- p %>% add_annotations(
        x = peak$Month_Num, y = peak$Sales_M,
        text = paste0("▲ ", peak$Month, " ", round(peak$Sales_M, 1), "M"),
        showarrow = TRUE, arrowhead = 2, arrowcolor = "#FF7651",
        ax = 0, ay = -38, arrowsize = 0.8,
        font = list(size = if (is_modal) 11 else 9, color = "#1E293B"),
        bgcolor = "rgba(255,255,255,0.85)", borderpad = 2
      )
    }
    if (nrow(low) > 0) {
      p <- p %>% add_annotations(
        x = low$Month_Num, y = low$Sales_M,
        text = paste0("▼ ", low$Month, " ", round(low$Sales_M, 1), "M"),
        showarrow = TRUE, arrowhead = 2, arrowcolor = "#F25D71",
        ax = 0, ay = 38, arrowsize = 0.8,
        font = list(size = if (is_modal) 11 else 9, color = "#1E293B"),
        bgcolor = "rgba(255,255,255,0.85)", borderpad = 2
      )
    }
    p %>% layout(
      xaxis = list(title = "Month", tickvals = 1:12, ticktext = month.abb, tickangle = 45,
                   tickfont = list(size = if (is_modal) 11 else 10, color = "#475569"),
                   gridcolor = "#F1F5F9", titlefont = list(color = "#475569", size = if (is_modal) 12 else 11)),
      yaxis = list(title = "Sales (M ৳)", gridcolor = "#F1F5F9",
                   titlefont = list(color = "#475569", size = if (is_modal) 12 else 11),
                   tickfont = list(color = "#475569")),
      showlegend = FALSE, autosize = TRUE
    ) %>% white_bg_layout(is_modal) %>% config(displayModeBar = FALSE) %>% reg_plot()
  }
  output$monthly_trend_plot <- renderPlotly({ get_monthly_plot(FALSE) })
  output$monthly_trend_modal_plot <- renderPlotly({ get_monthly_plot(TRUE) })
  
  # ========== REGION ==========
  make_region_plot <- function(is_modal = FALSE) {
    d <- filtered_df() %>% group_by(Region) %>% summarise(Sales = sum(Total_Sale_BDT)) %>% mutate(Sales_M = Sales / 1e6) %>% arrange(Sales_M)
    if (!nrow(d)) return(plot_ly() %>% layout(annotations = list(text = "No data", x = 0.5, y = 0.5, showarrow = F)))
    plot_ly(d, x = ~Sales_M, y = ~reorder(Region, Sales_M), type = "bar", orientation = "h",
            marker = list(color = ~Sales_M, colorscale = list(c(0, "#FF7651"), c(1, "#315B9F")), showscale = FALSE),
            hovertemplate = "<b>%{y}</b><br>Sales: ৳%{x:.1f}M<extra></extra>") %>%
      layout(xaxis = list(title = "Sales (Million ৳)"), yaxis = list(title = ""), height = NULL) %>%
      white_bg_layout(is_modal) %>% config(displayModeBar = FALSE) %>% reg_plot()
  }
  output$region_plot <- renderPlotly({ make_region_plot(FALSE) })
  output$region_modal_plot <- renderPlotly({ make_region_plot(TRUE) })
  
  # ========== TOP 10 VENDORS ==========
  make_vendor_plot <- function(is_modal = FALSE) {
    d <- filtered_df() %>% group_by(Vendor) %>% summarise(Sales = sum(Total_Sale_BDT)) %>% mutate(Sales_M = Sales / 1e6) %>%
      arrange(desc(Sales_M)) %>% slice_head(n = 10) %>% arrange(Sales_M)
    if (!nrow(d)) return(plot_ly() %>% layout(annotations = list(text = "No data", x = 0.5, y = 0.5, showarrow = F)))
    plot_ly(d, x = ~Sales_M, y = ~reorder(Vendor, Sales_M), type = "bar", orientation = "h",
            marker = list(color = get_cybercolors(nrow(d))),
            hovertemplate = "<b>%{y}</b><br>Sales: ৳%{x:.1f}M<extra></extra>") %>%
      layout(xaxis = list(title = "Sales (Million ৳)"), yaxis = list(title = ""), height = NULL) %>%
      white_bg_layout(is_modal) %>% config(displayModeBar = FALSE) %>% reg_plot()
  }
  output$vendor_plot <- renderPlotly({ make_vendor_plot(FALSE) })
  output$vendor_modal_plot <- renderPlotly({ make_vendor_plot(TRUE) })
  
  # ========== TOP 5 VENDORS ==========
  make_top_vendor_plot <- function(is_modal = FALSE) {
    d <- filtered_df() %>% group_by(Vendor) %>% summarise(Sales = sum(Total_Sale_BDT)) %>% mutate(Sales_M = Sales / 1e6) %>%
      arrange(desc(Sales_M)) %>% slice_head(n = 5) %>% arrange(Sales_M)
    if (!nrow(d)) return(plot_ly() %>% layout(annotations = list(text = "No data", x = 0.5, y = 0.5, showarrow = F)))
    plot_ly(d, x = ~Sales_M, y = ~reorder(Vendor, Sales_M), type = "bar", orientation = "h",
            marker = list(color = ~Sales_M, colorscale = list(c(0, "#D2528D"), c(1, "#7359AA")), showscale = FALSE),
            hovertemplate = "<b>%{y}</b><br>Sales: ৳%{x:.1f}M<extra></extra>") %>%
      layout(xaxis = list(title = "Sales (Million ৳)"), yaxis = list(title = ""), height = NULL) %>%
      white_bg_layout(is_modal) %>% config(displayModeBar = FALSE) %>% reg_plot()
  }
  output$top_vendor_plot <- renderPlotly({ make_top_vendor_plot(FALSE) })
  output$top_vendor_modal_plot <- renderPlotly({ make_top_vendor_plot(TRUE) })
  
  # ========== CATEGORY ==========
  make_category_plot <- function(is_modal = FALSE) {
    d <- filtered_df() %>% group_by(Category) %>% summarise(Sales = sum(Total_Sale_BDT)) %>% mutate(Sales_M = Sales / 1e6)
    if (!nrow(d)) return(plot_ly() %>% layout(annotations = list(text = "No data", x = 0.5, y = 0.5, showarrow = F)))
    if (!is_modal && is_mobile()) {
      d <- d %>% arrange(Sales_M)
      plot_ly(d, x = ~Sales_M, y = ~Category, type = "bar", orientation = "h",
              marker = list(color = get_cybercolors(nrow(d))),
              hovertemplate = "<b>%{y}</b><br>Sales: ৳%{x:.1f}M<extra></extra>") %>%
        layout(xaxis = list(title = "Sales (Million ৳)"), yaxis = list(title = "")) %>%
        white_bg_layout(FALSE) %>% config(displayModeBar = FALSE) %>% reg_plot()
    } else {
      d <- d %>% arrange(desc(Sales_M))
      plot_ly(d, x = ~Category, y = ~Sales_M, type = "bar",
              marker = list(color = get_cybercolors(nrow(d))),
              hovertemplate = "<b>%{x}</b><br>Sales: ৳%{y:.1f}M<extra></extra>") %>%
        layout(xaxis = list(title = "", tickangle = 25), yaxis = list(title = "Sales (Million ৳)"), height = NULL) %>%
        white_bg_layout(is_modal) %>% config(displayModeBar = FALSE) %>% reg_plot()
    }
  }
  output$category_plot <- renderPlotly({ make_category_plot(FALSE) })
  output$category_modal_plot <- renderPlotly({ make_category_plot(TRUE) })
  
  # ========== TOP PRODUCTS ==========
  make_top_products_plot <- function(is_modal = FALSE) {
    req(input$selected_category)
    d <- filtered_df() %>% filter(Category == input$selected_category) %>%
      group_by(Product) %>% summarise(Sales = sum(Total_Sale_BDT)) %>% mutate(Sales_M = Sales / 1e6) %>%
      arrange(desc(Sales_M)) %>% slice_head(n = 10) %>% arrange(Sales_M)
    if (!nrow(d)) return(plot_ly() %>% layout(annotations = list(text = "No data", x = 0.5, y = 0.5, showarrow = F)))
    d$Product_wrapped <- str_wrap(d$Product, if (is_modal) 40 else if (is_mobile()) 20 else 35)
    plot_ly(d, x = ~Sales_M, y = ~reorder(Product_wrapped, Sales_M), type = "bar", orientation = "h",
            marker = list(color = ~Sales_M, colorscale = list(c(0, "#F25D71"), c(1, "#A257A4")), showscale = FALSE),
            hovertemplate = "<b>%{customdata}</b><br>Sales: ৳%{x:.1f}M<extra></extra>", customdata = ~Product) %>%
      layout(xaxis = list(title = "Sales (Million ৳)"), yaxis = list(title = "", tickfont = list(size = if (is_modal) 10 else if (is_mobile()) 7 else 9)), height = NULL) %>%
      white_bg_layout(is_modal) %>% config(displayModeBar = FALSE) %>% reg_plot()
  }
  output$top_products_plot <- renderPlotly({ make_top_products_plot(FALSE) })
  output$top_products_modal_plot <- renderPlotly({ make_top_products_plot(TRUE) })
  
  # ========== CUSTOMER SEGMENT ==========
  make_segment_plot <- function(is_modal = FALSE) {
    d <- filtered_df() %>% group_by(Customer_Segment) %>% summarise(Sales = sum(Total_Sale_BDT)) %>%
      mutate(Sales_M = Sales / 1e6, Pct = Sales / sum(Sales) * 100)
    if (!nrow(d)) return(plot_ly() %>% layout(annotations = list(text = "No data", x = 0.5, y = 0.5, showarrow = F)))
    plot_ly(d, x = ~reorder(Customer_Segment, -Sales_M), y = ~Sales_M, type = "bar",
            marker = list(color = get_cybercolors(nrow(d))),
            hovertemplate = "<b>%{x}</b><br>Sales: ৳%{y:.1f}M<br>Share: %{customdata:.1f}%<extra></extra>", customdata = ~Pct) %>%
      layout(xaxis = list(title = "", tickangle = if (!is_modal && is_mobile()) 40 else 20), yaxis = list(title = "Sales (Million ৳)"), height = NULL) %>%
      white_bg_layout(is_modal) %>% config(displayModeBar = FALSE) %>% reg_plot()
  }
  output$segment_plot <- renderPlotly({ make_segment_plot(FALSE) })
  output$segment_modal_plot <- renderPlotly({ make_segment_plot(TRUE) })
  
  # ========== SALES CHANNEL ==========
  make_channel_plot <- function(is_modal = FALSE) {
    d <- filtered_df() %>% group_by(Sales_Channel) %>% summarise(Sales = sum(Total_Sale_BDT)) %>%
      mutate(Pct = Sales / sum(Sales) * 100)
    if (!nrow(d)) return(plot_ly() %>% layout(annotations = list(text = "No data", x = 0.5, y = 0.5, showarrow = F)))
    plot_ly(d, labels = ~Sales_Channel, values = ~Sales, type = "pie",
            textinfo = "label+percent", textposition = "inside",
            insidetextfont = list(color = "white", size = if (is_modal) 16 else if (is_mobile()) 10 else 14),
            marker = list(colors = get_cybercolors(nrow(d)), line = list(color = "white", width = if (is_modal) 3 else 2)),
            hovertemplate = "<b>%{label}</b><br>Sales: ৳%{value:,.0f}<br>Share: %{percent}<extra></extra>") %>%
      layout(showlegend = TRUE,
             legend = list(orientation = "h", yanchor = "bottom", y = if (is_modal) -0.15 else -0.2,
                           xanchor = "center", x = 0.5,
                           font = list(size = if (is_modal) 14 else if (is_mobile()) 9 else 12, color = "#1E293B")),
             margin = list(b = if (is_modal) 100 else if (is_mobile()) 60 else 80), height = NULL) %>%
      white_bg_layout(is_modal) %>% config(displayModeBar = FALSE) %>% reg_plot()
  }
  output$channel_plot <- renderPlotly({ make_channel_plot(FALSE) })
  output$channel_modal_plot <- renderPlotly({ make_channel_plot(TRUE) })
  
  # ========== QUARTERLY SEGMENT ==========
  make_quarter_segment_plot <- function(is_modal = FALSE) {
    d <- filtered_df() %>% group_by(Quarter, Customer_Segment) %>% summarise(Sales = sum(Total_Sale_BDT), .groups = "drop") %>%
      mutate(Sales_M = Sales / 1e6)
    if (!nrow(d)) return(plot_ly() %>% layout(annotations = list(text = "No data", x = 0.5, y = 0.5, showarrow = F)))
    plot_ly(d, x = ~Quarter, y = ~Sales_M, color = ~Customer_Segment, type = "bar",
            colors = get_cybercolors(length(unique(d$Customer_Segment))),
            hovertemplate = "<b>%{x} - %{customdata}</b><br>Sales: ৳%{y:.1f}M<extra></extra>", customdata = ~Customer_Segment) %>%
      layout(barmode = "group", xaxis = list(title = "Quarter"), yaxis = list(title = "Sales (Million ৳)"),
             legend = list(orientation = "h", yanchor = "top", y = -0.1,
                           font = list(size = if (!is_modal && is_mobile()) 8 else 11, color = "#1E293B")),
             height = NULL) %>%
      white_bg_layout(is_modal) %>% config(displayModeBar = FALSE) %>% reg_plot()
  }
  output$quarter_segment_plot <- renderPlotly({ make_quarter_segment_plot(FALSE) })
  output$quarter_segment_modal_plot <- renderPlotly({ make_quarter_segment_plot(TRUE) })
  
  # ========== MODAL TRIGGERS ==========
  modal_plot_height <- "78vh"
  observeEvent(input$expand_monthly,   { showModal(modalDialog(title = "Monthly Sales Trend – Detailed View", size = "l", easyClose = TRUE, footer = modalButton("Close"), plotlyOutput("monthly_trend_modal_plot", height = modal_plot_height))) })
  observeEvent(input$expand_channel,   { showModal(modalDialog(title = "Sales Channel – Detailed View", size = "l", easyClose = TRUE, footer = modalButton("Close"), plotlyOutput("channel_modal_plot", height = modal_plot_height))) })
  observeEvent(input$expand_segment,   { showModal(modalDialog(title = "Customer Segment – Detailed View", size = "l", easyClose = TRUE, footer = modalButton("Close"), plotlyOutput("segment_modal_plot", height = modal_plot_height))) })
  observeEvent(input$expand_top_vendor,{ showModal(modalDialog(title = "Top 5 Vendors – Detailed View", size = "l", easyClose = TRUE, footer = modalButton("Close"), plotlyOutput("top_vendor_modal_plot", height = modal_plot_height))) })
  observeEvent(input$expand_region,    { showModal(modalDialog(title = "Sales by Region – Detailed View", size = "l", easyClose = TRUE, footer = modalButton("Close"), plotlyOutput("region_modal_plot", height = modal_plot_height))) })
  observeEvent(input$expand_category,  { showModal(modalDialog(title = "Sales by Category – Detailed View", size = "l", easyClose = TRUE, footer = modalButton("Close"), plotlyOutput("category_modal_plot", height = modal_plot_height))) })
  observeEvent(input$expand_vendor,    { showModal(modalDialog(title = "Top 10 Vendors – Detailed View", size = "l", easyClose = TRUE, footer = modalButton("Close"), plotlyOutput("vendor_modal_plot", height = modal_plot_height))) })
  observeEvent(input$expand_products,  { showModal(modalDialog(title = "Top Products – Detailed View", size = "l", easyClose = TRUE, footer = modalButton("Close"), plotlyOutput("top_products_modal_plot", height = modal_plot_height))) })
  observeEvent(input$expand_quarter,   { showModal(modalDialog(title = "Quarterly Performance – Detailed View", size = "l", easyClose = TRUE, footer = modalButton("Close"), plotlyOutput("quarter_segment_modal_plot", height = modal_plot_height))) })
}

shinyApp(ui, server)