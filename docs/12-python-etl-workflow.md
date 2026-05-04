# 12. Python ETL Workflow

This document explains what the Python ETL code does, flow by flow, and why batching was used. The Python workflow replaces the manual Tableau Prep execution while keeping the same logical architecture:

```text
raw CSV files -> staging tables -> cleaned pickoperations -> production star schema -> dashboard
```

The main goal of the Python version is to make the ETL process more reproducible, easier to rerun, and better suited for large OBETA datasets.

---

## 1. What the Python Workflow Replaces

The original project used three Tableau Prep flows:

| Tableau Prep flow | Python replacement | Main purpose |
|---|---|---|
| Flow 1 | `flow1_raw_to_staging.py` | Load raw CSV files into `obeta_staging` |
| Flow 2 | `flow2_transform_staging.py` | Clean and transform staging data into `pickoperations` |
| Flow 3 | `flow3_staging_to_production.py` | Create the final production star schema |

The Python code keeps the same three-step logic, but makes the process script-based and repeatable.

---

## 2. Main Files and Responsibilities

| File | Responsibility |
|---|---|
| `main.py` | Command line entry point for `flow1`, `flow2`, `flow3`, `run-all`, and `counts` |
| `config.py` | Reads database settings from environment variables or `.env` |
| `db.py` | Handles MySQL connection and helper functions for SQL execution |
| `ddl.py` | Creates staging tables and the `pickoperations` table |
| `indexes.py` | Creates indexes only when they are missing |
| `dataframe_writer.py` | Inserts pandas DataFrames into MySQL in batches |
| `flow1_raw_to_staging.py` | Loads raw CSV files into staging |
| `flow2_transform_staging.py` | Builds the cleaned staging table |
| `flow3_staging_to_production.py` | Builds the production star schema |
| `diagnostics.py` | Prints row counts for validation |

This structure separates configuration, database utilities, table creation, index creation, and ETL logic. That makes the workflow easier to understand and safer to maintain.

---

## 3. How the Workflow Is Started

The `main.py` file defines the available commands:

```text
python3 main.py flow1
python3 main.py flow2
python3 main.py flow3
python3 main.py run-all
python3 main.py counts
```

The most important parameters are:

| Parameter | Meaning |
|---|---|
| `--csv-chunk-size` | Number of CSV rows read by pandas at once; default is `50000` |
| `--db-batch-size` | Number of rows or IDs committed per database batch; default is `100000` |
| `--reset-output` | Truncates or drops target tables before reloading |
| `--product-encoding` | Encoding used for `002_product_data.csv`; default is `cp1252` |

