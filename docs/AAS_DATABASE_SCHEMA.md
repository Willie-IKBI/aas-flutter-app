AAS_DATASCHEMA.md

All Africa Supplies — Data Schema & Security Specification
Backend: Supabase (Postgres + Auth + Storage + RLS)
Version: v1.0 (matches the latest SQL we generated)

0) Design Principles

Single source of truth per concept (Order, Customer, Part, Allocation).

Event-sourced pipeline: order_stage_events is the append-only history for stages.

Files in Storage; DB stores only metadata & storage paths.

Predictable names: snake_case; singular table names only if deeply conventional (we use plural).

Enums > free text for core domains (role, order status/stage, document category).

RLS first: Every table has row-level security and explicit policies.

1) Enums
-- Order status in overall lifecycle
order_status = ('draft','in_progress','waiting_approval','approved','in_production','complete','cancelled')

-- Pipeline stage transitions (current_stage points here)
order_stage = (
  'order_captured','wash_bay','assessment','quotation',
  'approval','job_commence','paint','dispatch'
)

-- Application user roles (stored in profiles.role)
user_role = ('admin','manager','sales','technician')

-- File/document taxonomy
document_category = ('photo','quotation_pdf','approval_doc','dispatch_doc','generic')


Usage notes

orders.status is the business status; orders.current_stage is the latest pipeline node.

To advance a stage: insert into order_stage_events and update orders.current_stage.

2) Tables (DDL & Notes)
2.1 profiles

Purpose: 1:1 with auth.users; stores app role & user metadata.

Column	Type	Constraints / Notes
id	uuid	PK, references auth.users(id) on delete cascade
created_at	timestamptz	default now()
display_name	text	
role	user_role	not null, default 'technician'
email	text	unique
contact_number	text	
department	text	
location	text	
emp_id	text	

RLS

Select: self or admin/manager.

Insert/Update: self; admins/managers may update others.

2.2 customers

Purpose: Organisations/clients who receive services.

Column	Type	Constraints / Notes
id	bigserial	PK
created_at	timestamptz	default now()
client_name	text	required
contact_name	text	
contact_number	text	
contact_email	text	
address	text	(free text or JSON later)
industry_sector	text	
contact_channel	text	
notes	text	

Indexes: customers_created_at_idx (created_at desc)

RLS

Read: all authenticated.

Write: admin/manager/sales.

2.3 orders

Purpose: A job/work order.

Column	Type	Constraints / Notes
id	bigserial	PK
created_at	timestamptz	default now()
order_date	date	default today (UTC)
description	text	brief job summary
captured_by	uuid	FK → profiles.id
customer_id	bigint	FK → customers.id (restrict)
sales_rep_id	uuid	FK → profiles.id
status	order_status	default in_progress
current_stage	order_stage	default order_captured
pdf_url	text	latest compiled PDF (e.g., quotation or work summary)

Indexes:

orders_customer_id_idx (customer_id)

orders_status_idx (status)

orders_created_at_idx (created_at desc)

RLS

Read: all authenticated.

Insert: admin/manager/sales.

Update: admin/manager or anyone assigned (via resource_allocations).

Delete: admin/manager.

2.4 order_stage_events

Purpose: Append-only history of stage transitions/notes/measurements.

Column	Type	Constraints / Notes
id	bigserial	PK
created_at	timestamptz	default now()
order_id	bigint	FK → orders.id (cascade)
stage	order_stage	which stage this event records
opened_at	timestamptz	default now()
closed_at	timestamptz	nullable (open until closed)
actor_id	uuid	FK → profiles.id
notes	text	
payload	jsonb	ad-hoc details (e.g., { "odometer": 120345 })

Indexes:

ose_order_id_idx (order_id, created_at)

ose_stage_idx (stage)

RLS

Read: all authenticated.

Insert: admin/manager/sales or any assigned tech.

Update/Delete: admin/manager or actor_id (the user who created it).

Usage notes

Store any stage-specific fields in payload to avoid schema churn.

Close an event by setting closed_at. You can keep multiple events per stage over time.

2.5 order_documents

Purpose: Metadata for files (stored in Supabase Storage) linked to an order (and optionally to a stage).

