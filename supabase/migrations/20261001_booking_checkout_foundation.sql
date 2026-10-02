-- OpenSlot payments + booking details foundation
alter table public.profiles add column if not exists phone text;
alter table public.businesses add column if not exists contact_email text;
alter table public.businesses add column if not exists contact_phone text;
alter table public.businesses add column if not exists address_line1 text;
alter table public.businesses add column if not exists postal_code text;
alter table public.businesses add column if not exists stripe_account_id text;
alter table public.businesses add column if not exists stripe_onboarding_complete boolean not null default false;

alter table public.bookings add column if not exists customer_name text;
alter table public.bookings add column if not exists customer_email text;
alter table public.bookings add column if not exists customer_phone text;
alter table public.bookings add column if not exists booking_reference text;
alter table public.bookings add column if not exists amount_cents integer;
alter table public.bookings add column if not exists currency text not null default 'cad';
alter table public.bookings add column if not exists payment_status text not null default 'unpaid';
alter table public.bookings add column if not exists stripe_checkout_session_id text;
alter table public.bookings add column if not exists stripe_payment_intent_id text;
alter table public.bookings add column if not exists confirmed_at timestamptz;

create unique index if not exists bookings_reference_uidx on public.bookings(booking_reference) where booking_reference is not null;
create unique index if not exists bookings_checkout_uidx on public.bookings(stripe_checkout_session_id) where stripe_checkout_session_id is not null;

create or replace function public.book_open_slot(
  p_slot_id uuid,
  p_quantity integer default 1,
  p_customer_name text default null,
  p_customer_email text default null,
  p_customer_phone text default null
) returns uuid
language plpgsql security definer set search_path=public
as $$
declare s public.open_slots%rowtype; bid uuid; ref text;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select * into s from public.open_slots where id=p_slot_id for update;
  if not found or s.status<>'open' or s.expires_at<=now() then raise exception 'Slot unavailable'; end if;
  if p_quantity<1 or s.quantity_available<p_quantity then raise exception 'Insufficient availability'; end if;
  ref := 'OS-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8));
  insert into public.bookings(slot_id,customer_id,quantity,customer_name,customer_email,customer_phone,booking_reference,amount_cents,payment_status,confirmed_at)
  values(p_slot_id,auth.uid(),p_quantity,p_customer_name,p_customer_email,p_customer_phone,ref,
    case when s.price_cents is null then null else s.price_cents*p_quantity end,
    case when coalesce(s.price_cents,0)=0 then 'not_required' else 'unpaid' end,
    case when coalesce(s.price_cents,0)=0 then now() else null end)
  returning id into bid;
  update public.open_slots set quantity_available=quantity_available-p_quantity,
    status=case when quantity_available-p_quantity=0 then 'booked'::public.slot_status else status end
  where id=p_slot_id;
  return bid;
end $$;

revoke all on function public.book_open_slot(uuid,integer,text,text,text) from public;
grant execute on function public.book_open_slot(uuid,integer,text,text,text) to authenticated;
