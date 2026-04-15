# 星辰商城数据库系统实验报告

## 1. 实验要求

本实验要求围绕一个完整业务场景完成数据库系统设计与实现，核心验收点包括：

- 选择一个具有实际意义的应用场景，完成需求分析。
- 设计概念模型，并将其转换为关系模型。
- 系统至少包含 8 个实体。
- 需要在数据库中使用主键、外键、唯一、非空、检查等完整性约束。
- 需要使用索引，并对索引效果进行验证分析。
- 需要至少设计 1 个视图。
- 需要实现至少 1 条复杂查询，满足多表连接、分组统计、嵌套查询或窗口函数等要求。
- 需要结合编程语言与数据库管理系统实现可运行程序，提供增删改查、查询和统计功能。
- 系统在违规输入或非法操作时，应给出明确的中文提示。

## 2. 需求描述

本实验选题为“星辰商城数据库系统”。系统面向两个角色：普通用户和管理员。

普通用户的主要需求如下：

- 注册、登录和维护个人资料。
- 浏览商品，按名称或分类查询商品。
- 将商品加入购物车并修改数量。
- 选择收货地址后提交订单。
- 对订单进行模拟支付并查看历史订单。
- 对已购买商品进行评分与评价。

管理员的主要需求如下：

- 管理商品信息，包括新增、修改、删除和上下架。
- 查看订单列表并维护订单状态。
- 查看用户列表并启停用户账号。
- 查看报表统计结果，分析用户消费情况和商品偏好。

因此，系统既要覆盖商城的基础交易流程，也要满足数据库实验对实体、视图、复杂查询和完整性约束的要求。

## 3. 概念数据库设计

### 3.1 实体设计

本系统最终包含 8 个实体：

1. `user_accounts`：用户账户
2. `user_addresses`：用户收货地址
3. `products`：商品
4. `cart_items`：购物车项
5. `orders`：订单
6. `order_items`：订单明细
7. `payment_records`：支付记录
8. `reviews`：商品评价

其中，`payment_records` 和 `reviews` 是为本次实验补强新增的两个实体：

- `payment_records` 将原本只体现在订单状态中的“支付行为”独立建模，便于统计支付信息。
- `reviews` 用于表示用户完成购买后的商品反馈，使商城业务形成自然闭环。

### 3.2 实体关系

主要实体关系如下：

- 一个用户可以拥有多个收货地址，`user_accounts 1:n user_addresses`
- 一个用户可以产生多个订单，`user_accounts 1:n orders`
- 一个用户可以拥有多个购物车项，`user_accounts 1:n cart_items`
- 一个商品可以出现在多个购物车项中，`products 1:n cart_items`
- 一个订单可以包含多个订单明细，`orders 1:n order_items`
- 一个订单可以对应多条支付记录，`orders 1:n payment_records`
- 一个用户可以发表多条评价，`user_accounts 1:n reviews`
- 一个商品可以对应多条评价，`products 1:n reviews`
- 一个订单明细最多只能产生一条评价，`order_items 1:1 reviews`

该设计既满足商城业务逻辑，也满足实验对实体数量和关系设计的要求。

## 4. 逻辑数据库和物理数据库设计

### 4.1 关系模式设计

系统中的主要关系模式如下：

- `user_accounts(id, username, password_hash, email, phone, role, active, created_at, updated_at)`
- `user_addresses(id, user_id, recipient_name, phone, province, city, district, street, postal_code, is_default, created_at, updated_at)`
- `products(id, name, sku, category, price, stock, status, created_at, updated_at)`
- `cart_items(id, user_id, product_id, quantity, created_at, updated_at)`
- `orders(id, order_number, user_id, total_amount, shipping_address_id, shipping_recipient, shipping_phone, shipping_province, shipping_city, shipping_district, shipping_street, shipping_postal_code, status, created_at, updated_at)`
- `order_items(id, order_id, product_id, product_name, product_sku, quantity, unit_price)`
- `payment_records(id, order_id, payment_no, payment_method, amount, payment_status, paid_at, created_at, updated_at)`
- `reviews(id, user_id, product_id, order_item_id, rating, content, created_at, updated_at)`

### 4.2 完整性约束设计

系统使用了多种完整性约束：

- 主键约束：8 个实体表均使用主键保证记录唯一性。
- 外键约束：如 `orders.user_id`、`order_items.order_id`、`payment_records.order_id`、`reviews.order_item_id` 等。
- 唯一约束：如 `user_accounts.username`、`products.sku`、`payment_records.payment_no`、`reviews.order_item_id`。
- 非空约束：用于用户名、订单编号、商品价格、支付方式、评分等关键字段。
- 检查约束：如订单状态、商品状态、用户角色、评分范围、支付状态、支付方式等。

其中，为保证 `reviews` 的数据一致性，系统除了外键约束外，还额外加入了：

- JPA 实体层一致性校验；
- PostgreSQL 触发器，防止直接 SQL 写入或父表更新破坏 `reviews` 与 `order_items`、`orders`、`products` 之间的一致性。

### 4.3 索引设计

系统中已有和本次补强新增的索引包括：

- `idx_user_addresses_user`
- `idx_user_addresses_default`
- `idx_payment_records_order`
- `idx_reviews_product_id`
- `idx_reviews_user_id`

这些索引主要用于加速地址查询、支付记录查询和评价统计查询。

### 4.4 视图设计

本实验新增业务视图 `order_detail_view`，用于封装订单详情查询。

视图整合以下表：

- `orders`
- `user_accounts`
- `order_items`
- `payment_records`

视图输出字段包括：

