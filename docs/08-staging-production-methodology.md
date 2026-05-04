# 08. Staging / Production Methodology

This document explains the **staging/production methodology** used in the OBETA project, why it works, and its main pros and cons.

---

## 1. What does staging mean?

The **staging layer** is an intermediate database area where raw data is first loaded, cleaned, transformed, and validated before it becomes part of the final analytical model.

In this project, the staging database is:

```text
obeta_staging
```

The main staging tables are:

| Table | Purpose |
|---|---|
| `pick_data` | Raw picking activity loaded from CSV files |
| `product_data` | Raw product information |
| `warehouse_sections` | Warehouse section reference data |
| `pickoperations` | Cleaned and enriched staging output used before production |

The staging layer is not the final dashboard model. It is a preparation area used by the ETL process.

---

## 2. What does production mean?

The **production layer** is the final analytical database structure used for reporting, dashboards, and business analysis.

In this project, the production database is:

```text
obeta_production
```

The main production tables are:

| Table | Type | Purpose |
|---|---|---|
| `pick` | Fact table | Stores picking events and measurable values |
| `product` | Dimension table | Stores product context |
| `order` | Dimension table | Stores order context |

This production model follows a **star schema**, where the fact table `pick` connects to the dimension tables `product` and `order` through foreign keys.

---

## 3. How we used this methodology in OBETA

The OBETA ETL process was divided into three streams.

### Stream 1: Raw to Staging

Raw CSV files were loaded into `obeta_staging`.

Examples:

- `pick_data`
- `product_data`
- `warehouse_sections`

At this stage, the data was still close to the original source format.

### Stream 2: Clean and Transform in Staging

The raw staging tables were cleaned, joined, and transformed.

Main transformations:

- Standardized data types
- Joined pick data with product data
- Joined warehouse section information
- Extracted `year`, `month`, and `quarter`
- Calculated `order_duration`
- Created the cleaned table `pickoperations`

The table `pickoperations` became the main clean staging source for production.

### Stream 3: Staging to Production

The cleaned staging table `pickoperations` was used to generate the final star schema.

The data was split into:

- `product` dimension
- `order` dimension
- `pick` fact table

Surrogate keys were added:

- `product_key`
- `order_key`

Then the fact table `pick` stored those keys instead of repeating all product and order information in every row.

---

## 4. Why this methodology works

This methodology works because it separates the ETL process into clear responsibilities.

| Layer | Responsibility |
|---|---|
| Raw/Staging input | Preserve and load source data |
| Clean staging | Clean, enrich, and prepare the data |
| Production | Store the final analytics-ready model |

This makes the process easier to understand, debug, and validate.

For example, if a dashboard value looks wrong, we can check the data step by step:

```text
Raw CSV → pick_data → pickoperations → production.pick → dashboard
```

This is better than loading raw files directly into a dashboard because every transformation is traceable.

---

## 5. Why we did not use only one big table

At one point, the process generated or depended on a very large table because the data contained millions of picking rows plus repeated product and order attributes.

A single large denormalized table can become heavy because it repeats descriptive fields many times, for example:

- Product description repeated for every pick
- Product group repeated for every pick
- Origin repeated across many rows
- Order information repeated across several picks

Instead, the production star schema reduces unnecessary repetition by storing descriptive data once in dimension tables and referencing it from the fact table using keys.

This helped reduce storage size and improved dashboard usability.

---

## 6. Pros of the staging/production approach

| Advantage | Explanation |
|---|---|
| Better organization | Raw, cleaned, and final analytical data are separated |
| Easier debugging | We can identify where an error was introduced |
| Better data quality | Cleaning happens before the dashboard uses the data |
| Reproducibility | The same ETL steps can recreate the same database state |
| Better performance | The final production model is smaller and easier to query |
| Better dashboard design | The star schema is optimized for analytics |
| Safer changes | Transformations can be tested in staging before affecting production |

---

## 7. Cons of the staging/production approach

| Disadvantage | Explanation |
|---|---|
| More storage required | Data exists in raw, cleaned, and production forms |
| More ETL steps | The process is longer than loading directly to one table |
| More maintenance | Changes must be reflected across flows, tables, and SQL scripts |
| Possible latency | Data is not immediately available until all streams finish |
| More complexity | Users must understand the difference between staging and production |
| Risk of duplicated logic | If transformations are not documented, the same logic may be repeated incorrectly |

---

## 8. Why it was a good choice for OBETA

The staging/production approach was a good choice because OBETA has a large operational dataset with millions of picking records.

The project required:

- Cleaning raw data before analysis
- Joining pick, product, and warehouse information
- Calculating analytical fields such as `order_duration`
- Creating a final model suitable for dashboards
- Avoiding unnecessary repetition in the final production database

Because of this, using staging first and production second made the project more reliable, explainable, and closer to a real data warehouse process.

---

## 9. Short explanation for presentation

```text
We used a staging/production methodology to separate data preparation from final analytics.
Raw CSV files were first loaded into the staging database. Then we cleaned, joined, and transformed them into the pickoperations table. Finally, we used this cleaned staging table to create the production star schema with one fact table, pick, and two dimensions, product and order.

This approach works because it makes the ETL process traceable, easier to debug, and better optimized for dashboards. The main advantage is data quality and performance. The main disadvantage is that it requires more storage, more steps, and more maintenance.
```


## 10. Mermaid diagram

A Mermaid version of this methodology is available here:

- [09. Staging / Production Methodology Diagram](09-staging-production-diagram.md)

---

## Navigation

[Previous: Database Schema Reference](07-database-schema-reference.md) | [Repository Home](../README.md) | [Next: Staging / Production Methodology Diagram](09-staging-production-diagram.md)
