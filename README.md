# 星辰商城数据库实验平台

星辰商城是一个用于数据库系统课程实验的全栈商城项目。项目使用 Nuxt 4 构建前端页面，使用 Spring Boot 3 和 PostgreSQL 提供后端接口与数据持久化，覆盖用户、商品、购物车、订单、支付、评价和统计报表等核心业务。

## 技术栈

- 前端：Nuxt 4、Vue 3、Nuxt UI、TypeScript、pnpm
- 后端：Spring Boot 3、Spring Data JPA、Gradle
- 数据库：PostgreSQL，测试环境兼容 H2
- 架构：前后端分离，REST API 通信

## 功能概览

- 用户注册、登录、资料维护和收货地址管理
- 商品浏览、关键字搜索、分类筛选和分页查询
- 购物车商品增删改查、数量校验和库存反馈
- 订单创建、订单查询、模拟支付和支付摘要展示
- 商品评价新增、查看、修改和后台管理
- 管理员商品、订单、用户、评价管理
- 用户消费与商品偏好统计报表

## 数据库实验内容

- 建模 8 个核心实体：用户、地址、商品、购物车、订单、订单明细、支付记录、商品评价
- 使用主键、外键、唯一、非空、检查约束保护数据一致性
- 创建 `order_detail_view` 封装订单详情联表查询
- 实现用户消费与商品偏好复杂查询，包含多表连接、聚合统计和窗口函数
- 为地址、支付记录、评价等高频查询场景补充索引
- 使用后端测试覆盖订单支付、评价一致性、视图和复杂查询

## 目录结构

```text
.
├── nuxt-app/   # Nuxt 4 前端应用
├── server/     # Spring Boot 3 后端服务
└── README.md   # 项目总览
```

详细说明请查看：

- `nuxt-app/README.md`：前端功能、目录和运行方式
- `server/README.md`：后端模块、接口能力和运行方式

## 本地运行

运行前请确认已安装 JDK、Node.js 和 pnpm。

启动后端：

```powershell
cd server
./gradlew.bat bootRun --args="--server.port=8081"
```

启动前端：

```powershell
cd nuxt-app
pnpm install
$env:NUXT_PUBLIC_API_BASE="http://localhost:8081"
pnpm dev
```

默认访问地址：

- 前端：`http://localhost:3000`
- 后端：`http://localhost:8081`

## 测试

后端测试命令：

```powershell
cd server
./gradlew.bat test
```

前端常用检查命令：

```powershell
cd nuxt-app
pnpm typecheck
pnpm build
```

## 说明

本仓库只保留项目源码、运行说明和必要配置。课程报告、实验要求文档、数据库导出文件等提交材料不纳入版本管理。
