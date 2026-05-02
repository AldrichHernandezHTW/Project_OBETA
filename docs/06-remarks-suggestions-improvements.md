# 06. Remarks, Suggestions and Improvements

## Main Remarks

The OBETA project successfully transformed raw warehouse data into an analytical production model. The final dashboard is easier to understand because it uses a star schema with one fact table and two dimensions.

The ETL process also improved the structure of the data by cleaning, joining, and enriching the original sources before analysis.

---

## Suggestions and Improvements

### 1. Replace Heavy Tableau Prep Processing with Python ETL

Some Tableau Prep flows were slow with large datasets. A Python ETL process can process the data in batches and avoid loading everything at once.

**Benefit:** Better performance and lower memory usage.

---

### 2. Add Indexes for Join Columns

Indexes should be added to frequently joined columns such as:

- `pick_id`
- `order_id`
- `product_id`
- `order_key`
- `product_key`

**Benefit:** Faster joins, faster filtering, and better dashboard performance.

---

### 3. Reduce Unnecessary Columns

Only the fields needed for the analytical model should be kept in production.

**Benefit:** Smaller tables, faster queries, and easier dashboards.

---

### 4. Use a Star Schema for Analytics

The final model should remain focused on the `pick` fact table and the `product` and `order` dimensions.

**Benefit:** Easier KPI calculation and better performance in Tableau or Power BI.

---

### 5. Validate KPI Results with SQL

Important dashboard numbers should be validated directly in MySQL using SQL queries.

**Benefit:** More reliable reporting and easier error detection.

---

### 6. Improve Automation

The three ETL flows should be executed automatically in sequence.

**Benefit:** Better reproducibility and less manual work.

---

## Final Improvement Statement

The most important improvement is to move from a heavy visual ETL process to a more controlled and optimized ETL process using Python and SQL. This allows batch processing, better memory control, indexing, and easier validation of results. The final production star schema should remain simple and optimized for analytics.

---

## Navigation

[Previous: Presentation Script](05-presentation-script.md) | [Repository Home](../README.md) | [Next: Database Schema Reference](07-database-schema-reference.md)