- 订单编号、订单状态、创建时间
- 用户编号、用户名
- 订单明细编号、商品编号、商品名称、SKU、数量、单价、小计金额
- 最新支付记录的支付状态、支付方式、支付时间

为了避免一个订单存在多条支付记录时放大订单明细行数，视图内部使用窗口函数先选出“每个订单最新的一条支付记录”，再与订单和订单明细连接，使视图结果保持稳定、一行一条订单明细。

## 5. 数据库创建

### 5.1 建库方式

项目采用 Spring Boot 3 + Spring Data JPA + PostgreSQL 实现。数据库结构一方面通过 JPA 实体映射维护，另一方面在 `db.sql` 中保留完整导出脚本，便于实验演示、报告撰写和数据库还原。

系统初始化数据主要写在：

- `server/src/main/resources/data.sql`
- `db.sql`

### 5.2 新增表创建说明

本次实验补强新增两张关键表：

#### `payment_records`

主要字段：

- `order_id`：所属订单
- `payment_no`：支付流水号
- `payment_method`：支付方式
- `amount`：支付金额
- `payment_status`：支付状态
- `paid_at`：支付完成时间

该表用于支撑订单支付摘要展示和消费统计。

#### `reviews`

主要字段：

- `user_id`：评价用户
- `product_id`：被评价商品
- `order_item_id`：对应订单明细
- `rating`：评分
- `content`：评价内容

该表用于支撑购买后评价和评价统计，并通过唯一约束保证一个订单明细只能评价一次。

### 5.3 测试数据设计

系统初始化了用户、商品、地址、订单、订单明细、支付记录和评价等演示数据，用于支持：

- 基础增删改查演示
- 支付记录与订单响应展示
- 复杂查询统计
- 视图查询验证

此外，针对测试环境还额外编写了 H2 自包含测试数据，保证后端测试不依赖本地 PostgreSQL 实例即可运行。

## 6. 程序实现

### 6.1 后端实现

后端基于 Spring Boot 3 开发，主要模块如下：

- `auth`：认证与密码相关功能
- `user`：用户资料、用户管理、地址管理
- `product`：商品管理与商品浏览
- `cart`：购物车服务
- `order`：下单、查询订单、后台订单管理
- `payment`：支付记录管理
- `review`：商品评价实体与约束
- `report`：报表视图与复杂查询

本次实验补强的关键实现包括：

1. 新增 `payment_records` 实体与支付流程集成。
2. 新增 `reviews` 实体，并补充数据库触发器和实体层校验。
3. 为 `order_items` 增加 `product_id`，便于后续复杂查询正确关联商品。
4. 新增 `order_detail_view`，封装订单详情联表查询。
5. 新增“用户消费与商品偏好统计查询”，通过多表连接、聚合统计和窗口函数计算：
   - 用户订单数
   - 购买商品总件数
   - 支付总金额
   - 最近支付时间
   - 最偏好的商品类别
6. 在订单响应中新增支付摘要字段：
   - `paymentStatus`
   - `paymentMethod`
   - `paidAt`

### 6.2 前端实现

前端基于 Nuxt 4 开发，已具备图形化操作界面，满足实验对 GUI 的要求。

主要页面包括：

- 登录与注册页面
- 商城商品浏览页面
- 购物车页面
- 订单结算页面
- 我的订单页面
- 地址管理页面
- 后台商品管理页面
- 后台订单管理页面
- 后台用户管理页面
- 仪表盘统计页面

这些页面已覆盖：

- 增删改查
- 条件查询
- 数据统计
- 中文错误提示与表单校验

### 6.3 复杂查询实现说明

复杂查询“用户消费与商品偏好统计查询”通过 `report` 模块实现，核心特点如下：

- 参与表：`user_accounts`、`orders`、`order_items`、`products`、`payment_records`
- 使用多表连接与分组统计
- 使用窗口函数求每个用户购买次数最多的商品类别
- 使用左连接保留无订单用户，便于输出完整客户列表
- 对历史 `order_items.product_id` 为空的情况进行了兼容，不会错误丢失用户统计行

该查询满足实验中“至少 3 表连接或嵌套/分组复杂查询”的要求，并且具有实际业务意义。

### 6.4 索引验证说明

为完成实验中的索引验证要求，本系统可在 PostgreSQL 中对复杂查询执行：

```sql
EXPLAIN ANALYZE
WITH ...
SELECT ...
```

重点观察 `payment_records`、`reviews`、`user_addresses` 等表在添加索引前后的执行计划变化，例如：

- 是否由顺序扫描转为索引扫描
- 是否减少了过滤成本
- 是否缩短了联表统计的执行时间

这些结果可直接写入实验报告的“索引效果分析”部分。

## 7. 总结和心得体会

通过本次实验，我完成了一个从需求分析、概念设计、逻辑设计、物理实现到程序开发和测试验证的完整数据库系统实践过程。

本项目原本已经具备商城前后端基础功能，但距离数据库课程实验的严格验收标准仍有差距。通过本次补强，我重点完成了以下工作：

- 将实体数从 6 个补足到 8 个；
- 新增 `payment_records` 和 `reviews` 两个业务实体；
- 新增 `order_detail_view` 业务视图；
- 新增符合要求的复杂统计查询；
- 强化了数据库完整性约束和应用层校验；
- 补充了后端自动化测试与报告材料。

本次实验让我认识到，数据库系统设计不仅仅是“把表建出来”，更重要的是：

- 关系设计是否自然贴合业务；
- 约束是否真正保护了数据质量；
- 查询是否能服务真实业务分析；
- 程序层和数据库层是否保持一致。

后续如果继续扩展该系统，还可以进一步增加真实支付回调、物流跟踪、评价管理页面和更大规模的数据压测，使系统更接近真实商城平台。
