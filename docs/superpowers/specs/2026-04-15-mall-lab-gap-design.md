# 商城数据库实验补强设计

## 目标

在尽量复用现有星辰商城项目结构的前提下，补齐数据库系统实验的关键验收项，使系统既满足课程要求，也保持业务场景自然、便于演示和写入实验报告。

本次补强重点解决以下问题：

- 实体数量不足 8 个
- 缺少视图
- 缺少符合要求的复杂查询
- 部分数据库约束不够完整
- 测试数据和索引验证材料不足

## 当前基础

现有项目已经具备以下 6 个核心实体：

1. `user_accounts`
2. `user_addresses`
3. `products`
4. `cart_items`
5. `orders`
6. `order_items`

前后端已经实现商品浏览、购物车、下单、支付状态更新、地址管理和后台管理功能，因此新增设计应优先围绕订单闭环扩展，而不是引入与现有商城割裂的新业务域。

## 方案选择

评估过的方案有三类：

1. 验收优先：补 `supplier`、`stock_movements`
2. 交易优先：补 `payment_records`、`coupon`
3. 验收与演示兼顾：补 `payment_records`、`reviews`

最终选择第 3 种方案，原因如下：

- `payment_records` 能把现有“模拟支付”行为独立建模
- `reviews` 能补齐商城“购买后反馈”的自然业务闭环
- 两个实体都能直接参与视图和复杂查询设计
- 解释成本低，便于在实验报告中说明设计合理性
- 对现有前后端改动范围可控

## 新增实体设计

### 1. `payment_records`

用于记录订单支付行为，将支付信息从订单状态中拆分出来，形成独立业务实体。

建议字段：

- `id`：主键
- `order_id`：外键，关联 `orders.id`
- `payment_no`：支付流水号，唯一
- `payment_method`：支付方式，取值限定为 `ALIPAY`、`WECHAT`、`BANK_CARD`
- `amount`：支付金额
- `payment_status`：支付状态，取值限定为 `PENDING`、`SUCCESS`、`FAILED`
- `paid_at`：支付成功时间，可空
- `created_at`
- `updated_at`

约束设计：

- 主键：`id`
- 外键：`order_id -> orders.id`
- 唯一：`payment_no`
- 非空：`order_id`、`payment_no`、`payment_method`、`amount`、`payment_status`
- 检查：`amount > 0`
- 检查：`payment_status` 限定在枚举集合中
- 检查：`payment_method` 限定在枚举集合中

关系说明：

- 一个订单对应一条或多条支付记录
- 一条支付记录只属于一个订单

### 2. `reviews`

用于记录用户购买商品后的评分与文字评价。

建议字段：

- `id`：主键
- `user_id`：外键，关联 `user_accounts.id`
- `product_id`：外键，关联 `products.id`
- `order_item_id`：外键，关联 `order_items.id`
- `rating`：评分，限定为 1 到 5
- `content`：评价内容，可空
- `created_at`
- `updated_at`

约束设计：

- 主键：`id`
- 外键：`user_id -> user_accounts.id`
- 外键：`product_id -> products.id`
- 外键：`order_item_id -> order_items.id`
- 唯一：`order_item_id`，表示一个订单项最多评价一次
- 非空：`user_id`、`product_id`、`order_item_id`、`rating`
- 检查：`rating between 1 and 5`

关系说明：

- 一个用户可以发表多条评价
- 一个商品可以拥有多条评价
- 一个订单项最多只能产生一条评价

## 补强后的实体集合

补充 `payment_records` 与 `reviews` 后，系统实体数达到 8 个：

1. `user_accounts`
2. `user_addresses`
3. `products`
4. `cart_items`
5. `orders`
6. `order_items`
7. `payment_records`
8. `reviews`

这满足实验中“系统至少包括 8 个实体”的要求。

## ER 关系建议

- `user_accounts 1:n user_addresses`
- `user_accounts 1:n orders`
- `user_accounts 1:n cart_items`
- `products 1:n cart_items`
- `orders 1:n order_items`
- `orders 1:n payment_records`
- `user_accounts 1:n reviews`
- `products 1:n reviews`
- `order_items 1:1 reviews`

其中应重点说明两条新增关系：

- `orders -> payment_records`：体现订单支付行为独立建模
- `order_items -> reviews`：体现购买后的评价闭环

## 视图设计

### 视图名称

`order_detail_view`

### 设计目标

封装订单、用户、订单项和支付记录的高频联表查询，作为订单详情展示、后台订单管理和统计分析的统一数据来源。

### 视图字段

- `order_id`
- `order_number`
- `user_id`
- `username`
- `order_status`
- `order_created_at`
- `order_item_id`
- `product_name`
- `product_sku`
- `quantity`
- `unit_price`
- `item_amount`
- `payment_status`
- `payment_method`
- `paid_at`

### 视图来源表

- `orders`
- `user_accounts`
- `order_items`
- `payment_records`

### 视图设计理由

- 订单展示功能频繁依赖多表连接
- 视图可减少重复 SQL 编写
- 视图结果可直接支撑后台订单列表与报表分析
- 在实验报告中容易说明“视图服务业务查询”的价值

## 复杂查询设计

### 查询名称

`用户消费与商品偏好统计查询`

### 查询目标

统计每个用户的：

- 订单数量
- 购买商品总件数
- 支付总金额
- 最近一次支付时间
- 最常购买的商品类别

### 涉及表

- `user_accounts`
- `orders`
- `order_items`
- `products`
- `payment_records`

### 查询特征

- 5 表连接
- 聚合统计：`COUNT`、`SUM`、`MAX`
- 分组：`GROUP BY`
- 排序：`ORDER BY`
- 窗口函数或 CTE：用于求每个用户购买次数最多的类别

### 业务意义

