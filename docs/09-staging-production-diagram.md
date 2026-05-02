# 09. Staging / Production Methodology Diagram

This document contains a **Mermaid diagram** that shows how the **staging/production methodology** works in the OBETA project.

---

> **Rendering note:** Mermaid diagrams render only in compatible Markdown viewers such as **GitHub** or **VS Code Markdown Preview**. If you only see code, open this file on GitHub or use the raw Mermaid source file: [../assets/staging-production-methodology.mmd](../assets/staging-production-methodology.mmd).

## 1. High-Level Methodology Diagram

```mermaid
flowchart LR
    A[Raw CSV Files
Source data] --> B[Stream 1
Raw to Staging]
    B --> C[(obeta_staging.pick_data)]
    B --> D[(obeta_staging.product_data)]
    B --> E[(obeta_staging.warehouse_sections)]

    C --> F[Stream 2
Clean and Transform in Staging]
    D --> F
    E --> F

    F --> G[(obeta_staging.pickoperations)]

    G --> H[Stream 3
Staging to Production]
    H --> I[(obeta_production.product)]
    H --> J[(obeta_production.order)]
    H --> K[(obeta_production.pick)]

    I --> L[Dashboard / Analytics / Reporting]
    J --> L
    K --> L
```

---

## 2. Layer-by-Layer Responsibility Diagram

```mermaid
flowchart TB
    subgraph S1[Source Layer]
        A1[CSV: pick_data]
        A2[CSV: product_data]
        A3[CSV: warehouse_sections]
    end

    subgraph S2[Staging Layer - obeta_staging]
        B1[pick_data
Raw operational data]
        B2[product_data
Raw product reference]
        B3[warehouse_sections
Warehouse reference]
        B4[pickoperations
Cleaned and enriched staging table]
    end

    subgraph S3[Production Layer - obeta_production]
        C1[product
Dimension]
        C2[order
Dimension]
        C3[pick
Fact]
    end

    subgraph S4[Consumption Layer]
        D1[Tableau / Power BI Dashboard]
        D2[KPIs, Charts, Analytics]
    end

    A1 --> B1
    A2 --> B2
    A3 --> B3

    B1 --> B4
    B2 --> B4
    B3 --> B4

    B4 --> C1
    B4 --> C2
    B4 --> C3

    C1 --> D1
    C2 --> D1
    C3 --> D1
    D1 --> D2
```

---

## 3. What the diagram shows

- **Source files** are the starting point.
- **Stream 1** loads raw files into the `obeta_staging` database.
- **Stream 2** cleans, enriches, and transforms the raw staging data into `pickoperations`.
- **Stream 3** converts the cleaned staging output into the final **production star schema**.
- The dashboard reads from the **production layer**, not from the raw staging tables.

This is the core idea of the methodology: **prepare first, analyze later**.

---

## 4. Why the diagram matters

The diagram helps explain that the project is not just a dashboard. It is a complete mini data warehouse process:

1. **Ingest raw data**
2. **Stage and clean data**
3. **Model it for analytics**
4. **Use the final model for reporting**

This is why the methodology is robust, explainable, and closer to real-world BI and data engineering practice.

---

## Navigation

⬅️ Previous: [08. Staging / Production Methodology](08-staging-production-methodology.md)  
🏠 [Repository Home](../README.md)  
➡️ Next: [10. Production ER Diagram](10-production-er-diagram.md)
