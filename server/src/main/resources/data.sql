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
