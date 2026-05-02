# 05. Presentation Script

## Complete Short Explanation

The OBETA dashboard was designed to analyze warehouse picking performance. We used the final production star schema, where `pick` is the fact table and `product` and `order` are dimension tables.

We selected the main KPIs because they summarize the most important parts of the picking process: total activity, total volume, processing time, product variety, and number of orders.

The **Number of Picks** shows the total number of picking operations. The **Total Pick Volume** shows the total quantity handled in the warehouse. The **Average Order Duration** measures the average time needed to complete an order. The **Products Used in Picks** shows how many different products were involved, and the **Number of Orders** shows how many unique orders generated the picking workload.

The visualizations then explain these KPIs in more detail. The line chart shows picking activity over time. The product group chart shows which categories generate the most work. The origin charts compare customer and store orders. The warehouse section chart shows where the largest volume is handled.

Overall, the dashboard helps identify workload concentration, operational trends, and efficiency differences in the OBETA warehouse picking process.

---

## Very Short Version for Slides

The dashboard uses the OBETA production star schema: `pick` as the fact table and `product` and `order` as dimension tables.

The selected KPIs measure:

- Total picking activity
- Total handled volume
- Average order processing duration
- Product variety
- Number of processed orders

The charts explain the KPIs over time and by product group, order origin, and warehouse section. This helps identify trends, workload distribution, and operational efficiency.

---

## One-Minute Oral Explanation

This dashboard analyzes OBETA warehouse picking performance. We built it using the production star schema, where the `pick` table stores the measurable picking operations and the `product` and `order` tables provide the context.

We chose these KPIs because they answer the most important operational questions: how many picks were made, how much volume was handled, how long orders took, how many products were involved, and how many orders were processed.

Then, the charts help us understand where the workload comes from. We can see activity over time, the product groups with the most picks, the difference between customer and store orders, and the warehouse sections with the highest pick volume.

In summary, the dashboard gives a clear view of workload, efficiency, and operational patterns in the OBETA picking process.

---

## Navigation

[Previous: Dashboard Charts](04-dashboard-charts.md) | [Repository Home](../README.md) | [Next: Remarks, Suggestions and Improvements](06-remarks-suggestions-improvements.md)
