INSERT INTO user_accounts (username, password_hash, email, phone, role, active, created_at, updated_at)
VALUES
    ('admin', '{noop}admin123', 'admin@example.com', '13800000000', 'ADMIN', TRUE, NOW(), NOW())
ON CONFLICT (username)
DO NOTHING;

INSERT INTO user_accounts (username, password_hash, email, phone, role, active, created_at, updated_at)
VALUES
    ('user01', '{noop}user123', 'user01@example.com', '13900000001', 'CUSTOMER', TRUE, NOW(), NOW()),
    ('wanglei', '{noop}user123', 'wanglei@example.com', '13900000011', 'CUSTOMER', TRUE, NOW(), NOW()),
    ('chenxi', '{noop}user123', 'chenxi@example.com', '13900000012', 'CUSTOMER', TRUE, NOW(), NOW()),
    ('liuying', '{noop}user123', 'liuying@example.com', '13900000013', 'CUSTOMER', TRUE, NOW(), NOW()),
    ('zhaomin', '{noop}user123', 'zhaomin@example.com', '13900000014', 'CUSTOMER', TRUE, NOW(), NOW())
ON CONFLICT (username)
DO NOTHING;

INSERT INTO products (name, sku, category, price, stock, status, created_at, updated_at)
VALUES
    ('星辰蓝牙耳机', 'SC-AIR-01', '数码影音', 299.00, 120, 'ACTIVE', NOW(), NOW()),
    ('极光智能手表', 'SC-WATCH-01', '智能穿戴', 699.00, 80, 'ACTIVE', NOW(), NOW()),
    ('轻羽保温杯', 'SC-CUP-01', '居家生活', 89.00, 300, 'INACTIVE', NOW(), NOW()),
    ('星耀5G手机', 'MALL-PHONE-01', '手机数码', 3999.00, 45, 'ACTIVE', NOW(), NOW()),
    ('云岚拍照手机', 'MALL-PHONE-02', '手机数码', 4599.00, 38, 'ACTIVE', NOW(), NOW()),
    ('速影运动相机', 'MALL-DIGI-01', '手机数码', 1299.00, 52, 'ACTIVE', NOW(), NOW()),
    ('远峰轻薄本', 'MALL-PC-01', '电脑办公', 5299.00, 24, 'ACTIVE', NOW(), NOW()),
    ('霆锋显示器', 'MALL-PC-02', '电脑办公', 1199.00, 36, 'ACTIVE', NOW(), NOW()),
    ('玄雷机械键盘', 'MALL-PC-03', '电脑办公', 349.00, 88, 'ACTIVE', NOW(), NOW()),
    ('云川无线鼠标', 'MALL-PC-04', '电脑办公', 129.00, 120, 'ACTIVE', NOW(), NOW()),
    ('清风空气净化器', 'MALL-HOME-01', '家用电器', 1599.00, 22, 'ACTIVE', NOW(), NOW()),
    ('晨露电饭煲', 'MALL-HOME-02', '家用电器', 399.00, 55, 'ACTIVE', NOW(), NOW()),
    ('极昼手持吸尘器', 'MALL-HOME-03', '家用电器', 699.00, 41, 'ACTIVE', NOW(), NOW()),
    ('山野有机苹果', 'MALL-FOOD-01', '食品生鲜', 39.90, 200, 'ACTIVE', NOW(), NOW()),
    ('牧场鲜牛奶', 'MALL-FOOD-02', '食品生鲜', 24.80, 180, 'ACTIVE', NOW(), NOW()),
    ('深海冷冻虾仁', 'MALL-FOOD-03', '食品生鲜', 69.00, 90, 'ACTIVE', NOW(), NOW()),
    ('逐风跑鞋', 'MALL-SPORT-01', '运动户外', 459.00, 64, 'ACTIVE', NOW(), NOW()),
    ('岩虎机能背包', 'MALL-SPORT-02', '运动户外', 269.00, 70, 'ACTIVE', NOW(), NOW()),
    ('轻峰露营帐篷', 'MALL-SPORT-03', '运动户外', 899.00, 18, 'ACTIVE', NOW(), NOW()),
    ('棉柔四件套', 'MALL-HOUSE-01', '家居日用', 299.00, 58, 'ACTIVE', NOW(), NOW()),
    ('竹韵抽纸12包装', 'MALL-HOUSE-02', '家居日用', 39.90, 240, 'ACTIVE', NOW(), NOW()),
    ('微光香薰机', 'MALL-HOUSE-03', '家居日用', 159.00, 95, 'ACTIVE', NOW(), NOW())
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

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '王磊', '13900000011', '浙江省', '杭州市', '西湖区', '文三路 188 号 云栖花园 6 幢 1202', '310012', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'wanglei'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '文三路 188 号 云栖花园 6 幢 1202'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '王磊', '13900000021', '浙江省', '宁波市', '鄞州区', '天童南路 566 号 都会里 3 幢 701', '315100', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'wanglei'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000021'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '陈曦', '13900000012', '江苏省', '南京市', '建邺区', '江东中路 218 号 金穗府 2 栋 1501', '210019', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'chenxi'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '江东中路 218 号 金穗府 2 栋 1501'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '陈曦', '13900000022', '上海市', '上海市', '浦东新区', '芳甸路 1088 号 星河湾 8 号楼 502', '200135', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'chenxi'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000022'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '刘颖', '13900000013', '四川省', '成都市', '高新区', '天府三街 69 号 锦宸国际 1 栋 902', '610041', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'liuying'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '天府三街 69 号 锦宸国际 1 栋 902'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '刘颖', '13900000023', '重庆市', '重庆市', '渝北区', '金开大道 88 号 中央公园城 12 栋 1604', '401120', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'liuying'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000023'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '赵敏', '13900000014', '北京市', '北京市', '朝阳区', '望京街 10 号 未来中心 5 单元 1103', '100102', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'zhaomin'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '望京街 10 号 未来中心 5 单元 1103'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '赵敏', '13900000024', '天津市', '天津市', '河西区', '友谊路 21 号 海河府邸 9 号楼 803', '300202', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'zhaomin'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000024'
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

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202512-0003', ua.id, 4078.80, 'SHIPPED',
       addr.id,
       addr.recipient_name,
       addr.phone,
       addr.province,
       addr.city,
       addr.district,
       addr.street,
       addr.postal_code,
       NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'wanglei'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202512-0003'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202512-0004', ua.id, 388.70, 'PAID',
       addr.id,
       addr.recipient_name,
       addr.phone,
       addr.province,
       addr.city,
       addr.district,
       addr.street,
       addr.postal_code,
       NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000021'
