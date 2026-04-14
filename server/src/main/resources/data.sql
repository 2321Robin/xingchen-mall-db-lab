INSERT INTO user_accounts (username, password_hash, email, phone, role, active, created_at, updated_at)
VALUES
    ('admin', '{noop}admin123', 'admin@example.com', '13800000000', 'ADMIN', TRUE, NOW(), NOW())
ON CONFLICT (username)
DO NOTHING;

INSERT INTO user_accounts (username, password_hash, email, phone, role, active, created_at, updated_at)
VALUES
    ('user01', '{noop}user123', 'user01@example.com', '13900000001', 'CUSTOMER', TRUE, NOW(), NOW())
ON CONFLICT (username)
DO NOTHING;

INSERT INTO products (name, sku, category, price, stock, status, created_at, updated_at)
VALUES
    ('星辰蓝牙耳机', 'SC-AIR-01', '数码影音', 299.00, 120, 'ACTIVE', NOW(), NOW()),
    ('极光智能手表', 'SC-WATCH-01', '智能穿戴', 699.00, 80, 'ACTIVE', NOW(), NOW()),
    ('轻羽保温杯', 'SC-CUP-01', '居家生活', 89.00, 300, 'INACTIVE', NOW(), NOW())
ON CONFLICT (sku)
DO NOTHING;

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '张三', '13900000001', '广东省', '广州市', '天河区', '科韵路 99 号 星辰公寓 1 栋 502', '510000', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'user01'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '科韵路 99 号 星辰公寓 1 栋 502'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '张三', '13900000002', '广东省', '深圳市', '南山区', '科技园 创新大道 88 号 A 座 1203', '518000', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'user01'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000002'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202511-0001', ua.id, 299.00, 'PAID',
       addr.id,
       COALESCE(addr.recipient_name, '张三'),
        COALESCE(addr.phone, '13900000001'),
       COALESCE(addr.province, '广东省'),
       COALESCE(addr.city, '广州市'),
       COALESCE(addr.district, '天河区'),
       COALESCE(addr.street, '科韵路 99 号 星辰公寓 1 栋 502'),
       COALESCE(addr.postal_code, '510000'),
       NOW(), NOW()
FROM user_accounts ua
LEFT JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'user01'
ON CONFLICT (order_number)
DO NOTHING;

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202511-0002', ua.id, 988.00, 'SHIPPED',
       addr.id,
       COALESCE(addr.recipient_name, '张三'),
       COALESCE(addr.phone, '13900000002'),
       COALESCE(addr.province, '广东省'),
       COALESCE(addr.city, '深圳市'),
       COALESCE(addr.district, '南山区'),
       COALESCE(addr.street, '科技园 创新大道 88 号 A 座 1203'),
       COALESCE(addr.postal_code, '518000'),
       NOW(), NOW()
FROM user_accounts ua
LEFT JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000002'
WHERE ua.username = 'user01'
ON CONFLICT (order_number)
DO NOTHING;

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 299.00
FROM orders o
JOIN products p ON p.sku = 'SC-AIR-01'
WHERE o.order_number = 'ORD-202511-0001'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'SC-AIR-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 699.00
FROM orders o
JOIN products p ON p.sku = 'SC-WATCH-01'
WHERE o.order_number = 'ORD-202511-0002'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'SC-WATCH-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 289.00
FROM orders o
JOIN products p ON p.sku = 'SC-CUP-01'
WHERE o.order_number = 'ORD-202511-0002'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'SC-CUP-01'
    );