The workflow uses environment variables such as `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `STAGING_DB`, and `PRODUCTION_DB`. If a `.env` file exists, it can load those settings automatically.

---

## 4. Flow 1: Raw CSV Files to Staging

Flow 1 loads the three raw source files into `obeta_staging`.

| CSV file | Target table |
|---|---|
| `001_warehouse_section.csv` | `obeta_staging.warehouse_sections` |
| `002_product_data.csv` | `obeta_staging.product_data` |
| `003_pick_data.csv` | `obeta_staging.pick_data` |

### What Flow 1 does

1. Creates the staging and production databases if they do not exist.
2. Creates the raw staging tables.
3. Reads the warehouse CSV and renames German source columns:
   - `Abkürzung` becomes `warehouse_abbreviation`
   - `Bedeutung` becomes `warehouse_description`
   - `Gruppe` becomes `warehouse_section`
4. Reads `product_data` with a configurable encoding because the file may fail with normal UTF-8.
5. Reads `pick_data` and converts numeric fields such as `origin`, `order_id`, `position_in_order`, and `pick_volume`.
6. Converts the picking timestamp field into a date/time value.
7. Inserts all data into MySQL in batches.
8. Creates indexes needed for Flow 2 joins and duration calculations.

### Why Flow 1 uses batches

The raw files are large, especially `pick_data`, which contains tens of millions of rows. Loading the full CSV into memory at once would be slow and risky. Flow 1 therefore uses:

| Batch mechanism | Why it is used |
|---|---|
| `pd.read_csv(..., chunksize=csv_chunk_size)` | Reads only part of the CSV into memory at one time |
| `batch_insert_dataframe(...)` | Inserts rows into MySQL in controlled groups |
| Regular commits | Avoids one huge transaction and reduces the risk of rollback or memory problems |

This makes the raw loading process more stable on normal laptops.

---

## 5. Flow 2: Transform Staging into `pickoperations`

Flow 2 reads the raw staging tables and creates the cleaned table:

```text
obeta_staging.pickoperations
```

This table is the bridge between raw staging data and the final production model.

### What Flow 2 does

1. Creates or truncates `pickoperations`.
2. Ensures indexes exist on the staging tables.
3. Creates a temporary duration table called `tmp_flow2_duration`.
4. Calculates `order_duration` using the minimum and maximum timestamp per generated `pick_id`.
5. Filters out extreme duration values above `10080` minutes.
6. Creates a temporary transformed table called `tmp_flow2_pickoperations`.
7. Joins picking data with product data.
8. Joins warehouse reference information.
9. Converts origin codes:
   - `46` becomes `STORE`
   - `48` becomes `CUSTOMER`
10. Extracts `year`, `month`, and `quarter`.
11. Filters invalid rows:
   - `pick_volume > 0`
   - `product_description IS NOT NULL`
   - `product_group IS NOT NULL`
12. Writes the final cleaned rows into `pickoperations` in batches.
13. Creates indexes on `pickoperations` for Flow 3.

### Why Flow 2 uses temporary tables

Flow 2 does several heavy transformations. Temporary tables make the process easier for MySQL to handle because intermediate results are stored once and reused.

| Temporary table | Purpose |
|---|---|
| `tmp_flow2_duration` | Stores calculated duration per `pick_id` |
| `tmp_flow2_pickoperations` | Stores the fully transformed staging result before final batch insertion |

This avoids repeating the same expensive calculations during the final write.

### Why Flow 2 uses batches

The final `pickoperations` table contains more than 33 million rows. Writing all rows in one transaction would be risky because:

- The transaction would be very large.
- A failure would require rolling back too much work.
- MySQL locks and memory usage could increase.
- Progress would be difficult to monitor.

To solve this, Flow 2 adds an internal `etl_row_id` to the temporary table and writes rows to `pickoperations` by ID ranges:

```text
1 - 100000
100001 - 200000
200001 - 300000
...
```

Each range is committed separately. This gives a controlled and more transparent loading process.

---

## 6. Flow 3: Staging to Production Star Schema

Flow 3 creates the final physical production model:

```text
obeta_production.product
obeta_production.order
obeta_production.pick
```

The production model is a star schema:

| Table | Type | Role |
|---|---|---|
| `product` | Dimension | Stores product context |
| `order` | Dimension | Stores order context |
| `pick` | Fact | Stores measurable picking operations |

### What Flow 3 does

1. Disables foreign key and unique checks during large loading steps.
2. Drops existing production tables if `--reset-output` is used.
3. Creates the production `product`, `order`, and `pick` tables.
4. Loads the `product` dimension using distinct product combinations from `pickoperations`.
5. Loads the `order` dimension using distinct order combinations from `pickoperations`.
6. Creates indexes on `product.product_id` and `order.order_id`.
7. Creates helper lookup tables:
   - `product_lookup`
   - `order_lookup`
8. Loads the `pick` fact table by joining `pickoperations` to the lookup tables.
9. Creates fact table indexes after the large insert.
10. Drops the helper lookup tables.
11. Re-enables checks.
12. Adds physical foreign keys:
   - `pick.product_key` to `product.product_key`
   - `pick.order_key` to `order.order_key`

### Why Flow 3 does not use Python batches for the fact table

Flow 3 is intentionally different from Flow 1 and Flow 2. It does not pull the 33 million rows into Python or pandas. Instead, it lets MySQL execute one internal `INSERT ... SELECT` operation:

```text
pickoperations + product_lookup + order_lookup -> production.pick
```

This is faster because the data already exists inside MySQL. Moving it out to Python and back into MySQL would add unnecessary overhead.

### Why indexes and foreign keys are created late

The code creates some indexes only after large inserts. This is intentional.

| Decision | Reason |
|---|---|
| Load fact data before creating fact indexes | Faster than updating indexes row by row during the insert |
| Add foreign keys at the end | Avoids expensive constraint checks during the large load |
| Use helper lookup tables | Makes key mapping faster and simpler |
| Drop helper lookup tables afterward | Keeps the final production schema clean |

This keeps the final model clean while still making the heavy load more efficient.

---

## 7. Why Batches Were Important

Batches were used because the OBETA dataset is too large for a naive load process. The main raw and transformed tables contain millions of rows, so the ETL must avoid loading everything into memory or committing everything in one transaction.

The batch strategy gives these benefits:

| Benefit | Explanation |
|---|---|
| Lower memory usage | Python reads and writes smaller chunks instead of full files |
| Safer database writes | Each batch is committed separately |
| Better failure recovery | A failed batch affects less work than one huge transaction |
| Better progress tracking | Logs show which batch range was committed |
| More stable performance | MySQL receives controlled insert sizes |
| Team reproducibility | Different laptops can run the same workflow with the same settings |

In short, batches were used to make the pipeline reliable with large files and large tables.

---

## 8. Why This Python Approach Is Better for the Project

The Python workflow improves the project because it is:

- Reproducible: the same command can rebuild the same tables.
- Transparent: each flow is visible as code.
- Easier to debug: errors can be traced to a specific module or SQL step.
- Better for large data: batching and SQL-side processing reduce memory pressure.
- Easier to automate: `run-all` can execute the complete pipeline.
- Better documented: the logic is explicit and can be explained flow by flow.

It also keeps the same data warehouse structure used in the documentation:

```text
raw data -> staging -> cleaned staging -> production star schema
```

---

## 9. Validation and Diagnostics

The workflow includes a `counts` command that prints row counts for all major tables:

```text
obeta_staging.warehouse_sections
obeta_staging.product_data
obeta_staging.pick_data
obeta_staging.pickoperations
obeta_production.product
obeta_production.order
obeta_production.pick
```

This is important because row counts help verify that each flow completed correctly and that the final dashboard is based on the expected data volume.

---

## 10. Final Explanation

The Python ETL workflow is a controlled replacement for the Tableau Prep process. Flow 1 loads raw files into staging using CSV and database batches. Flow 2 transforms and cleans the data into `pickoperations`, also using batches for the large final staging write. Flow 3 builds the production star schema mostly inside MySQL, because that is faster than moving millions of rows through Python.

The use of batches, indexes, temporary tables, lookup tables, and late foreign key creation makes the ETL process more reliable, more scalable, and easier to explain in a professional data analytics project.

---

## Navigation

[Previous: Q&A Questions and Answers](11-qa-questions.md) | [Repository Home](../README.md)
