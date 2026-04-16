INSERT INTO user_accounts (username, password_hash, email, phone, role, active, created_at, updated_at)
VALUES
    ('admin', '{noop}admin123', 'admin@example.com', '13800000000', 'ADMIN', TRUE, NOW(), NOW())
ON CONFLICT (username)
DO NOTHING;

INSERT INTO user_accounts (username, password_hash, email, phone, role, active, created_at, updated_at)
VALUES
    ('sunjia', '{noop}user123', 'sunjia@example.com', '13900000015', 'CUSTOMER', TRUE, NOW(), NOW()),
    ('heqing', '{noop}user123', 'heqing@example.com', '13900000016', 'CUSTOMER', TRUE, NOW(), NOW()),
    ('tangrui', '{noop}user123', 'tangrui@example.com', '13900000017', 'CUSTOMER', TRUE, NOW(), NOW()),
    ('qiaonan', '{noop}user123', 'qiaonan@example.com', '13900000018', 'CUSTOMER', TRUE, NOW(), NOW()),
    ('pengfei', '{noop}user123', 'pengfei@example.com', '13900000019', 'CUSTOMER', TRUE, NOW(), NOW()),
    ('linan', '{noop}user123', 'linan@example.com', '13900000020', 'CUSTOMER', TRUE, NOW(), NOW())
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
    ('轻羽保温杯', 'SC-CUP-01', '居家生活', 289.00, 300, 'INACTIVE', NOW(), NOW()),
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

INSERT INTO products (name, sku, category, price, stock, status, created_at, updated_at)
VALUES
    ('星河平板电脑', 'MALL-PHONE-03', '手机数码', 2499.00, 34, 'ACTIVE', NOW(), NOW()),
    ('霜语降噪耳机', 'MALL-PHONE-04', '手机数码', 899.00, 56, 'ACTIVE', NOW(), NOW()),
    ('磁吸无线充电器', 'MALL-PHONE-05', '手机数码', 149.00, 140, 'ACTIVE', NOW(), NOW()),
    ('远行翻译机', 'MALL-PHONE-06', '手机数码', 599.00, 48, 'ACTIVE', NOW(), NOW()),
    ('雷驰电竞路由器', 'MALL-PC-05', '电脑办公', 329.00, 72, 'ACTIVE', NOW(), NOW()),
    ('青岚升降桌', 'MALL-PC-06', '电脑办公', 1699.00, 20, 'ACTIVE', NOW(), NOW()),
    ('舒脊人体工学椅', 'MALL-PC-07', '电脑办公', 1899.00, 16, 'ACTIVE', NOW(), NOW()),
    ('流光移动固态硬盘', 'MALL-PC-08', '电脑办公', 499.00, 84, 'ACTIVE', NOW(), NOW()),
    ('晨雾蒸汽挂烫机', 'MALL-HOME-04', '家用电器', 299.00, 66, 'ACTIVE', NOW(), NOW()),
    ('果语迷你破壁机', 'MALL-HOME-05', '家用电器', 259.00, 74, 'ACTIVE', NOW(), NOW()),
    ('风信变频循环扇', 'MALL-HOME-06', '家用电器', 459.00, 51, 'ACTIVE', NOW(), NOW()),
    ('守望智能门锁', 'MALL-HOME-07', '家用电器', 1299.00, 27, 'ACTIVE', NOW(), NOW()),
    ('北岛冷萃咖啡液', 'MALL-FOOD-04', '食品生鲜', 59.90, 160, 'ACTIVE', NOW(), NOW()),
    ('山火手工牛肉干', 'MALL-FOOD-05', '食品生鲜', 49.90, 110, 'ACTIVE', NOW(), NOW()),
    ('海盐综合坚果', 'MALL-FOOD-06', '食品生鲜', 36.80, 190, 'ACTIVE', NOW(), NOW()),
    ('晴川沃柑礼盒', 'MALL-FOOD-07', '食品生鲜', 58.00, 120, 'ACTIVE', NOW(), NOW()),
    ('云阶瑜伽垫', 'MALL-SPORT-04', '运动户外', 119.00, 96, 'ACTIVE', NOW(), NOW()),
    ('原野折叠椅', 'MALL-SPORT-05', '运动户外', 179.00, 68, 'ACTIVE', NOW(), NOW()),
    ('轻速运动T恤', 'MALL-SPORT-06', '运动户外', 99.00, 150, 'ACTIVE', NOW(), NOW()),
    ('追风骑行头盔', 'MALL-SPORT-07', '运动户外', 239.00, 61, 'ACTIVE', NOW(), NOW()),
    ('晨砂珐琅早餐盘', 'MALL-HOUSE-04', '家居日用', 89.00, 130, 'ACTIVE', NOW(), NOW()),
    ('云朵午睡靠枕', 'MALL-HOUSE-05', '家居日用', 69.00, 118, 'ACTIVE', NOW(), NOW()),
    ('橡木厨房收纳推车', 'MALL-HOUSE-06', '家居日用', 219.00, 57, 'ACTIVE', NOW(), NOW()),
    ('防滑浴室地垫', 'MALL-HOUSE-07', '家居日用', 49.00, 142, 'ACTIVE', NOW(), NOW())
