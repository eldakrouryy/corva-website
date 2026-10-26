-- جدول طلبات عروض الأسعار من نموذج "قدّم شركتك"
-- شغّل هذا الملف مرة واحدة من: Supabase Dashboard > SQL Editor (انسخ المحتوى والصقه)

create table if not exists public.leads (
  id                bigint generated always as identity primary key,
  -- الخطوة 1: عن الشركة
  company           text        not null check (char_length(btrim(company)) between 2 and 150),
  sector            text        not null check (char_length(sector) between 1 and 60),
  employees         text        not null check (char_length(employees) between 1 and 30),
  city              text                 check (char_length(city) <= 60),
  -- الخطوة 2: الاحتياجات
  current_insurance text                 check (char_length(current_insurance) <= 60),
  priorities        text[]      not null default '{}' check (cardinality(priorities) <= 10),
  notes             text                 check (char_length(notes) <= 2000),
  -- الخطوة 3: بيانات التواصل
  contact_name      text        not null check (char_length(btrim(contact_name)) between 2 and 100),
  role              text        not null check (char_length(role) between 1 and 60),
  phone             text        not null check (phone ~ '^\+?[0-9 ]{8,20}$'),
  email             text        not null check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' and char_length(email) <= 150),
  -- من أقسام أخرى في الصفحة
  offer             text                 check (offer in ('launch-10')),
  plan              jsonb                check (pg_column_size(plan) <= 2000),
  created_at        timestamptz not null default now()
);

-- تشغيل Row Level Security
alter table public.leads enable row level security;

-- الإضافة فقط، وعلى أعمدة البيانات فقط (id و created_at يضعهما الخادم)
revoke all on table public.leads from anon, authenticated;
grant insert (company, sector, employees, city, current_insurance, priorities, notes,
              contact_name, role, phone, email, offer, plan)
  on table public.leads to anon, authenticated;

-- سياسة واحدة: الإضافة فقط. لا قراءة ولا تعديل ولا حذف.
drop policy if exists "leads_insert_only" on public.leads;
create policy "leads_insert_only"
  on public.leads
  for insert
  to anon, authenticated
  with check (true);
