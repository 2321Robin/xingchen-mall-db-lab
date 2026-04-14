insert into user_accounts (id, active, created_at, email, password_hash, phone, role, updated_at, username)
values (1, true, current_timestamp, 'legacy@example.com', '{noop}legacy', '13900000000', 'CUSTOMER', current_timestamp, 'legacy-user');

insert into orders (id, created_at, order_number, status, total_amount, updated_at, user_id)
values (1, current_timestamp, 'ORD-LEGACY-0001', 'PAID', 299.00, current_timestamp, 1);

insert into order_items (id, product_name, product_sku, quantity, unit_price, order_id)
values (10, 'Legacy Product', 'LEG-001', 1, 299.00, 1);

alter table user_accounts alter column id restart with 100;
alter table user_addresses alter column id restart with 100;
alter table products alter column id restart with 100;
alter table cart_items alter column id restart with 100;
alter table orders alter column id restart with 100;
alter table order_items alter column id restart with 100;
