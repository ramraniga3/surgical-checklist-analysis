SELECT
    COUNT(*) AS total_observations,
    SUM(compliant) AS compliant_observations,
    ROUND(100.0 * AVG(compliant), 1) AS compliance_pct
FROM checklist_items;

SELECT
    d.item_name,
    COUNT(*) AS observations,
    SUM(c.compliant) AS compliant_observations,
    ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items AS c
JOIN item_definitions AS d
    ON c.item_definition_id = d.item_definition_id
GROUP BY d.item_name
ORDER BY compliance_pct;


SELECT
    u.unit_name,
    COUNT(*) AS observations,
    SUM(c.compliant) AS compliant_observations,
    ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items AS c
JOIN procedures AS p
    ON c.procedure_id = p.procedure_id
JOIN units AS u
    ON p.unit_name = u.unit_name
GROUP BY u.unit_name
ORDER BY compliance_pct;

SELECT 
strftime('%Y-%m' , p.procedure_date) AS procedure_month,
count (*) AS observations,
sum(c.compliant) AS compliant_observations,
ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items as c
JOIN procedures AS p
ON c.procedure_id = p.procedure_id
GROUP BY procedure_month
ORDER BY compliance_pct;

SELECT
pt.procedure_category,
COUNT(*) AS observations,
    SUM(c.compliant) AS compliant_observations,
    ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items AS c 
JOIN procedures AS p
ON c.procedure_id = p.procedure_id
JOIN procedure_types AS pt
ON p.procedure_type_id = pt.procedure_type_id
GROUP BY pt.procedure_category
ORDER BY compliance_pct;

SELECT 
pt.risk_level,
COUNT (*) AS observations,
sum (c.compliant) AS compliant_observations,
round ( 100 * avg(c.compliant), 1) AS compliance_pct
FROM checklist_items AS c
JOIN procedures AS p
ON c.procedure_id = p.procedure_id
Join procedure_types as pt
ON p.procedure_type_id = pt.procedure_type_id
GROUP BY pt.risk_level
ORDER By compliance_pct;

SELECT 
u.unit_name,
d.item_name,
COUNT (*) AS observations,
sum (c.compliant) AS compliant_observations,
round ( 100 * avg(c.compliant), 1) AS compliance_pct
FROM checklist_items AS c
JOIN procedures as p
ON c.procedure_id = p.procedure_id
JOIN units as u
ON p.unit_name = u.unit_name
JOIN item_definitions as d
ON c.item_definition_id = d.item_definition_id
group by 
u.unit_name, 
d.item_name
ORDER BY
u.unit_name,
compliance_pct;

SELECT
    TRIM(s.recorded_by_staff_role) AS staff_role,
    COUNT(*) AS observations,
    SUM(c.compliant) AS compliant_observations,
    ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items AS c
JOIN staff AS s
    ON c.recorded_by_staff_id = s.recorded_by_staff_id
GROUP BY TRIM(s.recorded_by_staff_role)
ORDER BY compliance_pct;

SELECT
    pt.procedure_type,
    COUNT(*) AS procedures,
    ROUND(AVG(p.scheduled_duration_min), 1) AS avg_scheduled_min,
    ROUND(AVG(p.actual_duration_min), 1) AS avg_actual_min,
    ROUND(AVG(p.actual_duration_min - p.scheduled_duration_min), 1)
	AS avg_difference_min
	From procedures as p
	JOIN procedure_types as pt
	ON p.procedure_type_id = pt.procedure_type_id
	GROUP by pt.procedure_type
	ORDER by avg_difference_min;
  
  -- for the READ me

	SELECT
    d.item_name,
    ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items AS c
JOIN item_definitions AS d
    ON c.item_definition_id = d.item_definition_id
GROUP BY d.item_name
ORDER BY compliance_pct;

SELECT
    u.unit_name,
    ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items AS c
JOIN procedures AS p
    ON c.procedure_id = p.procedure_id
JOIN units AS u
    ON p.unit_name = u.unit_name
GROUP BY u.unit_name
ORDER BY compliance_pct;

SELECT
    strftime('%Y-%m', p.procedure_date) AS procedure_month,
    ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items AS c
JOIN procedures AS p
    ON c.procedure_id = p.procedure_id
GROUP BY procedure_month
ORDER BY procedure_month;