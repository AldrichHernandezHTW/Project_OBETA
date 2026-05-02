# 02. Data Model

## Production Star Schema

The final analytical model follows a **star schema**.

A star schema is useful for analytics because it separates measurable business events from descriptive context.

In OBETA:

- The **fact table** stores the picking events and numerical measures.
- The **dimension tables** store descriptive information about products and orders.

---

## Tables

### Fact Table: `pick`

The `pick` table is the central table of the dashboard.

It contains the measurable picking activity.

Example fields:

| Field | Meaning |
|---|---|
| `pick_id` | Unique identifier of a picking operation |
| `order_key` | Foreign key connecting the pick to the order dimension |
| `product_key` | Foreign key connecting the pick to the product dimension |
| `pick_volume` | Quantity or volume handled in the picking operation |
| `order_duration` | Time needed to complete the related order |
| `year` | Year of the picking activity |
| `month` | Month of the picking activity |
| `quarter` | Quarter of the picking activity |

---

### Dimension Table: `product`

The `product` table provides product-related context.

Example fields:

| Field | Meaning |
|---|---|
| `product_key` | Surrogate primary key of the product dimension |
| `product_id` | Original product identifier from the source data |
| `product_description` | Product description |
| `product_group` | Product category or group |
| `warehouse_section` | Warehouse section where the product is handled |

---

### Dimension Table: `order`

The `order` table provides order-related context.

Example fields:

| Field | Meaning |
|---|---|
| `order_key` | Surrogate primary key of the order dimension |
| `order_id` | Original order identifier from the source data |
| `origin` | Order origin, for example `CUSTOMER` or `STORE` |
| `position_in_order` | Position of the picked item within the order |

---

## Why a Star Schema Was Used

The star schema was used because it is efficient and simple for analytical dashboards.

Benefits:

- Faster aggregations for KPIs
- Easier joins between facts and dimensions
- Clear structure for reporting
- Better dashboard performance
- Easier business interpretation

---

## Relationship Logic

```text
product.product_key 1 ─── * pick.product_key
order.order_key     1 ─── * pick.order_key
```

This means:

- One product can appear in many picks.
- One order can generate many picks.
- Each pick belongs to one product and one order.

---

## Important Note About Denormalization

The production model is partially denormalized for analytics.

For example, product-related information such as `product_description`, `product_group`, and `warehouse_section` is stored together in the `product` dimension.

This reduces the number of joins needed in Tableau and makes the dashboard faster and easier to build.

---


---

## Exact Database Tables Used

The dashboard was built from the following MySQL tables.

### Staging Tables

| Table | Role in the ETL process |
|---|---|
| `obeta_staging.pick_data` | Raw picking activity loaded from CSV |
| `obeta_staging.product_data` | Raw product master data |
| `obeta_staging.warehouse_sections` | Warehouse section mapping and descriptions |
| `obeta_staging.pickoperations` | Cleaned and enriched staging table produced by Stream 2 |

### Production Tables

| Table | Type | Role in the dashboard |
|---|---|---|
| `obeta_production.pick` | Fact table | Stores measurable picking events and KPIs |
| `obeta_production.product` | Dimension table | Stores product context and product grouping |
| `obeta_production.`order`` | Dimension table | Stores order context such as origin and position in order |

The full SQL table definitions, indexes, primary keys, and foreign keys are documented here:

[07. Database Schema Reference](07-database-schema-reference.md)

## Navigation

[Previous: Project Overview](01-project-overview.md) | [Repository Home](../README.md) | [Next: Dashboard KPIs](03-dashboard-kpis.md)
