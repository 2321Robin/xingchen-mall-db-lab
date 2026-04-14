# 项目报告

## 项目整体功能描述
星辰商城项目基于 Nuxt 4 与 @nuxt/ui 组件库构建，提供完整的前台购物与后台管理体验。前台模块支持商品浏览、关键字搜索、分类筛选、购物车与结算流程，并整合用户账户信息、收货地址、订单跟踪等核心功能。后台模块面向管理员开放，覆盖商品上下架管理、订单处理、用户审核与仪表盘统计等场景，同时通过一致的布局与响应式设计保障在桌面与移动端均具备良好的操作体验。

## 程序设计过程的完整图文说明
1. 需求分析与信息架构规划，明确普通用户与管理员的角色权限范围。

	 ```mermaid
	 mindmap
		 root((星辰商城需求))
			 核心角色
				 普通用户
					 浏览商品
					 下单结算
					 管理账户
				 管理员
					 商品管理
					 订单处理
					 用户审核
			 系统约束
				 Nuxt4
				 @nuxt/ui
				 REST API
	 ```

2. 制定页面路由与组件划分，绘制高层次的页面关系图，确保导航结构清晰。

	 ```mermaid
	 graph TD
		 Root[/App.vue/]
		 Root --> Dashboard
		 Root --> Shop
		 Root --> Cart
		 Root --> Account
		 Root --> Admin
		 Account --> Profile
		 Account --> Addresses
		 Account --> Orders
		 Admin --> Products
		 Admin --> OrdersMgmt
		 Admin --> Users
	 ```

3. 设计全局样式与布局容器，统一水平边距、标题区与内容区的视觉规范。

	 ```mermaid
	 graph LR
		 Layout((AppLayout)) --> Header
		 Layout --> MainContainer
		 Layout --> Footer
		 MainContainer --> PaddingLayer[统一水平边距]
		 PaddingLayer --> PageHeader
		 PaddingLayer --> ContentArea
	 ```

4. 实现核心业务功能，包括商品列表、购物车交互、订单状态流转与后台数据提取逻辑。

	 ```mermaid
	 flowchart LR
		 FetchProducts-->DisplayGrid
		 DisplayGrid-->AddToCart
		 AddToCart-->UpdateCart
		 UpdateCart-->Checkout
		 Checkout-->SubmitOrder
		 SubmitOrder-->OrderStatus{订单状态}
		 OrderStatus -->|待付款| Pending
		 OrderStatus -->|已付款| Paid
		 OrderStatus -->|配送中| Shipped
		 OrderStatus -->|已完成| Delivered
		 AdminAPI[后台数据抓取] --> OrderStatus
	 ```

5. 完成账户相关模块的表单校验、接口异常处理与正向反馈提示，提升用户体验。

	 ```mermaid
	 sequenceDiagram
		 participant U as 用户
		 participant UI as 前端表单
		 participant API as 后端接口
		 U->>UI: 输入资料
		 UI->>UI: 本地校验
		 UI-->>U: 显示错误信息?
		 UI->>API: 提交合法请求
		 API-->>UI: 返回成功/失败
		 UI-->>U: 成功提示或异常反馈
		 UI->>UI: 启动反馈定时器
	 ```

6. 项目结构

	项目代码仓库 `web-homework/` 的实际目录层级如下（含主要源码、配置与构建产物目录）：

	```
	web-homework/
	|-- README.md
	|-- nuxt-app/
	|   |-- .editorconfig
	|   |-- .git/
	|   |-- .github/
	|   |   `-- workflows/
	|   |       `-- ci.yml
	|   |-- .gitignore
	|   |-- .npmrc
	|   |-- .nuxt/            (Nuxt 构建缓存)
	|   |-- .output/          (静态产物)
	|   |-- app/
	|   |   |-- app.config.ts
	|   |   |-- app.vue
	|   |   |-- assets/
	|   |   |   `-- css/
	|   |   |       `-- main.css
	|   |   |-- components/
	|   |   |   |-- AppLogo.vue
	|   |   |   `-- TemplateMenu.vue
	|   |   `-- pages/
	|   |       |-- account/
	|   |       |   |-- addresses.vue
	|   |       |   |-- orders.vue
	|   |       |   |-- password.vue
	|   |       |   `-- profile.vue
	|   |       |-- cart/
	|   |       |   `-- index.vue
	|   |       |-- checkout/
	|   |       |   `-- index.vue
	|   |       |-- dashboard.vue
	|   |       |-- forgot-password.vue
	|   |       |-- index.vue
	|   |       |-- orders/
	|   |       |   `-- index.vue
	|   |       |-- products/
	|   |       |   |-- create.vue
	|   |       |   |-- index.vue
	|   |       |   `-- [id].vue
	|   |       |-- register.vue
	|   |       |-- shop/
	|   |       |   `-- index.vue
	|   |       `-- users/
	|   |           `-- index.vue
	|   |-- composables/
	|   |   `-- useCurrentUser.ts
	|   |-- eslint.config.mjs
	|   |-- node_modules/     (依赖包)
	|   |-- nuxt.config.ts
	|   |-- package.json
	|   |-- plugins/
	|   |   `-- session.client.ts
	|   |-- pnpm-lock.yaml
	|   |-- pnpm-workspace.yaml
	|   |-- public/
	|   |   `-- favicon.ico
	|   |-- README.md
	|   |-- renovate.json
	|   |-- report.md
	|   |-- tsconfig.json
	|   `-- types/
	|       `-- auth.ts
	`-- server/
	    |-- .git/
	    |-- .gitattributes
	    |-- .gitignore
	    |-- .gradle/
	    |-- .idea/
	    |-- bin/
	    |-- build/
	    |-- build.gradle
	    |-- gradle/
	    |-- gradlew
	    |-- gradlew.bat
	    |-- HELP.md
	    |-- README.md
	    |-- settings.gradle
	    `-- src/
	        |-- main/
	        |   |-- java/
	        |   |   `-- com/example/server/
	        |   |       |-- auth/
	        |   |       |-- cart/
	        |   |       |-- common/
	        |   |       |-- config/
	        |   |       |-- order/
	        |   |       |-- product/
	        |   |       |-- user/
	        |   |       `-- ServerApplication.java
	        |   `-- resources/
	        |       `-- application.yml
	        `-- test/
	            `-- java/
	                `-- (测试目录当前为空)
	```

	其中 `.nuxt/`、`.output/`、`node_modules/`、`build/` 等目录为构建或依赖产物，通常不需要手工修改，仅供结构完整性参考。