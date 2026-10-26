-- جدول رسائل نموذج "تواصل معنا"
-- شغّل هذا الملف مرة واحدة من: Supabase Dashboard > SQL Editor

create table if not exists public.messages (
  id         bigint generated always as identity primary key,
  name       text        not null check (char_length(btrim(name)) between 2 and 100),
  phone      text        not null check (phone ~ '^\+?[0-9 ]{8,20}$'),
  message    text        not null check (char_length(btrim(message)) between 2 and 2000),
  created_at timestamptz not null default now()
);

-- تشغيل Row Level Security
alter table public.messages enable row level security;

-- سحب كل الصلاحيات من الأدوار العامة، ثم منح الإضافة فقط على الأعمدة الثلاثة
-- (وقت الإرسال يضعه الخادم تلقائياً ولا يستطيع الزائر تزويره)
revoke all on table public.messages from anon, authenticated;
grant insert (name, phone, message) on table public.messages to anon, authenticated;

-- سياسة واحدة: الإضافة فقط. لا توجد سياسات قراءة أو تعديل أو حذف، فكلها مرفوضة.
drop policy if exists "messages_insert_only" on public.messages;
create policy "messages_insert_only"
  on public.messages
  for insert
  to anon, authenticated
  with check (true);
