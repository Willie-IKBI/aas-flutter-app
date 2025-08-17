1. Overview

Project Name: All Africa Supplies (AAS)
Goal: Rebuild AAS as a modern, multi-device Flutter application with Supabase backend, enabling streamlined job/order processing, customer management, inventory tracking, and digital workflows.
Platforms: Web, Android, iOS
Primary Users:

Admins / Managers

Sales Representatives

Technicians (Wash Bay, Paint, etc.)

Dispatch & Delivery staff

2. Core Workflows
2.1 Authentication & Roles

Users authenticate via Supabase Auth (email/password, magic link).

Profile stored in profiles table with role enum (admin, manager, sales, technician).

RLS ensures users only access what their role permits.

2.2 Customer Management

CRUD customers (customers table).

Each customer stores:

Company info (name, sector, address, notes).

Contacts (name, phone, email, preferred channel).

Customers linked to orders.

2.3 Order Lifecycle

Every order moves through a stage pipeline:

Order Captured

Sales rep/admin captures initial job request.

Data: customer, description, order date, captured_by, attachments.

Status: in_progress, stage: order_captured.

Wash Bay

Vehicle/job undergoes wash bay prep.

Tech can upload photos, add notes.

Marks stage complete.

Assessment

Technician/supervisor evaluates job requirements.

Upload assessment photos, add comments.

Can flag additional work.

Quotation

Sales rep/manager prepares a quote.

Quote PDF generated (line items, VAT, totals, branding).

Shared via email/WhatsApp link.

Status: waiting_approval.

Approval

Manager or customer approves/rejects quote.

Approval record stored (approvals table or stage payload).

Status: approved → proceed, or rejected.

Job Commencement

Technicians assigned via Resource Allocation.

Logs start date/time, assigned bay, technician.

Job officially started.

Paint / Production

Work in progress.

Upload progress photos, notes.

Can attach parts used (order_parts).

Dispatch / Delivery

Final QC and packaging.

Delivery address + accountable person.

Dispatch note PDF generated if needed.

Status: complete.

2.4 Supporting Modules

Inventory / Parts

parts_inventory table.

Parts can be attached to orders (order_parts).

Stock adjustments tracked manually (future: movement logs).

Resource Allocation

Assign bays/employees to an order.

Start/end dates, role, status.

Documents & Photos

All files stored in Supabase Storage (order-files bucket).

Linked in order_documents with metadata (category, stage, mime, uploaded_by).

Categories: photo, quotation_pdf, approval_doc, dispatch_doc, generic.

3. Technical Requirements
3.1 Frontend

Framework: Flutter (>=3.22, Dart >=3.5).

Architecture: Feature-first, Riverpod for state.

Routing: GoRouter.

UI: Material 3, responsive design (mobile & web).

PDF Generation: pdf + printing.

File Uploads: Supabase Storage.

Notifications: FCM push (future enhancement).

3.2 Backend

Supabase:

Postgres (with enums & JSONB payloads).

Auth + RLS (per role).

Edge Functions (optional for notifications, approvals, email).

Storage for files/photos.

Database structure:

profiles, customers, orders, order_stage_events, order_documents, parts_inventory, order_parts, resource_allocations, approvals.

3.3 Data Flow

Orders always have current_stage (denormalized pointer).

order_stage_events is the audit log: each stage transition = one record (opened/closed, actor, notes, payload).

Documents/photos always linked to order + stage via order_documents.

Reports (dashboards) generated via Postgres views.

4. UI Requirements
4.1 Order List Screen

Shows all orders with:

Customer name

Description

Current stage + status badge

Order date

Filters: by stage, status, search.

Actions: Create Order, View Order.

4.2 Order Detail Screen

Tabs: Overview | Timeline | Documents | Parts | Allocations

Overview: Customer info, description, status, stage, assigned resources.

Timeline: List of order_stage_events with notes, actor, payload.

Documents: Preview/download PDFs/photos.

Parts: List of attached parts, qty.

Allocations: Assigned bays/employees.

4.3 Stage Update Flow

Bottom sheet/modal.

Select stage → add notes → optional payload fields (odometer, QC, delivery address).

Attach photos/documents.

Save = inserts new order_stage_events + uploads files + updates orders.current_stage.

4.4 Customers Module

List/search customers.

Create/edit customer.

Show linked orders.

4.5 Inventory Module

List/search parts.

Add/edit parts.

Attach parts to an order.

4.6 Dashboard

Cards showing:

Orders in each stage.

Average days per stage (via SQL view).

Overdue/blocked orders.

5. Security & RLS (Role Based Access)

Profiles: user can only see/edit their own profile; admins can see all.

Customers: sales/admin can CRUD; techs read only.

Orders: sales/admin can create; techs can update stage events/documents if assigned.

Stage Events: only assigned user/manager can insert; all can read.

Documents: only uploader/manager can delete; all can read if linked to their order.

Parts: inventory managed by admin/manager; techs can only attach to order.

6. Future Enhancements (Phase 2+)

Invoicing & Payments (integrate with Paystack/Payfast).

Multi-warehouse stock movements.

Advanced reporting (monthly trends, sales per customer).

External customer portal (view quotes, approve jobs).

Edge Functions for automatic notifications & SLA enforcement.

Offline-first caching for technicians in the field.

7. Development Guidelines

Branching: main (stable) / dev (active).

Commits: Conventional commits (feat:, fix:, chore:).

Code style: Follow flutter analyze.

Testing: Unit tests for repositories, widget tests for key flows.

CI/CD: GitHub Actions → build + Supabase migrations.

Deployment: Web build → Vercel or Firebase Hosting; mobile via Play Store/App Store.