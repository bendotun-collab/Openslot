-- OpenSlot v1.3: reusable product/service catalogue
create table if not exists public.catalogue_items(
 id uuid primary key default gen_random_uuid(),
 business_id uuid not null references public.businesses(id) on delete cascade,
 name text not null,
 description text,
 default_price_cents integer check(default_price_cents is null or default_price_cents>=0),
 unit_label text,
 duration_minutes integer check(duration_minutes is null or duration_minutes>0),
 active boolean not null default true,
 created_at timestamptz default now()
);
alter table public.catalogue_items enable row level security;
create policy "public catalogue read" on public.catalogue_items for select using(active=true);
create policy "owner manages catalogue" on public.catalogue_items for all to authenticated
 using(exists(select 1 from public.businesses b where b.id=business_id and b.owner_id=auth.uid()))
 with check(exists(select 1 from public.businesses b where b.id=business_id and b.owner_id=auth.uid()));
alter table public.open_slots add column if not exists catalogue_item_id uuid references public.catalogue_items(id) on delete set null;
