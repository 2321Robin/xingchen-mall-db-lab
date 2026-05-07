# 星辰商城后端（Spring Boot 3）

本目录为星辰商城数据库系统实验的后端服务，基于 Spring Boot 3、Spring Data JPA 与 PostgreSQL，提供用户、商品、购物车、订单、支付记录、评价、统计报表等 REST API。

## 当前功能

- 用户注册、登录、个人资料管理
- 收货地址管理
- 商品浏览与管理员商品管理
- 购物车增删改查
- 订单创建、支付、订单查询
- 支付记录摘要返回
- 商品评价新增、查询、修改
- 管理员用户、订单、评价管理
- 用户消费与商品偏好统计查询

## 本地运行

```powershell
./gradlew.bat test
./gradlew.bat bootRun --args="--server.port=8081"
```

默认后端地址：`http://localhost:8081`

数据库连接可通过以下环境变量覆盖：

- `DATABASE_URL`
- `DATABASE_USERNAME`
- `DATABASE_PASSWORD`

## 关键目录

```text
src/main/java/com/example/server/
  auth/      认证模块
  cart/      购物车模块
  order/     订单与支付摘要模块
  payment/   支付记录模块
  product/   商品模块与商城展示接口
  report/    统计报表与复杂查询模块
  review/    商品评价模块
  user/      用户与地址模块
```

## 说明

本目录 README 仅保留当前实验版本的后端说明，不再保留旧阶段开发记录。
实验报告请查看项目根目录下的 `report.md` 和 `report.docx`。
