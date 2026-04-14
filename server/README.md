# 星辰商城后端（Spring Boot 3）

本目录为星辰商城的后端服务，基于 Spring Boot 3、Spring Data JPA 与 PostgreSQL，提供用户认证、商品浏览、购物车、订单管理等 REST API。

## 已完成功能

- 用户模块：注册、登录、会话管理、个人资料及收货地址 CRUD
- 商品模块：管理员商品 CRUD、普通用户按关键字/分类/分页浏览
- 购物车模块：商品加入、更新数量、删除与清空，库存状态校验
- 订单模块：
  - 管理员：订单查询、改价、状态流转
  - 普通用户：购物车结算、收货地址选择、订单创建、模拟付款、历史订单查询
- 全局异常处理：覆盖认证、购物车、订单等业务错误的统一响应
- 数据初始化：`data.sql` 预置用户、商品、地址及演示订单

## 本地运行

```bash
./gradlew clean build
./gradlew bootRun
```

默认服务监听 `http://localhost:8080`，数据库连接配置见 `src/main/resources/application.properties`，通过环境变量 `DATABASE_URL`、`DATABASE_USERNAME`、`DATABASE_PASSWORD` 可覆盖默认值。

## 关键目录

```
src/main/java/com/example/server/
  auth/              # 认证与会话
  cart/              # 购物车领域模型与接口
  order/             # 订单实体、服务、控制器
  product/           # 商品领域
  user/              # 用户与地址模块
```

## 遇到的问题与解决方案

| 日期 | 问题 | 定位 | 解决方式 |
| ---- | ---- | ---- | -------- |
| 2025-11-10 | 扩展订单实体添加收货信息时报注解无法解析 | IDE 缓存旧编译结果 | 清理并重新导入 `jakarta.persistence` 相关依赖后编译正常 |
| 2025-11-11 | 订单生成逻辑中使用 `forEach` 无法累加总价 | Lambda 捕获的 `totalAmount` 非最终变量 | 改用增强 `for` 循环累积金额并同步扣减库存 |
| 2025-11-11 | 初始化订单缺少收货地址数据 | `data.sql` 未写入新列 | 更新脚本在插入订单前写入地址并补齐快照字段 |

更多接口说明和字段细节参考代码注释以及 `CartController`、`OrderUserController`、`OrderAdminController` 中的注释描述。
