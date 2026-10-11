# Surgical Checklist Analysis

SQLite portfolio project analyzing compliance with surgical safety checklist items across 20,000 procedures from January through June 2026.

## Business question

Where are the most meaningful surgical checklist compliance gaps, and which units or time periods should leaders prioritize for improvement?

## Key findings

1. **Two checklist items are clear priorities:** surgical site marking was compliant in **76.9%** of observations and specimen labeling in **77.4%**, compared with approximately **92%** for the other items.
2. **OR-3 is the lowest-performing unit:** compliance was **82.7%**, compared with approximately **91%** in OR-1, OR-2, and OR-4.
3. **Compliance improved over time:** monthly compliance rose from **86.1% in January** to **91.6% in June**, a 5.5 percentage-point improvement.

## Repository layout

```text
data/
  procedures_raw.csv          # original synthesized procedure data
  checklist_items_raw.csv    # original synthesized checklist data
sql/
  schema.sql                 # normalized SQLite tables and inserts
  queries.sql                # ten analysis queries, from basic to advanced
charts/                      # README chart images
```

## How to reproduce in DB Browser for SQLite

1. Open DB Browser for SQLite and create a new database named `surgical_checklist_analysis.db`.
2. Use **File → Import → Table from CSV file** to import both files in `data/`.
3. Keep the imported table names as `procedures_raw` and `checklist_items_raw`.
4. Open `sql/schema.sql` in the **Execute SQL** tab and run it.
5. Confirm that the eight normalized tables appear under the **Database Structure** tab.
6. Run the queries in `sql/queries.sql` one at a time. Export the three result sets used for the charts if needed.
7. Create the three charts below in Excel or another spreadsheet application and save them in `charts/`.

DB Browser is intended for database inspection and SQL execution. It does not provide a full chart-building workflow, so Excel is the quickest way to create the three README visuals from the exported query results.

## Charts

The final README should contain only these three visuals:

1. Compliance by checklist item, highlighting surgical site marking and specimen labeling.
2. Compliance by unit, highlighting OR-3 against the other operating rooms.
3. Monthly compliance trend from January through June 2026.

## Data model

The raw files are retained unchanged and used as staging tables. `schema.sql` normalizes them into eight analytical tables: `units`, `patients`, `surgeons`, `procedure_types`, `item_definitions`, `staff`, `procedures`, and `checklist_items`.

The data is synthesized and contains no real patient records. The raw files are intentionally included to make the project reproducible.

## Skills demonstrated

- SQLite table design and foreign-key relationships
- Normalization from flat CSV data
- Joins across fact and dimension tables
- Aggregation, conditional logic, date grouping, and threshold filtering
- Translating SQL output into concise operational findings

