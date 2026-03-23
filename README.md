# mobilestock

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

cd d:\flutterProject\2026\nextstepmobilestock

flutter build web --release --base-href /mobilestock/

cp -r build/web/\* C:/xampp/htdocs/mobilestock/

CREATE TABLE public.msc_cart
(
roworder serial,
doc_no character varying(255) NOT NULL,
doc_date date DEFAULT timezone('Asia/Bangkok'::text, now()),
doc_time time without time zone DEFAULT timezone('Asia/Bangkok'::text, now()),
wh_code character varying(255),
location_code character varying(255),
wh_to character varying(255),
location_to character varying(255),
creator_code character varying(255),
doc_ref character varying(255),
cust_code character varying(255),
remark text,
create_datetime timestamp without time zone DEFAULT timezone('Asia/Bangkok'::text, now()),
trans_flag smallint DEFAULT 0,
status smallint DEFAULT 0,
is_merge smallint DEFAULT 0,
is_approve smallint DEFAULT 0,
approve_code character varying(255),
approve_date_time timestamp without time zone DEFAULT timezone('Asia/Bangkok'::text, now()),
branch_code character varying(255),
carts text,
doc_no_add character varying(255),
doc_no_minus character varying(255),
user_code character varying(255),
user_approve character varying(255),
approve_datetime timestamp without time zone DEFAULT now(),
CONSTRAINT msc_cart_pk PRIMARY KEY (doc_no)
);

CREATE TABLE public.msc_cart_detail
(
roworder serial,
doc_no character varying(255),
barcode character varying(255),
item_code character varying(255),
unit_code character varying(255),
wh_code character varying(255),
location_code character varying(255),
qty numeric DEFAULT 0,
balance_qty numeric DEFAULT 0,
diff_qty numeric DEFAULT 0,
is_approve smallint DEFAULT 0,
create_datetime timestamp without time zone DEFAULT timezone('Asia/Bangkok'::text, now()),
remark text,
location text,
is_no_stock smallint NOT NULL DEFAULT 0,
line_number integer NOT NULL DEFAULT 0,
CONSTRAINT msc_cart_detail_pk PRIMARY KEY (roworder)
);

CREATE TABLE public.msc_cart_sub
(
roworder serial,
doc_no character varying(255) NOT NULL,
doc_date date DEFAULT timezone('Asia/Bangkok'::text, now()),
doc_time time without time zone DEFAULT timezone('Asia/Bangkok'::text, now()),
wh_code character varying(255),
location_code character varying(255),
creator_code character varying(255),
remark character varying(255),
create_datetime timestamp without time zone DEFAULT timezone('Asia/Bangkok'::text, now()),
status smallint DEFAULT 0,
is_merge smallint DEFAULT 0,
is_approve smallint DEFAULT 0,
approve_code character varying(255),
approve_date_time timestamp without time zone DEFAULT timezone('Asia/Bangkok'::text, now()),
branch_code character varying(255),
carts character varying(255),
doc_ref character varying(255),
user_code character varying(255),
CONSTRAINT msc_cart_sub_pk PRIMARY KEY (doc_no)
);

CREATE TABLE public.msc_cart_sub_detail
(
roworder serial,
doc_no character varying(255),
barcode character varying(255),
item_code character varying(255),
unit_code character varying(255),
wh_code character varying(255),
location_code character varying(255),
qty numeric DEFAULT 0,
balance_qty numeric DEFAULT 0,
diff_qty numeric DEFAULT 0,
is_approve smallint DEFAULT 0,
create_datetime timestamp without time zone DEFAULT timezone('Asia/Bangkok'::text, now()),
location character varying(255),
is_no_stock smallint NOT NULL DEFAULT 0,
line_number integer NOT NULL DEFAULT 0,
CONSTRAINT msc_cart_sub_detail_pk PRIMARY KEY (roworder)
);

CREATE TABLE public.msc_permission
(
roworder serial,
user_code character varying(255) NOT NULL,
stock_list smallint NOT NULL DEFAULT 0,
request_list smallint NOT NULL DEFAULT 0,
transfer_list smallint NOT NULL DEFAULT 0,
handheld_list smallint NOT NULL DEFAULT 0,
info_list smallint NOT NULL DEFAULT 0,
barcode_list smallint NOT NULL DEFAULT 0,
create_datetime timestamp without time zone DEFAULT timezone('asia/bangkok'::text, now()),
CONSTRAINT msc_permission_pkey PRIMARY KEY (user_code)
)
