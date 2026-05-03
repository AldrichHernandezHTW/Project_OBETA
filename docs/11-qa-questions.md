# 11. Q&A Questions and Answers

## Q&A: Database Theory

### 1. What is a database?

A database is a structured collection of data. Unlike CSV or Excel files, a database is managed by a database system, supports CRUD operations, can handle larger data volumes, and can define relationships between multiple tables.

### 2. What is a Database Management System (DBMS)?

A DBMS is software used to create, manage, query, and control databases. It is required at scale because it manages access, relationships, data integrity, concurrent users, and safe data modification.

### 3. What is the difference between OLTP and OLAP?

OLTP systems support daily transactional work with many short, fast operations, such as order processing or sales transactions. OLAP systems support analysis with fewer but more complex queries, aggregations, and historical reporting.

### 4. What does ACID stand for?

ACID stands for Atomicity, Consistency, Isolation, and Durability. In a 100 USD transfer from account A to account B, atomicity means both deduction and addition happen together, consistency means account rules are respected, isolation means parallel transactions do not interfere, and durability means the completed transfer remains stored even after a failure.

### 5. Why is ACID compliance important for transactional databases?

ACID compliance is important because it protects data integrity, prevents corruption, and keeps transactional data reliable even when errors, failures, or simultaneous users occur.

### 6. What are examples of operations that should be executed within a single transaction?

An e-commerce order should update the order record, payment status, and inventory stock in one transaction. This prevents cases where a customer pays but stock is not reduced, or stock is reduced even though the order failed.

### 7. What is the difference between a database and a DBMS?

A database is the stored data and its structure. A DBMS is the software system used to create, manage, access, and control that database.

### 8. Are MySQL and Oracle databases or DBMSs?

MySQL and Oracle are DBMSs. They are software systems that allow users to create, manage, query, and control databases.

### 9. What is a star schema, and why is it used in analytical systems?

A star schema is a data model with a central fact table connected to dimension tables. It is common in analytical systems because it is simple to understand, requires fewer joins than highly normalized models, and supports fast dashboard queries.

### 10. What is the difference between a star schema and a snowflake schema?

In a star schema, the fact table connects directly to denormalized dimension tables. In a snowflake schema, dimension tables are split into smaller normalized tables, which reduces redundancy but increases the number of joins.

### 11. Why do we need a modeling approach with reduced granularity here?

The OBETA raw data is very detailed and contains many picking records. For analysis and reporting, reducing granularity makes the data easier to process, faster to query, and better suited for dashboards and decision-making.

### 12. What relationships can exist between tables?

Common relationships are one-to-many, many-to-one, and many-to-many. For example, one product can appear in many picking events, many employees can belong to one department, and many orders can contain many products.

### 13. What is an index in a database?

An index is a database structure that helps find rows faster. It works like an index in a book: instead of scanning every row, the database can jump more directly to matching data.

### 14. How do indexes improve performance, and what trade-offs do they introduce?

Indexes improve query performance by reducing the amount of data scanned during `WHERE`, `JOIN`, `ORDER BY`, and sometimes `GROUP BY` operations. The trade-off is that indexes require extra storage and can slow down `INSERT`, `UPDATE`, and `DELETE` operations because the index must also be updated.

### 15. How is storing prepared tables different from defining indexes?

Indexes speed up access to existing data without changing the table content. Prepared tables improve merging by reducing or reshaping the data beforehand, for example by filtering rows or keeping only relevant columns. Prepared tables can reduce the amount of data processed, while indexes mainly make row lookup faster.

### 16. What is the role of primary keys and foreign keys in analytical data models?

Primary keys uniquely identify rows in dimension tables. Foreign keys connect the fact table to those dimension rows. In OBETA, `pick.product_key` links a picking event to the correct product, and `pick.order_key` links it to the correct order.

### 17. What are data models?

A data model is the blueprint of a database. It defines how data is structured, how tables relate to each other, and how the data should be used for analysis. Examples include relational models, normalized models, denormalized models, star schemas, and snowflake schemas.

### 18. How do we implement primary keys in SQL and make sure they are unique?

Primary keys are implemented using the `PRIMARY KEY` constraint. The database guarantees uniqueness, and `AUTO_INCREMENT` can automatically generate a new unique value for each row.

### 19. How do we implement an M:N relationship?

An M:N relationship is implemented with a bridge table. The bridge table stores the primary keys of both related tables as foreign keys and turns the many-to-many relationship into two one-to-many relationships.

### 20. What is the concrete OBETA data model?

The OBETA production model is a star schema with `pick` as the fact table and `product` and `order` as dimensions. The visual model is documented here: [10. Production ER Diagram](10-production-er-diagram.md).

### 21. What are the trade-offs between normalized and denormalized data models?

Normalized models reduce duplication and improve consistency, but they often require more tables and more joins. Denormalized models store related information together, which can duplicate data but makes analytical queries and dashboards faster and easier.

### 22. Where has denormalization been applied in the OBETA Product and Order dimensions?

The `product` dimension stores product information together with `warehouse_section`, even though that context originally came from picking data. The `order` dimension groups order-related fields such as `order_id`, `origin`, and `position_in_order`. This simplifies analytics because dashboard queries can access descriptive context without repeatedly joining raw source tables.