Column	Type	Constraints / Notes
id	bigserial	PK
created_at	timestamptz	default now()
order_id	bigint	FK → orders.id (cascade)
stage	order_stage	optional stage association
category	document_category	required category
storage_path	text	required; e.g. order-files/{orderId}/image_001.jpg
filename	text	original filename
mime_type	text	image/jpeg, application/pdf, …
uploaded_by	uuid	FK → profiles.id
meta	jsonb	freeform metadata (e.g., { "width": 1024, "height": 768 })

Indexes: od_order_id_idx (order_id, created_at)

RLS

Read: all authenticated.

Insert: admin/manager/sales/assigned.

Delete: admin/manager or uploaded_by.

2.6 parts_inventory

Purpose: Parts/items catalog.

Column	Type	Constraints / Notes
id	bigserial	PK
created_at	timestamptz	default now()
part_name	text	required
part_description	text	
part_image_url	text	optional Storage path
part_location	text	shelf/bin
part_number	text	unique SKU
part_status	text	default 'Active'

Indexes:

parts_name_trgm_idx using gin (part_name gin_trgm_ops) (requires pg_trgm)

RLS

Read: all authenticated.

Write: admin/manager.

2.7 order_parts

Purpose: Parts used on an order.

Column	Type	Constraints / Notes
id	bigserial	PK
created_at	timestamptz	default now()
order_id	bigint	FK → orders.id (cascade)
part_id	bigint	FK → parts_inventory.id
qty	numeric(12,2)	default 1
notes	text	

Indexes: order_parts_order_idx (order_id)

RLS

Read: all authenticated.

Write: admin/manager or assigned users for that order.

2.8 resource_allocations

Purpose: Assign users/bays/roles to orders (drives “assigned” permissions).

Column	Type	Constraints / Notes
id	bigserial	PK
created_at	timestamptz	default now()
order_id	bigint	FK → orders.id (cascade)
assignee_id	uuid	FK → profiles.id
bay_allocation	text	e.g., “Bay 2”
role	user_role	optional role context
start_at	timestamptz	assignment start
end_at	timestamptz	assignment end
status	text	default 'Active'

Indexes: ra_order_idx (order_id, created_at)

RLS

Read: all authenticated.

Write: admin/manager only.

2.9 approvals (optional)

Purpose: When you want an explicit approval artifact (besides a stage event).

Column	Type	Constraints / Notes
id	bigserial	PK
created_at	timestamptz	default now()
order_id	bigint	FK → orders.id (cascade)
approved_at	timestamptz	
method	text	“email”, “signature”, etc.
approver_name	text	
approver_title	text	
notes	text	

Indexes: approvals_order_idx (order_id, created_at)

RLS

Read: all authenticated.

Write: admin/manager/sales.

3) Relationships (ER overview)

profiles (1) — (M) orders via captured_by, sales_rep_id

customers (1) — (M) orders

orders (1) — (M) order_stage_events

orders (1) — (M) order_documents

orders (1) — (M) order_parts

orders (1) — (M) resource_allocations

parts_inventory (1) — (M) order_parts

profiles (1) — (M) order_stage_events via actor_id

profiles (1) — (M) order_documents via uploaded_by

profiles (1) — (M) resource_allocations via assignee_id

4) Security (RLS) — Effective Rules
Helper functions

current_user_role() -> user_role

is_admin_or_manager() -> boolean

is_sales(), is_technician()

is_assigned_to_order(order_id bigint) -> boolean (checks resource_allocations with status = 'Active')

Table summary
Table	Read	Insert	Update/Delete
profiles	self or admin/manager	self	self or admin/manager
customers	all authenticated	sales/admin/manager	sales/admin/manager
orders	all authenticated	sales/admin/manager	admin/manager or assigned
order_stage_events	all authenticated	admin/manager/sales/assigned	admin/manager or actor
order_documents	all authenticated	admin/manager/sales/assigned	admin/manager or uploaded_by
parts_inventory	all authenticated	admin/manager	admin/manager
order_parts	all authenticated	admin/manager/assigned	admin/manager/assigned
resource_allocations	all authenticated	admin/manager	admin/manager
approvals	all authenticated	admin/manager/sales	admin/manager/sales