ON CONFLICT (sku)
DO NOTHING;

UPDATE products
SET price = 289.00,
    updated_at = NOW()
WHERE sku = 'SC-CUP-01'
  AND price <> 289.00;

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

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '孙佳', '13900000015', '江苏省', '苏州市', '工业园区', '星湖街 188 号 金水湾 7 幢 1201', '215028', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'sunjia'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '星湖街 188 号 金水湾 7 幢 1201'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '孙佳', '13900000025', '山东省', '济南市', '历下区', '经十路 9777 号 华都广场 2 单元 901', '250014', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'sunjia'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000025'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '何晴', '13900000016', '湖北省', '武汉市', '洪山区', '珞喻路 266 号 光谷国际 5 栋 1703', '430074', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'heqing'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '珞喻路 266 号 光谷国际 5 栋 1703'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '何晴', '13900000026', '湖南省', '长沙市', '岳麓区', '梅溪湖路 98 号 观山府 11 栋 602', '410013', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'heqing'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000026'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '唐睿', '13900000017', '陕西省', '西安市', '雁塔区', '科技二路 66 号 锦业时代 3 幢 1508', '710065', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'tangrui'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '科技二路 66 号 锦业时代 3 幢 1508'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '唐睿', '13900000027', '河南省', '郑州市', '郑东新区', '商务内环路 18 号 绿地中心 6 栋 908', '450046', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'tangrui'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000027'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '乔楠', '13900000018', '福建省', '厦门市', '思明区', '软件园二期 88 号 海景城 1 栋 1205', '361008', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'qiaonan'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '软件园二期 88 号 海景城 1 栋 1205'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '乔楠', '13900000028', '福建省', '福州市', '鼓楼区', '五四路 216 号 环球广场 9 层 02 室', '350001', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'qiaonan'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000028'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '彭飞', '13900000019', '山东省', '青岛市', '市南区', '香港中路 33 号 海天中心 2 栋 1006', '266071', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'pengfei'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '香港中路 33 号 海天中心 2 栋 1006'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '彭飞', '13900000029', '辽宁省', '大连市', '中山区', '人民路 88 号 港湾广场 5 单元 1101', '116001', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'pengfei'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000029'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '林安', '13900000020', '云南省', '昆明市', '盘龙区', '北京路 605 号 云岭国际 4 栋 803', '650051', TRUE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'linan'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.street = '北京路 605 号 云岭国际 4 栋 803'
    );

INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)
SELECT ua.id, '林安', '13900000030', '贵州省', '贵阳市', '观山湖区', '金朱东路 129 号 金元国际 8 栋 1502', '550081', FALSE, NOW(), NOW()
FROM user_accounts ua
WHERE ua.username = 'linan'
    AND NOT EXISTS (
            SELECT 1 FROM user_addresses a WHERE a.user_id = ua.id AND a.phone = '13900000030'
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

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0011', ua.id, 2737.80, 'DELIVERED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'sunjia'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0011'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0012', ua.id, 852.00, 'PAID',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000025'
WHERE ua.username = 'sunjia'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0012'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0013', ua.id, 1136.00, 'PENDING_PAYMENT',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'sunjia'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0013'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0014', ua.id, 775.00, 'SHIPPED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000025'
WHERE ua.username = 'sunjia'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0014'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0015', ua.id, 2177.00, 'DELIVERED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'heqing'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0015'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0016', ua.id, 1458.60, 'SHIPPED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000026'
WHERE ua.username = 'heqing'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0016'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0017', ua.id, 728.60, 'PENDING_PAYMENT',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'heqing'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0017'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0018', ua.id, 1697.80, 'PAID',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000026'
WHERE ua.username = 'heqing'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0018'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0019', ua.id, 2467.00, 'SHIPPED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'tangrui'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0019'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0020', ua.id, 657.20, 'DELIVERED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000027'
WHERE ua.username = 'tangrui'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0020'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0021', ua.id, 814.00, 'PAID',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'tangrui'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0021'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0022', ua.id, 756.90, 'PENDING_PAYMENT',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000027'
WHERE ua.username = 'tangrui'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0022'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0023', ua.id, 4907.00, 'DELIVERED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'qiaonan'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0023'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0024', ua.id, 2137.80, 'SHIPPED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000028'
WHERE ua.username = 'qiaonan'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0024'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0025', ua.id, 1216.00, 'PENDING_PAYMENT',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'qiaonan'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0025'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0026', ua.id, 1047.00, 'PAID',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000028'
WHERE ua.username = 'qiaonan'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0026'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0027', ua.id, 4987.00, 'SHIPPED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'pengfei'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0027'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0028', ua.id, 1696.00, 'DELIVERED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000029'
WHERE ua.username = 'pengfei'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0028'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0029', ua.id, 422.80, 'PAID',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'pengfei'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0029'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0030', ua.id, 3947.00, 'PENDING_PAYMENT',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000029'
WHERE ua.username = 'pengfei'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0030'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0031', ua.id, 685.00, 'DELIVERED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'linan'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0031'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0032', ua.id, 1096.00, 'SHIPPED',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000030'
WHERE ua.username = 'linan'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0032'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0033', ua.id, 3327.00, 'PAID',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.is_default = TRUE
WHERE ua.username = 'linan'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0033'
    );

INSERT INTO orders (order_number, user_id, total_amount, status,
                    shipping_address_id, shipping_recipient, shipping_phone,
                    shipping_province, shipping_city, shipping_district,
                    shipping_street, shipping_postal_code, created_at, updated_at)
SELECT 'ORD-202601-0034', ua.id, 527.70, 'PENDING_PAYMENT',
       addr.id, addr.recipient_name, addr.phone, addr.province, addr.city,
       addr.district, addr.street, addr.postal_code, NOW(), NOW()
