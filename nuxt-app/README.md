# 星辰商城前端（Nuxt 4）

本目录为星辰商城数据库系统实验的 Nuxt 4 前端项目，包含普通用户界面与管理员界面，对应本次实验中的图形化操作模块与页面展示部分。

## 当前功能

- 用户登录、注册、忘记密码
- 商城商品浏览、关键字搜索、分类筛选、分页
- 商品详情查看、购物车加入
- 购物车增删改查
- 收货地址管理
- 订单创建、支付、订单列表查看
- 商品评价新增、查看、修改
- 管理员仪表盘、商品管理、订单管理、用户管理、评价管理

## 本地运行

```powershell
pnpm install
pnpm dev
```

默认开发地址：`http://localhost:3000`

如果后端运行在自定义地址，需要设置：

```powershell
$env:NUXT_PUBLIC_API_BASE="http://localhost:8081"
```

## 常用命令

- `pnpm dev`：启动开发环境
- `pnpm typecheck`：执行 Nuxt TypeScript 校验
- `pnpm build`：构建生产版本
- `pnpm preview`：预览生产构建结果

## 目录结构

```text
app/
  pages/
    shop/        商城与商品详情
    cart/        购物车
    checkout/    订单结算
    account/     用户资料、地址、订单、评价
    orders/      管理员订单管理
    products/    管理员商品管理
    users/       管理员用户管理
    reviews/     管理员评价管理
```

## 说明

本目录 README 仅保留当前实验版本的前端说明，不再记录历史开发时间线。
完整实验说明与报告请查看项目根目录下的 `report.md` 和 `report.docx`。
