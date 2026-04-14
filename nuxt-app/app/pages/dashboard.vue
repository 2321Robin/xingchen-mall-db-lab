<script setup lang="ts">
import type { FetchError } from 'ofetch'
import { useDateFormat } from '@vueuse/core'

type ProductStatus = 'DRAFT' | 'ACTIVE' | 'INACTIVE'

type Product = {
  id: number
  status: ProductStatus
  createdAt: string
}

type OrderStatus = 'PENDING_PAYMENT' | 'PAID' | 'SHIPPED' | 'DELIVERED'

type Order = {
  id: number
  status: OrderStatus
  totalAmount: number
  createdAt: string
}

type UserRole = 'ADMIN' | 'CUSTOMER'

type User = {
  id: number
  role: UserRole
  active: boolean
  createdAt: string
}

type QuickLinkColor = 'primary' | 'neutral'

type QuickLink = {
  label: string
  icon: string
  to: string
  color: QuickLinkColor
}

type CurrentUser = {
  username?: string
  role?: UserRole
}

useSeoMeta({
  title: '控制台 - 星辰商城',
  description: '快速了解商城核心指标，并进入各管理模块处理日常工作。'
})

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const router = useRouter()
const currentUser = useState<CurrentUser | null>('currentUser', () => null)

onBeforeMount(() => {
  if (!currentUser.value) {
    router.push('/')
  }
})

const loading = ref(false)
const logoutLoading = ref(false)
const errorMessage = ref('')
const products = ref<Product[]>([])
const orders = ref<Order[]>([])
const users = ref<User[]>([])
const isAdmin = computed(() => currentUser.value?.role === 'ADMIN')

const fetchDashboardData = async () => {
  loading.value = true
  errorMessage.value = ''

  try {
    const productRes = await $fetch<Product[]>(`${apiBase}/api/admin/products`)
    products.value = productRes

    if (isAdmin.value) {
      const [orderRes, userRes] = await Promise.all([
        $fetch<Order[]>(`${apiBase}/api/admin/orders`),
        $fetch<User[]>(`${apiBase}/api/admin/users`)
      ])

      orders.value = orderRes
      users.value = userRes
    } else {
      orders.value = []
      users.value = []
    }
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
  }
}

onMounted(fetchDashboardData)

const activeProductCount = computed(() => products.value.filter(product => product.status === 'ACTIVE').length)
const pendingOrderCount = computed(() => orders.value.filter(order => order.status === 'PENDING_PAYMENT').length)
const paidAmountToday = computed(() => {
  const today = useDateFormat(new Date(), 'YYYY-MM-DD').value
  return orders.value
    .filter(order => order.status !== 'PENDING_PAYMENT' && useDateFormat(order.createdAt, 'YYYY-MM-DD').value === today)
    .reduce((sum, order) => sum + Number(order.totalAmount || 0), 0)
})

const activeUserCount = computed(() => users.value.filter(user => user.active).length)

const quickLinks = computed<QuickLink[]>(() => {
  if (isAdmin.value) {
    return [
      { label: '个人资料', icon: 'i-lucide-user-cog', to: '/account/profile', color: 'primary' },
      { label: '收货地址', icon: 'i-lucide-map-pin', to: '/account/addresses', color: 'primary' },
      { label: '商城商品', icon: 'i-lucide-store', to: '/shop', color: 'primary' },
      { label: '购物车', icon: 'i-lucide-shopping-cart', to: '/cart', color: 'primary' },
      { label: '我的订单', icon: 'i-lucide-receipt', to: '/account/orders', color: 'primary' },
      { label: '商品管理', icon: 'i-lucide-package', to: '/products', color: 'primary' },
      { label: '订单管理', icon: 'i-lucide-truck', to: '/orders', color: 'primary' },
      { label: '用户管理', icon: 'i-lucide-users', to: '/users', color: 'primary' },
      { label: '修改密码', icon: 'i-lucide-key-round', to: '/account/password', color: 'neutral' }
    ]
  }

  return [
    { label: '个人资料', icon: 'i-lucide-user-cog', to: '/account/profile', color: 'primary' },
    { label: '收货地址', icon: 'i-lucide-map-pin', to: '/account/addresses', color: 'primary' },
    { label: '商城商品', icon: 'i-lucide-store', to: '/shop', color: 'primary' },
    { label: '购物车', icon: 'i-lucide-shopping-cart', to: '/cart', color: 'primary' },
    { label: '我的订单', icon: 'i-lucide-receipt', to: '/account/orders', color: 'primary' },
    { label: '修改密码', icon: 'i-lucide-key-round', to: '/account/password', color: 'neutral' }
  ]
})

