
# 🏆 Data Warehouse Interview Q&A

### 1. **What is a Data Warehouse?**
- **Answer**: A data warehouse is a centralized repository that integrates data from multiple sources, optimized for querying and analysis rather than transaction processing.
It supports business intelligence, reporting, and decision‑making.

---

### 2. **Difference between OLTP and OLAP?**
- **OLTP (Online Transaction Processing)** → Handles day‑to‑day operations (insert/update/delete). Example: banking transactions.  
- **OLAP (Online Analytical Processing)** → Handles queries, aggregations, and historical analysis. Example: sales trends over 5 years.

---

### 3. **What is ETL vs ELT?**
- **ETL (Extract, Transform, Load)** → Data is transformed before loading into the warehouse (traditional Oracle/Informatica pipelines).  
- **ELT (Extract, Load, Transform)** → Data is loaded first, then transformed inside the warehouse (modern Snowflake/AWS approach).

---

### 4. **What are Fact and Dimension Tables?**
- **Fact Table**: Stores measurable business data (sales, revenue, transactions).  
- **Dimension Table**: Stores descriptive attributes (customer, product, time, region).  
👉 Together they form schemas for analysis.

---

### 5. **Explain Star Schema vs Snowflake Schema.**
- **Star Schema**: Central fact table linked directly to dimension tables. Simple, fast queries.  
- **Snowflake Schema**: Dimensions normalized into multiple related tables. Saves space but adds complexity.

---

### 6. **What is Data Mart vs Data Warehouse?**
- **Data Mart**: Subset of a data warehouse focused on a specific business area (e.g., finance, HR).  
- **Data Warehouse**: Enterprise‑wide repository integrating all business domains.

---

### 7. **What is Slowly Changing Dimension (SCD)?**
- **Answer**: A technique to manage changes in dimension data over time.  
  - **Type 1**: Overwrite old data.  
  - **Type 2**: Add new row with versioning.  
  - **Type 3**: Add new column for history.

---

### 8. **How do you ensure Data Quality in a Warehouse?**
- Apply **data cleansing**, validation rules, referential integrity checks.  
- Use QA practices like reconciliation reports and exception handling in ETL.

---

### 9. **What are Partitioning and Indexing in Warehouses?**
- **Partitioning**: Splits large tables into smaller segments for faster queries.  
- **Indexing**: Improves retrieval speed by creating lookup structures.  
👉 You’ve applied this in Oracle fact tables with billions of rows.

---

### 10. **How does Snowflake differ from traditional warehouses?**
- **Answer**: Snowflake is cloud‑native, supports ELT, separates compute from storage, scales automatically, and integrates seamlessly with AWS. Unlike traditional Oracle warehouses, it doesn’t require manual tuning of infrastructure.

---

## 🎯 Interview Delivery Tip
When asked about data warehouses, frame it like this:  
*"I’ve worked extensively with Oracle data warehouses, designing fact/dimension tables, optimizing queries with partitioning and indexes,
and building ETL pipelines using Informatica and PL/SQL. 
More recently, I’ve leveraged Snowflake and AWS for scalable, cloud‑native analytics, applying ELT patterns and automation.
This gives me a strong foundation across both traditional and modern warehouse architectures."*

---

