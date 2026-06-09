-- ============================================================
--  HR Report Generator — Supabase Database Setup
--  วิธีใช้: เปิด Supabase Dashboard → SQL Editor → วาง + Run
-- ============================================================

-- 1. Employee Master
CREATE TABLE IF NOT EXISTS employees (
  emp_code      text PRIMARY KEY,
  name          text,
  grade         text,
  position      text,
  service_type  text,
  payment_type  text,
  shift_ref     text,
  day_shifts    jsonb,          -- { "1": "OTA", "2": "OTB", ... }
  updated_at    timestamptz DEFAULT now()
);

-- 2. Shift Definitions
CREATE TABLE IF NOT EXISTS shifts (
  shift_code   text PRIMARY KEY,
  position     text,
  type         text,
  time_str     text,
  time_start   text,
  time_end     text,
  break1_out   text,
  break1_in    text,
  updated_at   timestamptz DEFAULT now()
);

-- 3. Attendance Records
--    UNIQUE(emp_id, date) → upsert ทับได้เมื่อ re-upload
CREATE TABLE IF NOT EXISTS attendance (
  id             uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  emp_id         text NOT NULL,
  emp_name       text,
  dept           text,
  date           date NOT NULL,
  month          smallint,
  year           smallint,
  clock_in_time  text,
  clock_out_time text,
  work_time      text,
  ot_time        text,
  late_time      text,
  status         text,
  clock_in_src   text,
  uploaded_at    timestamptz DEFAULT now(),
  UNIQUE (emp_id, date)
);

-- ── Indexes ──
CREATE INDEX IF NOT EXISTS idx_attendance_month_year ON attendance (year, month);
CREATE INDEX IF NOT EXISTS idx_attendance_emp_id     ON attendance (emp_id);

-- ── Disable RLS (internal tool, no login) ──
ALTER TABLE employees  DISABLE ROW LEVEL SECURITY;
ALTER TABLE shifts     DISABLE ROW LEVEL SECURITY;
ALTER TABLE attendance DISABLE ROW LEVEL SECURITY;

-- ── ตรวจสอบว่าสร้างถูกต้อง ──
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('employees','shifts','attendance');
