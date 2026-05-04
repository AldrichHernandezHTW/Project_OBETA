# 07. Database Schema Reference

This document stores the final database table definitions used in the OBETA project.

It is useful when someone needs to verify:

- Which tables exist in `obeta_staging` and `obeta_production`.
- Which columns were available for the dashboard.
- Which fields were created during the ETL process.
- Which indexes were added to improve joins and dashboard queries.
- How the production star schema connects `pick`, `product`, and `order`.

---

## 1. Staging Layer

The staging layer is stored in:

```text
obeta_staging
```

The staging layer keeps raw and cleaned data before the final analytical model is created.

### `pick_data`

This is the raw picking activity table loaded from the source CSV data.

Main fields:

| Field | Meaning |
|---|---|
| `product_id` | Product identifier from the source data |
| `warehouse_section` | Warehouse section or warehouse area abbreviation |
| `origin` | Original order source field before transformation |
| `order_id` | Original order identifier |
| `position_in_order` | Position of the picked item inside the order |
| `pick_volume` | Quantity or volume picked |
| `quantity_unit` | Unit of the picked quantity |
| `date` | Timestamp of the picking activity |

Important indexes:

| Index | Columns | Why it was useful |
|---|---|---|
| `idx_pick_data_order_date` | `order_id`, `date` | Speeds up the calculation of minimum and maximum timestamp per order |
| `idx_pick_data_product` | `product_id` | Speeds up joins with product data |
| `idx_pick_data_warehouse` | `warehouse_section` | Speeds up joins with warehouse section data |

---

### `product_data`

This table contains product master data.

Main fields:

| Field | Meaning |
|---|---|
| `product_id` | Product identifier |
| `product_description` | Product description |
| `product_group` | Product category or group |

Important index:

| Index | Columns | Why it was useful |
|---|---|---|
| `idx_product_data_product` | `product_id` | Speeds up the join between picks and products |

---

### `warehouse_sections`

This table adds warehouse section descriptions and mapping information.

Main fields:

| Field | Meaning |
|---|---|
| `warehouse_abbreviation` | Short warehouse code used for matching |
| `warehouse_description` | Description of the warehouse area |
| `warehouse_section` | Final warehouse section used in analysis |

Important index:

| Index | Columns | Why it was useful |
|---|---|---|
| `idx_warehouse_abbreviation` | `warehouse_abbreviation` | Speeds up the join between pick data and warehouse information |

---

### `pickoperations`

This is the cleaned and enriched staging table created after Stream 2.

It combines picking data, product data, warehouse data, and the calculated `order_duration`.

Main fields:

| Field | Meaning |
|---|---|
| `pick_id` | Generated picking operation identifier |
| `order_id` | Order identifier used before creating the production surrogate key |
| `product_id` | Product identifier used before creating the production surrogate key |
| `product_description` | Product description from product data |
| `product_group` | Product group from product data |
| `warehouse_section` | Warehouse section used for analysis |
| `origin` | Order origin, for example `CUSTOMER` or `STORE` |
| `position_in_order` | Position of the item inside the order |
| `pick_volume` | Picked quantity or volume |
| `quantity_unit` | Quantity unit |
| `year` | Year extracted from the picking timestamp |
| `month` | Month extracted from the picking timestamp |
| `quarter` | Quarter extracted from the picking timestamp |
| `order_duration` | Duration between the first and last picking timestamp of the order |

Important indexes:

| Index | Columns | Why it was useful |
|---|---|---|
| `idx_pickoperations_product` | `product_id` | Speeds up the creation of the `product` dimension and the join back to `pick` |
| `idx_pickoperations_order` | `order_id` | Speeds up the creation of the `order` dimension and the join back to `pick` |

---

## 2. Production Layer

The production layer is stored in:

```text
obeta_production
```

This layer is the final analytical model used by the dashboard.

It follows a star schema:

```text
product ─┐
         ├── pick
order ───┘
```

---

### `product`

This is a production dimension table.

It stores descriptive product information and uses a surrogate primary key.

Main fields:

| Field | Meaning |
|---|---|
| `product_key` | Auto-generated surrogate primary key |
| `product_id` | Original product identifier from staging |
| `product_description` | Product description |
| `product_group` | Product category or group |
| `warehouse_section` | Warehouse section related to the product |

Key logic:

```text
product_key = internal analytical key
product_id = original business/source key
```

