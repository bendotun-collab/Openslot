-- OpenSlot v1.4: scalable marketplace categories and subcategories
create table if not exists public.marketplace_categories(
  id text primary key,
  name text not null,
  description text,
  sort_order integer not null default 0,
  active boolean not null default true
);
create table if not exists public.marketplace_subcategories(
  id text primary key,
  category_id text not null references public.marketplace_categories(id) on delete cascade,
  name text not null,
  sort_order integer not null default 0,
  active boolean not null default true
);
alter table public.businesses add column if not exists category_id text references public.marketplace_categories(id);
alter table public.businesses add column if not exists subcategory_id text references public.marketplace_subcategories(id);
alter table public.open_slots add column if not exists category_id text references public.marketplace_categories(id);
alter table public.open_slots add column if not exists subcategory_id text references public.marketplace_subcategories(id);

insert into public.marketplace_categories(id,name,description,sort_order) values
('service','Beauty & Services','Appointments and service capacity that just opened up',10),
('dining','Dining','Restaurant tables that just became available',20),
('catering','Food & Catering','Prepared food and catering capacity available now',30),
('events','Events & Spaces','Event spaces and event professionals with newly available time',40)
on conflict(id) do update set name=excluded.name,description=excluded.description,sort_order=excluded.sort_order;

insert into public.marketplace_subcategories(id,category_id,name,sort_order) values
('hair-barber','service','Hair & Barber',10),('beauty','service','Beauty & Nails',20),('wellness','service','Wellness & Massage',30),('fitness','service','Fitness & Training',40),('pet-services','service','Pet Services',50),
('restaurants','dining','Restaurants',10),
('prepared-food','catering','Prepared Food',10),('caterers','catering','Caterers',20),
('event-venues','events','Event Venues',10),('photography-studios','events','Photography Studios',20),('photographers','events','Photographers',30),('videographers','events','Videographers',40),('djs-entertainers','events','DJs & Entertainers',50),('decorators','events','Decorators',60),('makeup-artists','events','Makeup Artists',70),('event-caterers','events','Event Caterers',80)
on conflict(id) do update set category_id=excluded.category_id,name=excluded.name,sort_order=excluded.sort_order;

alter table public.marketplace_categories enable row level security;
alter table public.marketplace_subcategories enable row level security;
drop policy if exists "public categories read" on public.marketplace_categories;
create policy "public categories read" on public.marketplace_categories for select using(active=true);
drop policy if exists "public subcategories read" on public.marketplace_subcategories;
create policy "public subcategories read" on public.marketplace_subcategories for select using(active=true);