WHERE ua.username = 'wanglei'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202512-0004'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202512-0005', ua.id, 5428.00, 'SHIPPED',
       addr.id,
       addr.recipient_name,
       addr.phone,
       addr.province,
       addr.city,
       addr.district,
       addr.street,
       addr.postal_code,
       NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'chenxi'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202512-0005'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202512-0006', ua.id, 448.60, 'PENDING_PAYMENT',
       addr.id,
       addr.recipient_name,
       addr.phone,
       addr.province,
       addr.city,
       addr.district,
       addr.street,
       addr.postal_code,
       NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000022'
WHERE ua.username = 'chenxi'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202512-0006'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202512-0007', ua.id, 597.00, 'SHIPPED',
       addr.id,
       addr.recipient_name,
       addr.phone,
       addr.province,
       addr.city,
       addr.district,
       addr.street,
       addr.postal_code,
       NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'liuying'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202512-0007'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202512-0008', ua.id, 1837.80, 'PAID',
       addr.id,
       addr.recipient_name,
       addr.phone,
       addr.province,
       addr.city,
       addr.district,
       addr.street,
       addr.postal_code,
       NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000023'
WHERE ua.username = 'liuying'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202512-0008'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202512-0009', ua.id, 5298.00, 'SHIPPED',
       addr.id,
       addr.recipient_name,
       addr.phone,
       addr.province,
       addr.city,
       addr.district,
       addr.street,
       addr.postal_code,
       NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'zhaomin'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202512-0009'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202512-0010', ua.id, 1222.80, 'PENDING_PAYMENT',
       addr.id,
       addr.recipient_name,
       addr.phone,
       addr.province,
       addr.city,
       addr.district,
       addr.street,
       addr.postal_code,
       NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000024'