Why this matters:

- `product_key` is stable and efficient for joins.
- `product_id` keeps the connection to the original data.
- The dimension is denormalized because product description, group, and warehouse section are stored together for easier dashboard analysis.

Important indexes:

| Index | Columns | Why it was useful |
|---|---|---|
| `PRIMARY KEY` | `product_key` | Uniquely identifies each product dimension row and supports joins from `pick` |
| `idx_product_product_id` | `product_id` | Speeds up matching products from `pickoperations` when creating or joining the production model |

---

### `order`

This is a production dimension table.

It stores descriptive order information and uses a surrogate primary key.

Main fields:

| Field | Meaning |
|---|---|
| `order_key` | Auto-generated surrogate primary key |
| `order_id` | Original order identifier from staging |
| `origin` | Source of the order, such as `CUSTOMER` or `STORE` |
| `position_in_order` | Position of the item inside the order |

Key logic:

```text
order_key = internal analytical key
order_id = original business/source key
```

Important note:

Because `order` is a reserved SQL keyword, it must be written with backticks in MySQL:

```sql
obeta_production.`order`
```

Important indexes:

| Index | Columns | Why it was useful |
|---|---|---|
| `PRIMARY KEY` | `order_key` | Uniquely identifies each order dimension row and supports joins from `pick` |
| `idx_order_order_id` | `order_id` | Speeds up matching orders from `pickoperations` when creating or joining the production model |

---

### `pick`

This is the production fact table.

It stores the measurable picking activity and connects to the dimensions using foreign keys.

Main fields:

| Field | Meaning |
|---|---|
| `pick_id` | Picking operation identifier |
| `product_key` | Foreign key to `product.product_key` |
| `order_key` | Foreign key to `order.order_key` |
| `pick_volume` | Quantity or volume picked |
| `quantity_unit` | Unit of the picked quantity |
| `year` | Year used for time analysis |
| `month` | Month used for time analysis |
| `quarter` | Quarter used for time analysis |
| `order_duration` | Duration of the related order |

Foreign keys:

| Foreign Key | Connects |
|---|---|
| `fk_pick_product` | `pick.product_key` → `product.product_key` |
| `fk_pick_order` | `pick.order_key` → `order.order_key` |

Important indexes:

| Index | Columns | Why it was useful |
|---|---|---|
| `idx_pick_product_key` | `product_key` | Speeds up joins from `pick` to `product` |
| `idx_pick_order_key` | `order_key` | Speeds up joins from `pick` to `order` |
| `idx_pick_year_month` | `year`, `month` | Speeds up time-based dashboard charts |
| `idx_pick_quarter` | `quarter` | Speeds up quarter-based filtering or aggregation |

---

## 3. Index Summary for All Tables

| Database | Table | Index | Columns | Purpose |
|---|---|---|---|---|
| `obeta_staging` | `pick_data` | `idx_pick_data_order_date` | `order_id`, `date` | Speeds up minimum and maximum timestamp calculations per order |
| `obeta_staging` | `pick_data` | `idx_pick_data_product` | `product_id` | Speeds up joins with `product_data` |
| `obeta_staging` | `pick_data` | `idx_pick_data_warehouse` | `warehouse_section` | Speeds up joins with `warehouse_sections` |
| `obeta_staging` | `pickoperations` | `idx_pickoperations_product` | `product_id` | Speeds up creation of the `product` dimension and joins back to picks |
| `obeta_staging` | `pickoperations` | `idx_pickoperations_order` | `order_id` | Speeds up creation of the `order` dimension and joins back to picks |
| `obeta_staging` | `product_data` | `idx_product_data_product` | `product_id` | Speeds up joins between picking data and product master data |
| `obeta_staging` | `warehouse_sections` | `idx_warehouse_abbreviation` | `warehouse_abbreviation` | Speeds up joins between picking data and warehouse reference data |
| `obeta_production` | `product` | `PRIMARY KEY` | `product_key` | Uniquely identifies product dimension rows |
| `obeta_production` | `product` | `idx_product_product_id` | `product_id` | Speeds up product lookup by original source/business key |
| `obeta_production` | `order` | `PRIMARY KEY` | `order_key` | Uniquely identifies order dimension rows |
| `obeta_production` | `order` | `idx_order_order_id` | `order_id` | Speeds up order lookup by original source/business key |
| `obeta_production` | `pick` | `idx_pick_product_key` | `product_key` | Speeds up joins from `pick` to `product` |
| `obeta_production` | `pick` | `idx_pick_order_key` | `order_key` | Speeds up joins from `pick` to `order` |
| `obeta_production` | `pick` | `idx_pick_year_month` | `year`, `month` | Speeds up time-based dashboard charts |
| `obeta_production` | `pick` | `idx_pick_quarter` | `quarter` | Speeds up quarter-based filtering and aggregation |

