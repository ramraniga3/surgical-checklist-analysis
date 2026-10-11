-- Surgical checklist analysis: normalized SQLite schema
-- Run after importing the two CSV files as:
--   procedures_raw
--   checklist_items_raw

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS checklist_items;
DROP TABLE IF EXISTS procedures;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS item_definitions;
DROP TABLE IF EXISTS procedure_types;
DROP TABLE IF EXISTS surgeons;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS units;

CREATE TABLE units (
    unit_id INTEGER PRIMARY KEY,
    unit_name TEXT NOT NULL UNIQUE,
    unit_floor INTEGER NOT NULL,
    unit_beds INTEGER NOT NULL
);

CREATE TABLE patients (
    patient_id TEXT PRIMARY KEY,
    patient_age INTEGER NOT NULL,
    patient_sex TEXT NOT NULL
);

CREATE TABLE surgeons (
    surgeon_id TEXT PRIMARY KEY,
    surgeon_name TEXT NOT NULL,
    surgeon_specialty TEXT NOT NULL,
    surgeon_years_exp INTEGER NOT NULL
);

CREATE TABLE procedure_types (
    procedure_type_id INTEGER PRIMARY KEY,
    procedure_type TEXT NOT NULL,
    procedure_category TEXT NOT NULL,
    typical_duration_min INTEGER NOT NULL,
    risk_level TEXT NOT NULL,
    UNIQUE (procedure_type, procedure_category, typical_duration_min, risk_level)
);

CREATE TABLE item_definitions (
    item_definition_id INTEGER PRIMARY KEY,
    item_name TEXT NOT NULL UNIQUE,
    item_category TEXT NOT NULL,
    is_critical INTEGER NOT NULL CHECK (is_critical IN (0, 1))
);

CREATE TABLE staff (
    staff_id TEXT PRIMARY KEY,
    staff_name TEXT NOT NULL,
    staff_role TEXT NOT NULL
);

CREATE TABLE procedures (
    procedure_id INTEGER PRIMARY KEY,
    procedure_date TEXT NOT NULL,
    procedure_type_id INTEGER NOT NULL REFERENCES procedure_types(procedure_type_id),
    unit_id INTEGER NOT NULL REFERENCES units(unit_id),
    surgeon_id TEXT NOT NULL REFERENCES surgeons(surgeon_id),
    patient_id TEXT NOT NULL REFERENCES patients(patient_id),
    anesthesia_type TEXT NOT NULL,
    scheduled_duration_min INTEGER NOT NULL,
    actual_duration_min INTEGER NOT NULL
);

CREATE TABLE checklist_items (
    checklist_item_id INTEGER PRIMARY KEY,
    procedure_id INTEGER NOT NULL REFERENCES procedures(procedure_id),
    item_definition_id INTEGER NOT NULL REFERENCES item_definitions(item_definition_id),
    compliant INTEGER NOT NULL CHECK (compliant IN (0, 1)),
    recorded_at TEXT NOT NULL,
    recorded_by_staff_id TEXT NOT NULL REFERENCES staff(staff_id),
    notes TEXT
);

CREATE INDEX idx_checklist_items_procedure_id ON checklist_items(procedure_id);
CREATE INDEX idx_checklist_items_item_definition_id ON checklist_items(item_definition_id);
CREATE INDEX idx_procedures_date ON procedures(procedure_date);
CREATE INDEX idx_procedures_unit_id ON procedures(unit_id);

INSERT INTO units (unit_id, unit_name, unit_floor, unit_beds)
SELECT ROW_NUMBER() OVER (ORDER BY unit), unit, unit_floor, unit_beds
FROM (SELECT DISTINCT unit, unit_floor, unit_beds FROM procedures_raw);

INSERT INTO patients (patient_id, patient_age, patient_sex)
SELECT DISTINCT patient_id, patient_age, patient_sex FROM procedures_raw;

INSERT INTO surgeons (surgeon_id, surgeon_name, surgeon_specialty, surgeon_years_exp)
SELECT DISTINCT surgeon_id, surgeon_name, surgeon_specialty, surgeon_years_exp FROM procedures_raw;

INSERT INTO procedure_types
    (procedure_type_id, procedure_type, procedure_category, typical_duration_min, risk_level)
SELECT ROW_NUMBER() OVER (ORDER BY procedure_type, procedure_category),
       procedure_type, procedure_category, typical_duration_min, risk_level
FROM (SELECT DISTINCT procedure_type, procedure_category, typical_duration_min, risk_level
      FROM procedures_raw);

INSERT INTO item_definitions (item_definition_id, item_name, item_category, is_critical)
SELECT ROW_NUMBER() OVER (ORDER BY item_name), item_name, item_category, is_critical
FROM (SELECT DISTINCT item_name, item_category, is_critical FROM checklist_items_raw);

INSERT INTO staff (staff_id, staff_name, staff_role)
SELECT DISTINCT recorded_by_staff_id, recorded_by_staff_name, recorded_by_staff_role
FROM checklist_items_raw;

INSERT INTO procedures
    (procedure_id, procedure_date, procedure_type_id, unit_id, surgeon_id, patient_id,
     anesthesia_type, scheduled_duration_min, actual_duration_min)
SELECT p.procedure_id,
       p.procedure_date,
       pt.procedure_type_id,
       u.unit_id,
       p.surgeon_id,
       p.patient_id,
       p.anesthesia_type,
       p.scheduled_duration_min,
       p.actual_duration_min
FROM procedures_raw p
JOIN procedure_types pt
  ON pt.procedure_type = p.procedure_type
 AND pt.procedure_category = p.procedure_category
 AND pt.typical_duration_min = p.typical_duration_min
 AND pt.risk_level = p.risk_level
JOIN units u ON u.unit_name = p.unit;

INSERT INTO checklist_items
    (checklist_item_id, procedure_id, item_definition_id, compliant, recorded_at,
     recorded_by_staff_id, notes)
SELECT c.item_id,
       c.procedure_id,
       i.item_definition_id,
       c.compliant,
       c.recorded_at,
       c.recorded_by_staff_id,
       NULLIF(c.notes, '')
FROM checklist_items_raw c
JOIN item_definitions i ON i.item_name = c.item_name;