该查询不是单纯列出数据，而是面向真实业务统计，反映用户消费能力和购买偏好，适合作为实验中的复杂查询示例。

## SQL 草案

### `payment_records`

```sql
CREATE TABLE payment_records (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    payment_no VARCHAR(40) NOT NULL UNIQUE,
    payment_method VARCHAR(20) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT chk_payment_amount
        CHECK (amount > 0),
    CONSTRAINT chk_payment_status
        CHECK (payment_status IN ('PENDING', 'SUCCESS', 'FAILED')),
    CONSTRAINT chk_payment_method
        CHECK (payment_method IN ('ALIPAY', 'WECHAT', 'BANK_CARD'))
);
```

### `reviews`

```sql
CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    order_item_id BIGINT NOT NULL UNIQUE,
    rating INTEGER NOT NULL,
    content VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_review_user
        FOREIGN KEY (user_id) REFERENCES user_accounts(id),
    CONSTRAINT fk_review_product
        FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_review_order_item
        FOREIGN KEY (order_item_id) REFERENCES order_items(id),
    CONSTRAINT chk_review_rating
        CHECK (rating BETWEEN 1 AND 5)
);
```

### 索引

```sql
CREATE INDEX idx_payment_records_order_id ON payment_records(order_id);
CREATE INDEX idx_payment_records_status_paid_at ON payment_records(payment_status, paid_at);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
```

### 视图

```sql
CREATE VIEW order_detail_view AS
SELECT
    o.id AS order_id,
    o.order_number,
    ua.id AS user_id,
    ua.username,
    o.status AS order_status,
    o.created_at AS order_created_at,
    oi.id AS order_item_id,
    oi.product_name,
    oi.product_sku,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS item_amount,
    pr.payment_status,
    pr.payment_method,
    pr.paid_at
FROM orders o
JOIN user_accounts ua ON ua.id = o.user_id
JOIN order_items oi ON oi.order_id = o.id
LEFT JOIN payment_records pr ON pr.order_id = o.id;
```

### 复杂查询

```sql
WITH user_order_stats AS (
    SELECT
        ua.id AS user_id,
        ua.username,
        COUNT(DISTINCT o.id) AS order_count,
        COALESCE(SUM(oi.quantity), 0) AS total_items,
        COALESCE(SUM(pr.amount), 0) AS total_paid_amount,
        MAX(pr.paid_at) AS last_paid_at
    FROM user_accounts ua
    LEFT JOIN orders o
        ON o.user_id = ua.id
    LEFT JOIN order_items oi
        ON oi.order_id = o.id
    LEFT JOIN payment_records pr
        ON pr.order_id = o.id
       AND pr.payment_status = 'SUCCESS'
    GROUP BY ua.id, ua.username
),
user_category_rank AS (
    SELECT
        ua.id AS user_id,
        p.category,
        SUM(oi.quantity) AS category_buy_count,
        ROW_NUMBER() OVER (
            PARTITION BY ua.id
            ORDER BY SUM(oi.quantity) DESC, p.category ASC
        ) AS rn
    FROM user_accounts ua
    JOIN orders o
        ON o.user_id = ua.id
    JOIN order_items oi
        ON oi.order_id = o.id
    JOIN products p
        ON p.sku = oi.product_sku
    GROUP BY ua.id, p.category
)
SELECT
    s.user_id,
    s.username,
    s.order_count,
    s.total_items,
    s.total_paid_amount,
    s.last_paid_at,
    c.category AS favorite_category,
    c.category_buy_count
FROM user_order_stats s
LEFT JOIN user_category_rank c
    ON c.user_id = s.user_id
   AND c.rn = 1
ORDER BY s.total_paid_amount DESC, s.order_count DESC, s.user_id ASC;
```

## 测试数据设计

建议准备三层数据：

1. 演示数据：支持功能展示
2. 批量订单与订单项数据：支持复杂查询验证
3. 支付与评价数据：支持统计与视图演示

推荐规模：

- 10 个以上用户
- 30 个以上商品
- 50 条以上订单用于演示
- 1000 条以上订单用于索引与性能验证
- 200 条以上评价数据

## 索引验证设计

重点验证以下索引：

- `idx_payment_records_order_id`
- `idx_payment_records_status_paid_at`
- `idx_orders_user_status`

验证方式：

1. 使用 `EXPLAIN ANALYZE` 执行复杂查询或其关键子查询
2. 记录无索引时的执行计划和执行时间
3. 建立索引后重新执行
4. 对比是否由顺序扫描转为索引扫描，以及总耗时是否下降

## 边界与风险

- 当前 `order_items` 仅保存 `product_sku` 与 `product_name` 快照，没有 `product_id`
- 因此复杂查询使用 `products.sku = order_items.product_sku` 关联，能够工作，但规范性略弱

建议在后续实现中顺手补两个数据库修正：

1. 给 `order_items` 增加 `product_id`
2. 给 `cart_items.user_id` 与 `orders.shipping_address_id` 补充外键

这两项不是本轮设计主目标，但有助于提升数据库完整性说明。

## 落地顺序

1. 新增 `payment_records` 与 `reviews`
2. 补充必要索引与约束
3. 创建 `order_detail_view`
4. 插入测试数据
5. 实现复杂查询 SQL 与展示接口
6. 完成索引前后性能对比说明

## 验收对应关系

- 至少 8 个实体：通过新增 `payment_records` 与 `reviews` 满足
- 视图：通过 `order_detail_view` 满足
- 复杂查询：通过“用户消费与商品偏好统计查询”满足
- 索引：通过订单、支付、评价相关索引满足
- 完整性约束：通过主键、外键、唯一、非空、检查约束以及应用层校验共同满足
- 图形化界面：复用现有 Nuxt 前端页面进行展示