WHERE ua.username = 'zhaomin'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202512-0010'
    );

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

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 3999.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-01'
WHERE o.order_number = 'ORD-202512-0003'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 39.90
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-02'
WHERE o.order_number = 'ORD-202512-0003'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-02'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 269.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-02'
WHERE o.order_number = 'ORD-202512-0004'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-02'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 3, 39.90
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-01'
WHERE o.order_number = 'ORD-202512-0004'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 5299.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-01'
WHERE o.order_number = 'ORD-202512-0005'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 129.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-04'
WHERE o.order_number = 'ORD-202512-0005'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 399.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-02'
WHERE o.order_number = 'ORD-202512-0006'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-02'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 24.80
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-02'
WHERE o.order_number = 'ORD-202512-0006'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-02'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 459.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-01'
WHERE o.order_number = 'ORD-202512-0007'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 69.00
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-03'
WHERE o.order_number = 'ORD-202512-0007'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 1599.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-01'
WHERE o.order_number = 'ORD-202512-0008'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 159.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-03'
WHERE o.order_number = 'ORD-202512-0008'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 39.90
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-01'
WHERE o.order_number = 'ORD-202512-0008'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 4599.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-02'
WHERE o.order_number = 'ORD-202512-0009'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-02'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 699.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-03'
WHERE o.order_number = 'ORD-202512-0009'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 299.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-01'
WHERE o.order_number = 'ORD-202512-0010'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 899.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-03'
WHERE o.order_number = 'ORD-202512-0010'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 24.80
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-02'
WHERE o.order_number = 'ORD-202512-0010'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-02'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202511-0001', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202511-0001'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202511-0001'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202511-0002', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202511-0002'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202511-0002'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202512-0003', 'WECHAT', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202512-0003'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202512-0003'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202512-0004', 'BANK_CARD', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202512-0004'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202512-0004'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202512-0005', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202512-0005'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202512-0005'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202512-0007', 'WECHAT', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202512-0007'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202512-0007'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202512-0008', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202512-0008'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202512-0008'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202512-0009', 'BANK_CARD', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202512-0009'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202512-0009'
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '极光手表续航稳定，日常佩戴很方便', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'user01'
    AND o.order_number = 'ORD-202511-0002'
    AND oi.product_sku = 'SC-WATCH-01'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 4, '保温效果不错，杯身轻巧', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'user01'
    AND o.order_number = 'ORD-202511-0002'
    AND oi.product_sku = 'SC-CUP-01'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '手机运行流畅，拍照和续航都很稳。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'wanglei'
    AND o.order_number = 'ORD-202512-0003'
    AND oi.product_sku = 'MALL-PHONE-01'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '轻薄本开机快，办公和出差都很省心。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'chenxi'
    AND o.order_number = 'ORD-202512-0005'
    AND oi.product_sku = 'MALL-PC-01'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 4, '鼠标连接稳定，日常使用手感不错。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'chenxi'
    AND o.order_number = 'ORD-202512-0005'
    AND oi.product_sku = 'MALL-PC-04'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '跑鞋脚感轻弹，通勤和慢跑都合适。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'liuying'
    AND o.order_number = 'ORD-202512-0007'
    AND oi.product_sku = 'MALL-SPORT-01'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '拍照表现很强，屏幕也足够细腻。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'zhaomin'
    AND o.order_number = 'ORD-202512-0009'
    AND oi.product_sku = 'MALL-PHONE-02'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

CREATE OR REPLACE FUNCTION public.validate_review_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS '
DECLARE
    expected_user_id BIGINT;
    expected_product_id BIGINT;
