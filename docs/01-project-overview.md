# 01. Project Overview

## Project Name

**OBETA Warehouse Picking Performance Dashboard**

## Objective

The objective of the dashboard is to analyze the performance of the OBETA warehouse picking process.

The dashboard helps answer questions such as:

- How many picking operations were performed?
- How much volume was picked?
- How long does an average order take to complete?
- Which product groups generate the most picking activity?
- Which warehouse sections handle the highest volume?
- Are customer orders or store orders more time-consuming?

---

## Why These Items Were Chosen

The dashboard items were selected because they represent the most important parts of warehouse picking performance:

1. **Activity**: How many picks were performed?
2. **Workload**: How much total volume was handled?
3. **Efficiency**: How long did orders take?
4. **Complexity**: How many products were involved?
5. **Demand**: How many orders generated the workload?
6. **Distribution**: Which origins, product groups, and warehouse sections created the workload?

---

## Data Source

The dashboard is based on the final production database:

```text
OBETA_PRODUCTION
```

This production database was created after three ETL streams:

1. **Stream 01: Raw to Staging**
   - Loads raw CSV files into `OBETA_STAGING`.

2. **Stream 02: Transform and Clean Staging**
   - Cleans and enriches the raw data.
   - Calculates important fields such as `order_duration`.
   - Produces the cleaned table `pickoperations`.

3. **Stream 03: Staging to Production**
   - Creates the final star schema in `OBETA_PRODUCTION`.
   - Generates the `pick`, `product`, and `order` tables.

---

## Business Meaning

In this project, a **pick** represents a warehouse picking operation. Picking is the process of selecting products from the warehouse to fulfill an order.

The dashboard therefore measures how much picking activity happened, how much volume was handled, how long orders took, and where the main operational workload was concentrated.

---

## Navigation

[Repository Home](../README.md) | [Next: Data Model](02-data-model.md)