FROM user_accounts ua
JOIN user_addresses addr ON addr.user_id = ua.id AND addr.phone = '13900000030'
WHERE ua.username = 'linan'
    AND NOT EXISTS (
            SELECT 1 FROM orders o WHERE o.order_number = 'ORD-202601-0034'
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

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 2499.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-03'
WHERE o.order_number = 'ORD-202601-0011'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 59.90
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-04'
WHERE o.order_number = 'ORD-202601-0011'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 119.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-04'
WHERE o.order_number = 'ORD-202601-0011'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 459.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-06'
WHERE o.order_number = 'ORD-202601-0012'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-06'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 219.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-06'
WHERE o.order_number = 'ORD-202601-0012'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-06'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 3, 58.00
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-07'
WHERE o.order_number = 'ORD-202601-0012'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 499.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-08'
WHERE o.order_number = 'ORD-202601-0013'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-08'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 69.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-05'
WHERE o.order_number = 'ORD-202601-0013'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 149.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-05'
WHERE o.order_number = 'ORD-202601-0014'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 299.00
FROM orders o
JOIN products p ON p.sku = 'SC-AIR-01'
WHERE o.order_number = 'ORD-202601-0014'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'SC-AIR-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 89.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-04'
WHERE o.order_number = 'ORD-202601-0014'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 1699.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-06'
WHERE o.order_number = 'ORD-202601-0015'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-06'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 349.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-03'
WHERE o.order_number = 'ORD-202601-0015'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 129.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-04'
WHERE o.order_number = 'ORD-202601-0015'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 1299.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-07'
WHERE o.order_number = 'ORD-202601-0016'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 4, 39.90
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-02'
WHERE o.order_number = 'ORD-202601-0016'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-02'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 179.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-05'
WHERE o.order_number = 'ORD-202601-0017'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 3, 99.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-06'
WHERE o.order_number = 'ORD-202601-0017'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-06'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 36.80
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-06'
WHERE o.order_number = 'ORD-202601-0017'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-06'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 899.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-04'
WHERE o.order_number = 'ORD-202601-0018'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 699.00
FROM orders o
JOIN products p ON p.sku = 'SC-WATCH-01'
WHERE o.order_number = 'ORD-202601-0018'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'SC-WATCH-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 49.90
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-05'
WHERE o.order_number = 'ORD-202601-0018'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 1899.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-07'
WHERE o.order_number = 'ORD-202601-0019'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 499.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-08'
WHERE o.order_number = 'ORD-202601-0019'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-08'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 69.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-05'
WHERE o.order_number = 'ORD-202601-0019'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 259.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-05'
WHERE o.order_number = 'ORD-202601-0020'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 299.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-04'
WHERE o.order_number = 'ORD-202601-0020'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 4, 24.80
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-02'
WHERE o.order_number = 'ORD-202601-0020'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-02'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 239.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-07'
WHERE o.order_number = 'ORD-202601-0021'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 459.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-01'
WHERE o.order_number = 'ORD-202601-0021'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 58.00
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-07'
WHERE o.order_number = 'ORD-202601-0021'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 599.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-06'
WHERE o.order_number = 'ORD-202601-0022'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-06'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 49.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-07'
WHERE o.order_number = 'ORD-202601-0022'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 59.90
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-04'
WHERE o.order_number = 'ORD-202601-0022'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 4599.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-02'
WHERE o.order_number = 'ORD-202601-0023'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-02'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 149.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-05'
WHERE o.order_number = 'ORD-202601-0023'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 159.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-03'
WHERE o.order_number = 'ORD-202601-0023'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 1599.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-01'
WHERE o.order_number = 'ORD-202601-0024'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 459.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-06'
WHERE o.order_number = 'ORD-202601-0024'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-06'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 39.90
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-02'
WHERE o.order_number = 'ORD-202601-0024'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-02'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 899.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-03'
WHERE o.order_number = 'ORD-202601-0025'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 179.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-05'
WHERE o.order_number = 'ORD-202601-0025'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 69.00
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-03'
WHERE o.order_number = 'ORD-202601-0025'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 329.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-05'
WHERE o.order_number = 'ORD-202601-0026'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 499.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-08'
WHERE o.order_number = 'ORD-202601-0026'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-08'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 219.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-06'
WHERE o.order_number = 'ORD-202601-0026'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-06'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 3999.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-01'
WHERE o.order_number = 'ORD-202601-0027'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 899.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-04'
WHERE o.order_number = 'ORD-202601-0027'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 89.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-04'
WHERE o.order_number = 'ORD-202601-0027'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 1299.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-07'
WHERE o.order_number = 'ORD-202601-0028'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 299.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-01'
WHERE o.order_number = 'ORD-202601-0028'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 49.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-07'
WHERE o.order_number = 'ORD-202601-0028'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 5, 39.90
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-01'
WHERE o.order_number = 'ORD-202601-0029'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-01'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 3, 49.90
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-05'
WHERE o.order_number = 'ORD-202601-0029'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 36.80
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-06'
WHERE o.order_number = 'ORD-202601-0029'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-06'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 1699.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-06'
WHERE o.order_number = 'ORD-202601-0030'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-06'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 1899.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-07'
WHERE o.order_number = 'ORD-202601-0030'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 349.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-03'
WHERE o.order_number = 'ORD-202601-0030'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 269.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-02'
WHERE o.order_number = 'ORD-202601-0031'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-02'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 119.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-04'
WHERE o.order_number = 'ORD-202601-0031'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 239.00
FROM orders o
JOIN products p ON p.sku = 'MALL-SPORT-07'
WHERE o.order_number = 'ORD-202601-0031'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-SPORT-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 58.00
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-07'
WHERE o.order_number = 'ORD-202601-0031'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-07'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 699.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-03'
WHERE o.order_number = 'ORD-202601-0032'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 259.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-05'
WHERE o.order_number = 'ORD-202601-0032'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 2, 69.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-05'
WHERE o.order_number = 'ORD-202601-0032'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 2499.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PHONE-03'
WHERE o.order_number = 'ORD-202601-0033'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PHONE-03'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 329.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-05'
WHERE o.order_number = 'ORD-202601-0033'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-05'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 499.00
FROM orders o
JOIN products p ON p.sku = 'MALL-PC-08'
WHERE o.order_number = 'ORD-202601-0033'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-PC-08'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 299.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOME-04'
WHERE o.order_number = 'ORD-202601-0034'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOME-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 3, 59.90
FROM orders o
JOIN products p ON p.sku = 'MALL-FOOD-04'
WHERE o.order_number = 'ORD-202601-0034'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-FOOD-04'
    );