BEGIN
    SELECT o.user_id, oi.product_id
    INTO expected_user_id, expected_product_id
    FROM public.order_items oi
    JOIN public.orders o ON o.id = oi.order_id
    WHERE oi.id = NEW.order_item_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION ''review order_item_id % does not reference an existing order item'', NEW.order_item_id;
    END IF;

    IF NEW.user_id IS DISTINCT FROM expected_user_id THEN
        RAISE EXCEPTION ''review user_id % must match order item purchaser %'', NEW.user_id, expected_user_id;
    END IF;

    IF NEW.product_id IS DISTINCT FROM expected_product_id THEN
        RAISE EXCEPTION ''review product_id % must match order item product %'', NEW.product_id, expected_product_id;
    END IF;

    RETURN NEW;
END;
';

DROP TRIGGER IF EXISTS trg_reviews_validate_consistency ON public.reviews;

CREATE TRIGGER trg_reviews_validate_consistency
    BEFORE INSERT OR UPDATE ON public.reviews
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_review_consistency();

CREATE OR REPLACE FUNCTION public.prevent_review_breakage_from_order_update()
RETURNS trigger
LANGUAGE plpgsql
AS '
BEGIN
    IF EXISTS (
        SELECT 1
        FROM public.order_items oi
        JOIN public.reviews r ON r.order_item_id = oi.id
        WHERE oi.order_id = OLD.id
            AND r.user_id IS DISTINCT FROM NEW.user_id
    ) THEN
        RAISE EXCEPTION ''cannot update orders.user_id for order % because dependent reviews exist'', OLD.id;
    END IF;

    RETURN NEW;
END;
';

DROP TRIGGER IF EXISTS trg_orders_protect_review_consistency ON public.orders;

CREATE TRIGGER trg_orders_protect_review_consistency
    BEFORE UPDATE OF user_id ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_review_breakage_from_order_update();

CREATE OR REPLACE FUNCTION public.prevent_review_breakage_from_order_item_update()
RETURNS trigger
LANGUAGE plpgsql
AS '
BEGIN
    IF NEW.product_id IS DISTINCT FROM OLD.product_id AND EXISTS (
        SELECT 1
        FROM public.reviews r
        WHERE r.order_item_id = OLD.id
            AND r.product_id IS DISTINCT FROM NEW.product_id
    ) THEN
        RAISE EXCEPTION ''cannot update order_items.product_id for order item % because dependent reviews exist'', OLD.id;
    END IF;

    IF NEW.order_id IS DISTINCT FROM OLD.order_id AND EXISTS (
        SELECT 1
        FROM public.reviews r
        JOIN public.orders o ON o.id = NEW.order_id
        WHERE r.order_item_id = OLD.id
            AND r.user_id IS DISTINCT FROM o.user_id
    ) THEN
        RAISE EXCEPTION ''cannot update order_items.order_id for order item % because dependent reviews exist'', OLD.id;
    END IF;

    RETURN NEW;
END;
';

DROP TRIGGER IF EXISTS trg_order_items_protect_review_consistency ON public.order_items;

CREATE TRIGGER trg_order_items_protect_review_consistency
    BEFORE UPDATE OF product_id, order_id ON public.order_items
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_review_breakage_from_order_item_update();

CREATE OR REPLACE VIEW public.order_detail_view AS
SELECT
    o.id AS order_id,
    o.order_number,
    ua.id AS user_id,
    ua.username,
    o.status AS order_status,
    o.created_at AS order_created_at,
    oi.id AS order_item_id,
    oi.product_id,
    oi.product_name,
    oi.product_sku,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS item_amount,
    latest_payment.payment_status,
    latest_payment.payment_method,
    latest_payment.paid_at
FROM orders o
JOIN user_accounts ua ON ua.id = o.user_id
JOIN order_items oi ON oi.order_id = o.id
LEFT JOIN (
    SELECT order_id, payment_status, payment_method, paid_at
    FROM (
        SELECT
            pr.order_id,
            pr.payment_status,
            pr.payment_method,
            pr.paid_at,
            ROW_NUMBER() OVER (
                PARTITION BY pr.order_id
                ORDER BY pr.paid_at DESC NULLS LAST, pr.id DESC
            ) AS payment_rank
        FROM payment_records pr
    ) ranked_payments
    WHERE payment_rank = 1
) latest_payment ON latest_payment.order_id = o.id;