const handleLogout = async () => {
  if (logoutLoading.value) {
    return
  }

  logoutLoading.value = true

  try {
    await $fetch(`${apiBase}/api/auth/logout`, { method: 'POST' })
  } catch (error) {
    console.error('Logout request failed', error)
  } finally {
    currentUser.value = null
    logoutLoading.value = false
    await router.push('/')
  }
}

const handleError = (error: unknown) => {
  if (isFetchError(error)) {
    errorMessage.value = error.data?.message || error.statusMessage || '加载数据失败，请稍后刷新'
  } else {
    errorMessage.value = '加载数据失败，请稍后刷新'
  }
}

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-10 px-4 sm:px-6 lg:px-8">
    <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
      <UPageHeader
        title="星辰商城控制台"
        description="查看核心指标并前往各管理模块。"
      />
      <UButton
        color="neutral"
        variant="ghost"
        icon="i-lucide-log-out"
        :loading="logoutLoading"
        @click="handleLogout"
      >
        退出登录
      </UButton>
    </div>

    <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
      <UCard>
        <div class="space-y-2">
          <p class="text-sm text-muted">{{ isAdmin ? '在售商品' : '可购买商品' }}</p>
          <p class="text-3xl font-semibold">{{ activeProductCount }}</p>
          <p class="text-xs text-muted">
            <span v-if="isAdmin">共 {{ products.length }} 条商品记录</span>
            <span v-else>统计商城正在上架的商品数量</span>
          </p>
        </div>
      </UCard>
      <UCard>
        <div class="space-y-2">
          <p class="text-sm text-muted">{{ isAdmin ? '待处理订单' : '订单提醒' }}</p>
          <p class="text-3xl font-semibold">
            <span v-if="isAdmin">{{ pendingOrderCount }}</span>
            <span v-else>--</span>
          </p>
          <p class="text-xs text-muted">
            <span v-if="isAdmin">共 {{ orders.length }} 笔订单，点击“订单管理”处理详情</span>
            <span v-else>使用管理员账号查看订单统计</span>
          </p>
        </div>
      </UCard>
      <UCard>
        <div class="space-y-2">
          <p class="text-sm text-muted">{{ isAdmin ? '今日已收款' : '今日收款' }}</p>
          <p class="text-3xl font-semibold">
            <span v-if="isAdmin">￥{{ paidAmountToday.toFixed(2) }}</span>
            <span v-else>--</span>
          </p>
          <p class="text-xs text-muted">
            <span v-if="isAdmin">统计已付款及以上状态订单</span>
            <span v-else>仅管理员可查看收款数据</span>
          </p>
        </div>
      </UCard>
      <UCard>
        <div class="space-y-2">
          <p class="text-sm text-muted">{{ isAdmin ? '启用用户' : '商城会员' }}</p>
          <p class="text-3xl font-semibold">
            <span v-if="isAdmin">{{ activeUserCount }}</span>
            <span v-else>--</span>
          </p>
          <p class="text-xs text-muted">
            <span v-if="isAdmin">共 {{ users.length }} 位账号</span>
            <span v-else>管理员可在“用户管理”维护账号</span>
          </p>
        </div>
      </UCard>
    </div>

    <UCard>
      <template #header>
        <div class="flex items-center justify-between">
          <div>
            <h2 class="text-base font-semibold">快捷导航</h2>
            <p class="text-sm text-muted">快速进入所需的后台页面。</p>
          </div>
          <UButton icon="i-lucide-refresh-cw" variant="ghost" :loading="loading" @click="fetchDashboardData">
            刷新数据
          </UButton>
        </div>
      </template>

      <UAlert
        v-if="errorMessage"
        color="error"
        variant="soft"
        icon="i-lucide-alert-circle"
        :title="errorMessage"
        class="mb-4"
      />

      <div class="grid gap-4 lg:grid-cols-4 md:grid-cols-2">
        <UButton
          v-for="link in quickLinks"
          :key="link.to"
          :to="link.to"
          :color="link.color"
          variant="soft"
          :icon="link.icon"
          class="justify-start"
        >
          {{ link.label }}
        </UButton>
      </div>
    </UCard>
    </div>
  </div>
</template>