---

## 4. Why Indexes Were Added

Indexes were added because the dataset is large and joins/grouping operations were expensive.

Without indexes, MySQL may need to scan complete tables to find matching rows.

In this project, indexes helped mainly with:

- Joining `pick_data` with `product_data` by `product_id`.
- Joining `pick_data` with `warehouse_sections` by warehouse code/section.
- Calculating `order_duration` by grouping `order_id` and checking timestamps.
- Joining the production fact table `pick` with the dimensions `product` and `order`.
- Aggregating dashboard metrics by year, month, and quarter.

Trade-off:

- Indexes improve read and join performance.
- Indexes require additional storage.
- Indexes can make inserts slower because MySQL has to update the index structures.

For this project, the trade-off makes sense because the production database is mainly used for analytics and dashboard queries.

---

## 5. Full SQL Schema

The complete schema is also available as a SQL file:

[database-schema.sql](../sql/database-schema.sql)

```sql
-- obeta_staging.pick_data definition

CREATE TABLE `pick_data` (
  `product_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warehouse_section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin` int DEFAULT NULL,
  `order_id` bigint DEFAULT NULL,
  `position_in_order` int DEFAULT NULL,
  `pick_volume` int DEFAULT NULL,
  `quantity_unit` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  KEY `idx_pick_data_order_date` (`order_id`,`date`),
  KEY `idx_pick_data_product` (`product_id`),
  KEY `idx_pick_data_warehouse` (`warehouse_section`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- obeta_staging.pickoperations definition

CREATE TABLE `pickoperations` (
  `pick_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_group` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warehouse_section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position_in_order` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pick_volume` int DEFAULT NULL,
  `quantity_unit` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year` int DEFAULT NULL,
  `month` int DEFAULT NULL,
  `quarter` int DEFAULT NULL,
  `order_duration` decimal(12,6) DEFAULT NULL,
  KEY `idx_pickoperations_product` (`product_id`),
  KEY `idx_pickoperations_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- obeta_staging.product_data definition

CREATE TABLE `product_data` (
  `product_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_group` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_product_data_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- obeta_staging.warehouse_sections definition

CREATE TABLE `warehouse_sections` (
  `warehouse_abbreviation` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warehouse_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warehouse_section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_warehouse_abbreviation` (`warehouse_abbreviation`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- obeta_production.`order` definition

CREATE TABLE `order` (
  `order_key` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position_in_order` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`order_key`),
  KEY `idx_order_order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28835401 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- obeta_production.pick definition

CREATE TABLE `pick` (
  `pick_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_key` int DEFAULT NULL,
  `order_key` int DEFAULT NULL,
  `pick_volume` int DEFAULT NULL,
  `quantity_unit` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year` int DEFAULT NULL,
  `month` int DEFAULT NULL,
  `quarter` int DEFAULT NULL,
  `order_duration` decimal(12,6) DEFAULT NULL,
  KEY `idx_pick_product_key` (`product_key`),
  KEY `idx_pick_order_key` (`order_key`),
  KEY `idx_pick_year_month` (`year`,`month`),
  KEY `idx_pick_quarter` (`quarter`),
  CONSTRAINT `fk_pick_order` FOREIGN KEY (`order_key`) REFERENCES `order` (`order_key`),
  CONSTRAINT `fk_pick_product` FOREIGN KEY (`product_key`) REFERENCES `product` (`product_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- obeta_production.product definition

CREATE TABLE `product` (
  `product_key` int NOT NULL AUTO_INCREMENT,
  `product_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_group` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warehouse_section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`product_key`),
  KEY `idx_product_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=196606 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

```

---

## Navigation

[Previous: Remarks, Suggestions and Improvements](06-remarks-suggestions-improvements.md) | [Repository Home](../README.md) | [Next: Staging / Production Methodology](08-staging-production-methodology.md)