### 23. What remarks, suggestions, and improvements were identified?

The main improvements are to replace heavy Tableau Prep processing with Python ETL, add indexes for join columns, reduce unnecessary production columns, keep the star schema for analytics, validate KPI results with SQL, and automate the three ETL flows. More detail is documented here: [06. Remarks, Suggestions and Improvements](06-remarks-suggestions-improvements.md).

### 24. How do OLTP and OLAP compare?

| Topic | OLTP | OLAP |
|---|---|---|
| Name | Online Transaction Processing | Online Analytical Processing |
| Definition | Manages operational data and real-time transactions | Manages data for analysis and reporting |
| Example | Incoming orders in an online shop | Sales trend analysis |
| Data structure | Relational tables | Multidimensional or analytical structures |
| Manipulation | Record-by-record operations | Queries and aggregations |
| Updates | Real time and continuous | Batch or historical updates |
| Dataset size | Medium operational data | Large historical data |
| Workload | Predictable | Complex |
| Response time | Seconds | Minutes or longer can be acceptable |

---

## Q&A: ETL/DB Modeling

### 1. Why is ETL necessary in modern data architectures?

ETL is necessary because raw data from different systems is often messy, inconsistent, duplicated, or incomplete. ETL extracts data from heterogeneous sources, transforms it into a clean and consistent structure, and loads it into a central system so it can be used for reporting, analytics, and machine learning.

### 2. How does ETL improve data quality and consistency?

ETL improves quality by cleaning, validating, filtering, deduplicating, correcting formats, and standardizing values. This prevents raw source problems such as missing values, inconsistent date formats, duplicate records, and wrong data types from entering reports or dashboards.

### 3. What are the risks of skipping or simplifying ETL?

Skipping ETL can lead to wrong KPIs, corrupted reports, poor performance, missing reproducibility, missing auditability, and lost data lineage. Business users may lose trust in the data, analysts waste time cleaning manually, and decisions may be based on unreliable information.

### 4. Why is the staging layer not part of the final analytical model?

The staging layer is an intermediate preparation area. It can contain raw keys, duplicate records, temporary transformation results, redundant join columns, and partially cleaned data. Its structure is driven by technical ETL needs, while the production model is designed for stable analytics.

### 5. How do staging tables differ from the production star schema in OBETA?

Staging tables are process-oriented and used for loading, cleaning, joining, and transformation. The production star schema is entity-oriented and organized into the `pick` fact table plus the `product` and `order` dimensions for fast reporting and dashboard analysis.

### 6. What is the big picture of staging and production implementation?

The implementation follows this flow:

```text
Raw CSV files -> OBETA_STAGING raw tables -> pickoperations -> OBETA_PRODUCTION star schema -> dashboard
```

The detailed diagram is documented here: [09. Staging / Production Diagram](09-staging-production-diagram.md).

### 7. Would a staging/production approach also be used for Amazon-scale data?

Yes, but it would need to be adapted for much higher volume and speed. A large-scale implementation could use services such as a data lake for raw data, distributed ETL processing, and streaming pipelines. The drawbacks are higher latency, higher storage cost, and more complex monitoring and maintenance.

### 8. What is the general structure of an SQL command?

A typical `SELECT` command follows this structure:

```sql
SELECT
FROM
JOIN
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT
```

`SELECT` chooses columns, `FROM` identifies the source table, `JOIN` combines tables, `WHERE` filters rows, `GROUP BY` groups rows for aggregation, `HAVING` filters grouped results, `ORDER BY` sorts results, and `LIMIT` restricts the number of returned rows.

---

## Q&A: Data Flow

### 1. What data flow is implemented by Tableau Prep Flow 1?

Flow 1 implements the raw-to-staging step. It reads the raw CSV files, defines column names and data types, and writes the data into `OBETA_STAGING` tables. This creates a controlled starting layer for the whole team.

The advantages are centralized raw data, reusable staging tables, reproducibility, better collaboration, and a clear foundation for later transformations. The drawbacks are extra storage, added latency, and one more step in the pipeline.

### 2. What transformation steps are implemented in Tableau Prep Flow 2?

Flow 2 reads the raw staging tables, cleans and standardizes data types, calculates minimum and maximum timestamps per order, derives `order_duration`, joins the calculated duration back to pick data, enriches picks with product data, joins warehouse information, removes duplicate or unnecessary columns, and writes the cleaned result as `pickoperations` in `OBETA_STAGING`.

### 3. What SQL logic is implemented in Tableau Prep Flow 3?

Flow 3 creates the production star schema from `pickoperations`. It creates and fills the `product` dimension with unique product combinations, creates and fills the `order` dimension with unique order combinations, and creates the `pick` fact table. The final `pick` table is populated by joining `pickoperations` to `product` and `order` so each picking event receives the correct `product_key` and `order_key`.

This is needed because the raw cleaned staging table is still one wide operational table. Flow 3 converts it into an analytical star schema that reduces repetition, creates clear fact/dimension structure, and improves dashboard performance.

---

## Navigation

[Previous: Production ER Diagram](10-production-er-diagram.md) | [Repository Home](../README.md)