Assigned = exists resource_allocations row order_id=<id> and assignee_id=auth.uid() and status='Active'.

5) Views (Dashboards)
5.1 view_stage_duration_days

Average duration (days) per stage, using opened_at → closed_at (or now() if still open).

select * from public.view_stage_duration_days;
-- columns: stage, occurrences, avg_days

5.2 view_orders_by_stage

Counts by orders.current_stage.

select * from public.view_orders_by_stage;
-- columns: stage, orders_count

6) Patterns & Recipes
6.1 Create an order
insert into public.orders (customer_id, description, captured_by, sales_rep_id)
values (123, 'Repair & respray left panel', auth.uid(), auth.uid())
returning *;

6.2 Append a stage event (and advance current_stage)
-- event
insert into public.order_stage_events (order_id, stage, actor_id, notes, payload)
values (456, 'assessment', auth.uid(), 'Checked left panel', '{"odometer": 120345}')
returning *;

-- pointer
update public.orders set current_stage = 'assessment'
where id = 456;

6.3 Upload a file (client-side) & record it

Upload to Storage bucket order-files at path: order-files/{orderId}/{uuid}.jpg.

Then:

insert into public.order_documents
(order_id, stage, category, storage_path, filename, mime_type, uploaded_by, meta)
values
(456, 'assessment', 'photo', 'order-files/456/6d2a...jpg', 'photo.jpg', 'image/jpeg', auth.uid(), '{"width":1024,"height":768}');

6.4 Assign a technician to an order
insert into public.resource_allocations (order_id, assignee_id, bay_allocation, role, start_at, status)
values (456, '00000000-0000-0000-0000-000000000000', 'Bay 2', 'technician', now(), 'Active');

6.5 Search parts by name (trigram)
select id, part_name, part_number
from public.parts_inventory
where part_name ilike '%polish%'
order by similarity(part_name, 'polish') desc
limit 20;

7) Naming & Conventions

Tables: snake_case, plural (orders, order_parts).

Columns: snake_case; timestamp columns are timestamptz named *_at.

FKs: <entity>_id.

Enums: lower_snake; values lower_snake.

Storage: bucket order-files; path order-files/{orderId}/{file}.

8) Migrations & Compatibility

If legacy tables exist (e.g., order_records, order_tracking), migrate into:

orders (core header)

order_stage_events (derive events from booleans/dates)

order_documents (move images/docs from arrays to Storage)

For missing columns (e.g., created_at in old tables), add via:

alter table public.customers add column if not exists created_at timestamptz not null default now();


Always enable RLS and apply policies after creating new tables.

9) Sanity Checks (post-deploy)
-- 1) Enums exist
select * from pg_type where typname in ('order_status','order_stage','user_role','document_category');

-- 2) Tables exist
select table_name from information_schema.tables
where table_schema='public'
  and table_name in ('profiles','customers','orders','order_stage_events','order_documents',
                     'parts_inventory','order_parts','resource_allocations','approvals');

-- 3) RLS enabled
select relname, relrowsecurity
from pg_class
where relnamespace = 'public'::regnamespace
  and relname in ('profiles','customers','orders','order_stage_events','order_documents',
                  'parts_inventory','order_parts','resource_allocations','approvals');

-- 4) Views usable
select * from public.view_orders_by_stage;
select * from public.view_stage_duration_days;

10) Roadmap (Phase 2+ Schema)

Invoicing: invoices, invoice_lines, links to orders, payments.

Stock movements: stock_movements with kind enum (in, out, adjust) and references to orders/purchase orders.

Multi-warehouse: warehouses, stock (by warehouse/product).

Audit trail: pgaudit or custom triggers to log updates.

API Keys: service_tokens with hashed secrets + scopes.

11) Appendix — JSON Payload Hints

Assessment event payload

{
  "odometer": 120345,
  "panel_condition": "scratched",
  "photos_count": 6,
  "notes": "Left door needs respray"
}


Dispatch event payload

{
  "delivery_address": "12 Main Rd, Centurion",
  "accountable_person": "Thabo M",
  "qc_passed": true,
  "dispatch_time": "2025-08-17T13:45:00Z"
}