INSERT INTO order_items (order_id, product_name, product_sku, product_id, quantity, unit_price)
SELECT o.id, p.name, p.sku, p.id, 1, 49.00
FROM orders o
JOIN products p ON p.sku = 'MALL-HOUSE-07'
WHERE o.order_number = 'ORD-202601-0034'
    AND NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.id AND oi.product_sku = 'MALL-HOUSE-07'
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

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0011', 'WECHAT', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0011'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0011'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0012', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0012'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0012'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0014', 'BANK_CARD', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0014'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0014'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0015', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0015'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0015'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0016', 'WECHAT', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0016'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0016'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0018', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0018'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0018'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0019', 'BANK_CARD', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0019'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0019'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0020', 'WECHAT', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0020'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0020'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0021', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0021'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0021'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0023', 'BANK_CARD', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0023'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0023'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0024', 'WECHAT', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0024'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0024'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0026', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0026'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0026'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0027', 'BANK_CARD', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0027'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0027'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0028', 'WECHAT', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0028'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0028'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0029', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0029'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0029'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0031', 'WECHAT', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0031'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0031'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0032', 'BANK_CARD', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0032'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0032'
    );

INSERT INTO payment_records (order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)
SELECT o.id, 'PAY-ORD-202601-0033', 'ALIPAY', o.total_amount, 'SUCCESS', NOW(), NOW(), NOW()
FROM orders o
WHERE o.order_number = 'ORD-202601-0033'
    AND NOT EXISTS (
        SELECT 1 FROM payment_records pr WHERE pr.payment_no = 'PAY-ORD-202601-0033'
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

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '平板屏幕清透，追剧和记笔记都很顺手。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'sunjia'
    AND o.order_number = 'ORD-202601-0011'
    AND oi.product_sku = 'MALL-PHONE-03'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 4, '循环扇风感柔和，卧室夜间使用也不吵。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'sunjia'
    AND o.order_number = 'ORD-202601-0012'
    AND oi.product_sku = 'MALL-HOME-06'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '耳机连接稳定，通勤路上降噪效果很明显。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'sunjia'
    AND o.order_number = 'ORD-202601-0014'
    AND oi.product_sku = 'SC-AIR-01'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '升降桌结构扎实，切换站立办公很顺畅。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'heqing'
    AND o.order_number = 'ORD-202601-0015'
    AND oi.product_sku = 'MALL-PC-06'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 4, '门锁录入指纹很快，家里老人也能轻松使用。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'heqing'
    AND o.order_number = 'ORD-202601-0016'
    AND oi.product_sku = 'MALL-HOME-07'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '头戴耳机佩戴舒适，办公室里听歌很沉浸。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'heqing'
    AND o.order_number = 'ORD-202601-0018'
    AND oi.product_sku = 'MALL-PHONE-04'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '人体工学椅支撑到位，久坐办公明显轻松很多。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'tangrui'
    AND o.order_number = 'ORD-202601-0019'
    AND oi.product_sku = 'MALL-PC-07'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 4, '破壁机做早餐奶昔很方便，清洗也不费事。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'tangrui'
    AND o.order_number = 'ORD-202601-0020'
    AND oi.product_sku = 'MALL-HOME-05'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '头盔包裹感不错，周末骑行更安心。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'tangrui'
    AND o.order_number = 'ORD-202601-0021'
    AND oi.product_sku = 'MALL-SPORT-07'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '手机成像稳定，旅行拍海景色彩很讨喜。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'qiaonan'
    AND o.order_number = 'ORD-202601-0023'
    AND oi.product_sku = 'MALL-PHONE-02'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 4, '空气净化器开机后见效快，卧室异味少了很多。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'qiaonan'
    AND o.order_number = 'ORD-202601-0024'
    AND oi.product_sku = 'MALL-HOME-01'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '主力手机运行流畅，游戏和拍照表现都很均衡。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'pengfei'
    AND o.order_number = 'ORD-202601-0027'
    AND oi.product_sku = 'MALL-PHONE-01'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 5, '这套餐具和家居搭配很顺手，安装简单又实用。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'pengfei'
    AND o.order_number = 'ORD-202601-0028'
    AND oi.product_sku = 'MALL-HOME-07'
    AND NOT EXISTS (
        SELECT 1 FROM reviews r WHERE r.order_item_id = oi.id
    );

INSERT INTO reviews (user_id, product_id, order_item_id, rating, content, created_at, updated_at)
SELECT ua.id, p.id, oi.id, 4, '运动装备搭配很完整，周末徒步和骑行都能用上。', NOW(), NOW()
FROM user_accounts ua
JOIN orders o ON o.user_id = ua.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE ua.username = 'linan'
    AND o.order_number = 'ORD-202601-0031'
    AND oi.product_sku = 'MALL-SPORT-07'
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
