# iNS8Gain Sales-Dashboard
An **interactive sales analytics dashboard** built with R Shiny, `shinydashboard`, and `plotly`. It provides real-time insights into sales performance, customer behavior, product trends, and regional distribution through dynamic filtering and rich visualizations.

<img width="1920" height="1122" alt="screencapture-nirjhar-nakib-shinyapps-io-iNS8Gain-2026-05-29-09_37_11" src="https://github.com/user-attachments/assets/20e26d9d-085a-4cfc-bb6f-427ce368d684" />


## ✨ Features

- **8 Key Performance Indicators (KPIs)** – Total revenue, MoM change, average order value, top category/vendor/region, total orders, best-selling product.
- **Dynamic filtering** – Filter data by year, month, quarter, region, and category. All charts update instantly.
- **Interactive plots** (built with `plotly`):
  - Monthly sales trend (with peak/low annotations)
  - Sales by region (horizontal bar chart)
  - Top 10 vendors & top 5 vendors
  - Sales by category
  - Top products per selected category
  - Customer segment distribution (bar chart + share)
  - Sales channel breakdown (pie chart)
  - Quarterly performance by customer segment (grouped bar chart)
- **Expandable modals** – Every plot has an "Expand" button that opens a larger, high‑detail version in a modal.
- **Customer segment summary table** – Custom HTML table with sales, orders, average order value, and share (with progress bars).
- **Sales data explorer** – Fully searchable, paginated table of all sales records with CSV download.
- **Mobile‑responsive CSS** – Optimized layout for desktops, tablets, and phones.
- **Modern, clean UI** – Custom gradient value boxes, smooth hover effects, and a crisp color palette.

---

## 📊 Data Requirements

The dashboard expects a CSV file named `Sales Data..csv` in the working directory with the following columns:

| Column name          | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `Date`               | Transaction date (will be parsed as `Date`)                                 |
| `Year`               | Year (integer)                                                              |
| `Month`              | Full month name (e.g., "January") – will be ordered                       |
| `Month_Num`          | Month number (1–12)                                                         |
| `Quarter`            | Quarter (Q1, Q2, Q3, Q4)                                                    |
| `Region`             | Sales region                                                               |
| `Vendor`             | Vendor name                                                                |
| `Category`           | Product category                                                           |
| `Product`            | Product name                                                               |
| `Customer_Segment`   | Customer segment (e.g., "Small Business", "Consumer")                      |
| `Sales_Channel`      | Channel (e.g., "Online", "Retail")                                         |
| `Quantity`           | Number of units sold                                                       |
| `Unit_Price_BDT`     | Unit price in Bangladeshi Taka (BDT)                                       |
| `Total_Sale_BDT`     | Total sales amount (Quantity × Unit Price)                                 |

> **Note:** The file name must be exactly `Sales Data..csv` (two dots before `.csv`). You can change the file name in the code if needed.

---

## 🚀 How to Run

1. **Clone the repository**  
   ```bash
   git clone https://github.com/yourusername/ins8-sales-dashboard.git
   cd ins8-sales-dashboard
2. **Install required R packages**
install.packages(c("shiny", "shinydashboard", "shinyWidgets", "tidyverse", "scales", "plotly"))
Place your data file
Copy Sales Data..csv into the project folder.

3. **Run the app**
 Open the project in RStudio and click Run App.



 
