# 03. Dashboard KPIs

This document explains each KPI used in the OBETA Warehouse Picking Performance Dashboard.

---

## 1. Number of Picks

### Dashboard Value

```text
33,698,592
```

### Calculation

```sql
COUNT(pick_id)
```

or:

```sql
SELECT COUNT(*) AS number_of_picks
FROM obeta_production.pick;
```

### Meaning

This KPI shows the total number of picking operations recorded in the warehouse.

### Why We Chose It

Picking is the central activity in the OBETA warehouse case. Counting picks gives a direct view of the total operational workload.

### Business Question Answered

```text
How many picking actions happened in the warehouse?
```

---

## 2. Total Pick Volume

### Dashboard Value

```text
2,087,058,309
```

### Calculation

```sql
SUM(pick_volume)
```

or:

```sql
SELECT SUM(pick_volume) AS total_pick_volume
FROM obeta_production.pick;
```

### Meaning

This KPI shows the total quantity or volume handled during all picking operations.

### Why We Chose It

The number of picks tells us how many operations happened, but not how large those operations were. `pick_volume` measures the total amount handled by the warehouse.

### Business Question Answered

```text
How much total product volume was handled by the warehouse?
```

---

## 3. Average Order Duration

### Dashboard Value

```text
140.8 minutes
```

### Calculation

```sql
AVG(order_duration)
```

or:

```sql
SELECT AVG(order_duration) AS average_order_duration
FROM obeta_production.pick;
```

### Meaning

This KPI shows the average time required to process an order.

### How It Was Created

The field `order_duration` was created during the transformation process:

1. Group records by `order_id`.
2. Identify the earliest timestamp for each order.
3. Identify the latest timestamp for each order.
4. Calculate the difference between the latest and earliest timestamp.
5. Store the result as `order_duration`.

### Why We Chose It

This is a warehouse efficiency KPI. It helps evaluate how long orders take to complete.

### Business Question Answered

```text
How long does an average OBETA order take to be picked?
```

---

## 4. Products Used in Picks

### Dashboard Value

```text
97,307
```

### Calculation

```sql
COUNT(DISTINCT product_id)
```

or, using the production star schema:

```sql
SELECT COUNT(DISTINCT product_key) AS products_used_in_picks
FROM obeta_production.pick;
```

### Meaning

This KPI shows how many different products were involved in picking operations.

### Why We Chose It

A higher number of unique products means more product variety and more warehouse complexity.

### Business Question Answered

```text
How many different products were actually picked?
```

---

## 5. Number of Orders

### Dashboard Value

```text
6,928,450
```

### Calculation

```sql
COUNT(DISTINCT order_id)
```

or, using the production dimension table:

```sql
SELECT COUNT(*) AS number_of_orders
FROM obeta_production.`order`;
```

### Meaning

This KPI shows the total number of unique orders processed.

### Why We Chose It

Orders represent the business demand behind the picking operations.

### Business Question Answered

```text
How many orders generated the warehouse workload?
```

---

## Navigation

[Previous: Data Model](02-data-model.md) | [Repository Home](../README.md) | [Next: Dashboard Charts](04-dashboard-charts.md)
