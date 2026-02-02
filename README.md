# CRM Customer Segmentation Analysis (RFM Model)

## 📌 Project Overview
This project performs an in-depth analysis of supermarket customer behavior. By leveraging the RFM (Recency, Frequency, Monetary) model and the Pareto Principle (80/20 rule), the analysis identifies high-value segments and at-risk customers to drive targeted marketing strategies.

## 📊 Business Problem
The supermarket needs to differentiate its customer base to:
* Identify high-value customers (VIP).
* Re-engage customers at risk of churning.
* Optimize marketing budget by targeting the right segments.

## 🛠 Tech Stack
* **Data Source:** Kaggle (Customer Personality Analysis).
* **Processing:** SQL (SQL Server) for RFM scoring.
* **Visualization:** Power BI for dashboard.

## ⚙️ Workflow
1.  **Data Extraction:** Imported raw `.csv` data into the SQL environment.
2.  **RFM Scoring (SQL):** * **Recency ($R$):** Days since the last purchase.
    * **Frequency ($F$):** Total number of transactions.
    * **Monetary ($M$):** Total revenue generated per customer.
3.  **Segmentation Strategy:** The SQL script categorizes customers into the following strategic groups:
   * VIP: The "Golden" group (Score 3-3-3). These are your most valuable customers according to the Pareto principle.
   * Big Spenders: High-value customers ($M=3$) regardless of frequency or recency.
   * Recent Customers: New or returning customers ($R=3$) with high potential.
   * Frequent Customers: Highly engaged users ($F=3$) who visit often.
   * High Risk: Customers who haven't returned recently ($R > 1$) and require re-engagement.
   * Lost: Lowest engagement across all metrics (1-1-1).
5.  **Dashboarding:** Integrated both raw and processed data into Power BI to visualize segment distribution and behavioral trends.
