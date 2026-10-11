-- Surgical checklist analysis queries
-- These queries run against the normalized tables created by schema.sql.

-- 1. Overall compliance
SELECT ROUND(100.0 * AVG(compliant), 1) AS overall_compliance_pct
FROM checklist_items;

-- 2. Compliance by checklist item
SELECT i.item_name,
       COUNT(*) AS observations,
       SUM(c.compliant) AS compliant_observations,
       ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items c
JOIN item_definitions i ON i.item_definition_id = c.item_definition_id
GROUP BY i.item_definition_id, i.item_name
ORDER BY compliance_pct;

-- 3. Critical versus non-critical item compliance
SELECT i.is_critical,
       COUNT(*) AS observations,
       ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items c
JOIN item_definitions i ON i.item_definition_id = c.item_definition_id
GROUP BY i.is_critical;

-- 4. Compliance by operating-room unit
SELECT u.unit_name,
       COUNT(*) AS observations,
       ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items c
JOIN procedures p ON p.procedure_id = c.procedure_id
JOIN units u ON u.unit_id = p.unit_id
GROUP BY u.unit_id, u.unit_name
ORDER BY compliance_pct;

-- 5. Monthly compliance trend
SELECT substr(p.procedure_date, 1, 7) AS month,
       COUNT(*) AS observations,
       ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items c
JOIN procedures p ON p.procedure_id = c.procedure_id
GROUP BY month
ORDER BY month;

-- 6. Compliance by procedure category
SELECT pt.procedure_category,
       COUNT(*) AS observations,
       ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items c
JOIN procedures p ON p.procedure_id = c.procedure_id
JOIN procedure_types pt ON pt.procedure_type_id = p.procedure_type_id
GROUP BY pt.procedure_category
ORDER BY compliance_pct;

-- 7. Compliance by risk level
SELECT pt.risk_level,
       COUNT(*) AS observations,
       ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items c
JOIN procedures p ON p.procedure_id = c.procedure_id
JOIN procedure_types pt ON pt.procedure_type_id = p.procedure_type_id
GROUP BY pt.risk_level
ORDER BY compliance_pct;

-- 8. Unit-by-item gaps (useful for targeting an intervention)
SELECT u.unit_name,
       i.item_name,
       COUNT(*) AS observations,
       ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items c
JOIN procedures p ON p.procedure_id = c.procedure_id
JOIN units u ON u.unit_id = p.unit_id
JOIN item_definitions i ON i.item_definition_id = c.item_definition_id
GROUP BY u.unit_id, u.unit_name, i.item_definition_id, i.item_name
HAVING COUNT(*) >= 100
ORDER BY compliance_pct, u.unit_name;

-- 9. Procedure-duration variance by unit
SELECT u.unit_name,
       COUNT(*) AS procedures,
       ROUND(AVG(p.actual_duration_min - p.scheduled_duration_min), 1)
           AS avg_duration_variance_min,
       ROUND(100.0 * AVG(
           CASE WHEN p.actual_duration_min <= p.scheduled_duration_min THEN 1.0 ELSE 0.0 END
       ), 1) AS on_or_under_schedule_pct
FROM procedures p
JOIN units u ON u.unit_id = p.unit_id
GROUP BY u.unit_id, u.unit_name
ORDER BY avg_duration_variance_min DESC;

-- 10. Staff-level compliance, with a minimum observation threshold
SELECT s.staff_name,
       s.staff_role,
       COUNT(*) AS observations,
       ROUND(100.0 * AVG(c.compliant), 1) AS compliance_pct
FROM checklist_items c
JOIN staff s ON s.staff_id = c.recorded_by_staff_id
GROUP BY s.staff_id, s.staff_name, s.staff_role
HAVING COUNT(*) >= 500
ORDER BY compliance_pct;

