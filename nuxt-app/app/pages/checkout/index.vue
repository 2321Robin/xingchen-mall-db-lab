<script setup lang="ts">
import { computed, onBeforeMount, onMounted, onUnmounted, ref } from 'vue'
import { useDateFormat } from '@vueuse/core'
import type { FetchError } from 'ofetch'

useSeoMeta({
  title: '订单结算 - 星辰商城',
  description: '选择收货地址并确认购物车商品，完成订单创建与支付状态更新。'
})

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const router = useRouter()
const currentUser = useState<{ userId?: number } | null>('currentUser', () => null)

type ProductStatus = 'DRAFT' | 'ACTIVE' | 'INACTIVE'
type OrderStatus = 'PENDING_PAYMENT' | 'PAID' | 'SHIPPED' | 'DELIVERED'

type CartItem = {
  id: number
  productId: number
  productName: string
  productSku: string | null
  category: string | null
  price: number
  quantity: number
  stock: number
  status: ProductStatus
  subtotal: number
}

type CartSummary = {
  items: CartItem[]
  totalItems: number
  totalQuantity: number
  totalAmount: number
}

type UserAddress = {
  id: number
  recipientName: string
  phone: string
  province: string
  city: string
  district: string
  street: string
  postalCode: string | null
  isDefault: boolean
  createdAt: string
  updatedAt: string
}

type OrderItem = {
  id: number
  productName: string
  productSku: string | null
  quantity: number
  unitPrice: number
}

type Order = {
  id: number
  orderNumber: string
  userId: number
  username: string
  totalAmount: number
  status: OrderStatus
  createdAt: string
  updatedAt: string
  shippingAddressId: number | null
  shippingRecipient: string | null
  shippingPhone: string | null
  shippingProvince: string | null
  shippingCity: string | null
  shippingDistrict: string | null
  shippingStreet: string | null
  shippingPostalCode: string | null
  items: OrderItem[]
}

type CheckoutSummary = {
  cart: CartSummary
  addresses: UserAddress[]
  selectedAddressId: number | null
}

type OrderStatusBadge = {
  label: string
  color: 'warning' | 'primary' | 'info' | 'success'
}

onBeforeMount(() => {
  if (!currentUser.value) {
    router.push('/')
  }
})

const summary = ref<CheckoutSummary | null>(null)
const loading = ref(false)
const errorMessage = ref('')
const actionError = ref('')
const actionSuccess = ref('')
const processing = ref(false)
const selectedAddressId = ref<number | null>(null)
const createdOrder = ref<Order | null>(null)

const statusBadges: Record<OrderStatus, OrderStatusBadge> = {
  PENDING_PAYMENT: { label: '未付款', color: 'warning' },
  PAID: { label: '已付款', color: 'primary' },
  SHIPPED: { label: '已发货', color: 'info' },
  DELIVERED: { label: '已收货', color: 'success' }
}

const addresses = computed(() => summary.value?.addresses ?? [])
const cartItems = computed(() => summary.value?.cart.items ?? [])
const totalQuantity = computed(() => summary.value?.cart.totalQuantity ?? 0)
const totalAmount = computed(() => summary.value?.cart.totalAmount ?? 0)
const hasItems = computed(() => (summary.value?.cart.totalItems ?? 0) > 0)
const canSubmit = computed(() => hasItems.value && selectedAddressId.value !== null && !processing.value && !createdOrder.value)
const selectedAddress = computed(() => addresses.value.find(address => address.id === selectedAddressId.value) ?? null)

const formatPrice = (value: number | null | undefined) => {
  if (typeof value !== 'number' || Number.isNaN(value)) {
    return '0.00'
  }
  return value.toFixed(2)
}

const formatAddress = (address: UserAddress | null) => {
  if (!address) {
    return '未选择收货地址'
  }
  const parts = [address.province, address.city, address.district, address.street].filter(Boolean)
  const postalCode = address.postalCode ? `（邮编：${address.postalCode}）` : ''
  return `${parts.join(' ')}${postalCode}`
}

const formatDate = (value: string | null | undefined) => {
  if (!value) {
    return ''
  }
  return useDateFormat(value, 'YYYY-MM-DD HH:mm').value
}

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}

const extractErrorMessage = (error: unknown, fallback: string) => {
  if (isFetchError(error)) {
    return error.data?.message || error.statusMessage || fallback
  }
  return fallback
}

let feedbackTimer: ReturnType<typeof setTimeout> | null = null

const resetFeedbackTimer = () => {
  if (feedbackTimer) {
    clearTimeout(feedbackTimer)
    feedbackTimer = null
  }
}

const showSuccess = (message: string) => {
  resetFeedbackTimer()
  actionError.value = ''
  actionSuccess.value = message
  feedbackTimer = setTimeout(() => {
    actionSuccess.value = ''
    feedbackTimer = null
  }, 2600)
}

const showError = (message: string) => {
  resetFeedbackTimer()
  actionSuccess.value = ''
  actionError.value = message
}

const fetchSummary = async () => {
  if (!currentUser.value?.userId) {
    return
  }

  loading.value = true
  errorMessage.value = ''

  try {
    const data = await $fetch<CheckoutSummary>(`${apiBase}/api/user/orders/${currentUser.value.userId}/checkout`)
    summary.value = data
    const preferredId = data.selectedAddressId ?? data.addresses[0]?.id ?? null
    selectedAddressId.value = preferredId
  } catch (error) {
    errorMessage.value = extractErrorMessage(error, '加载结算信息失败，请稍后重试')
  } finally {
    loading.value = false
  }
}

const handleSelectAddress = (id: number) => {
  selectedAddressId.value = id
}

const submitOrder = async () => {
  if (!currentUser.value?.userId) {
    await router.push('/')
    return
  }

  if (selectedAddressId.value === null) {
    showError('请选择收货地址后再提交订单')
    return
  }

  if (!hasItems.value) {
    showError('购物车为空，无法提交订单')
    return
  }

  processing.value = true
  showError('')

  try {
    const order = await $fetch<Order>(`${apiBase}/api/user/orders/${currentUser.value.userId}`, {
      method: 'POST',
      body: {
        addressId: selectedAddressId.value
      }
    })

    createdOrder.value = order
    showSuccess(`订单创建成功：${order.orderNumber}`)
    await fetchSummary()
  } catch (error) {
    showError(extractErrorMessage(error, '创建订单失败，请稍后重试'))
  } finally {
    processing.value = false
  }
}

const payOrder = async () => {
  if (!currentUser.value?.userId || !createdOrder.value) {
    return
  }

  if (createdOrder.value.status !== 'PENDING_PAYMENT') {
    showError('当前订单状态无需再次支付')
    return
  }

  processing.value = true
  showError('')

  try {
    const order = await $fetch<Order>(`${apiBase}/api/user/orders/${currentUser.value.userId}/${createdOrder.value.id}/pay`, {
      method: 'POST'
    })

    createdOrder.value = order
    showSuccess('支付状态已更新为已付款')
  } catch (error) {
    showError(extractErrorMessage(error, '支付状态更新失败，请稍后重试'))
  } finally {
    processing.value = false
  }
}

onMounted(async () => {
  await fetchSummary()
})

onUnmounted(() => {
  resetFeedbackTimer()
})
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="订单结算"
        description="确认购物车商品、选择收货地址并提交订单。"
        :links="[
          {
            label: '返回主界面',
            icon: 'i-lucide-home',
            to: '/dashboard',
            color: 'neutral',
            variant: 'ghost'
          },
          {
            label: '返回购物车',
            icon: 'i-lucide-shopping-cart',
            to: '/cart',
            color: 'primary'
          }
        ]"
      />

      <UCard>
        <template #header>
          <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <div>
              <h2 class="text-base font-semibold">确认订单信息</h2>
              <p class="text-sm text-muted">核对购物车商品与收货地址后提交订单。</p>
            </div>
            <UButton icon="i-lucide-rotate-cw" variant="ghost" :loading="loading" @click="fetchSummary">
              刷新
            </UButton>
          </div>
        </template>

        <div class="space-y-6">
          <UAlert
            v-if="errorMessage"
            color="error"
            variant="soft"
            icon="i-lucide-alert-circle"
            :title="errorMessage"
          />

          <UAlert
            v-if="actionError"
            color="error"
            variant="soft"
            icon="i-lucide-alert-triangle"
            :title="actionError"
          />

          <UAlert
            v-if="actionSuccess"
            color="success"
            variant="soft"
            icon="i-lucide-check-circle"
            :title="actionSuccess"
          />

          <div v-if="loading" class="grid gap-4 md:grid-cols-2">
            <USkeleton class="h-48 rounded-xl" />
            <USkeleton class="h-48 rounded-xl" />
          </div>

          <template v-else>
            <div v-if="hasItems" class="space-y-8">
              <div class="space-y-4">
                <div class="flex items-center justify-between">
                  <h3 class="text-sm font-medium text-foreground">收货地址</h3>
                  <UButton size="xs" variant="ghost" icon="i-lucide-map-pin" to="/account/addresses">
                    管理地址
                  </UButton>
                </div>

                <div v-if="addresses.length" class="space-y-3">
                  <label
                    v-for="address in addresses"
                    :key="address.id"
                    class="flex cursor-pointer items-start gap-3 rounded-xl border p-4 transition-colors"
                    :class="address.id === selectedAddressId ? 'border-primary bg-primary/5' : 'border-border/60 hover:border-primary/60'"
                  >
                    <input
                      type="radio"
                      class="sr-only"
                      name="checkout-address"
                      :value="address.id"
                      :checked="address.id === selectedAddressId"
                      @change="handleSelectAddress(address.id)"
                    >
                    <div class="flex-1 space-y-1 text-sm">
                      <div class="flex flex-wrap items-center gap-2">
                        <span class="font-medium">{{ address.recipientName }}</span>
                        <span class="text-muted">{{ address.phone }}</span>
                        <UBadge v-if="address.isDefault" size="xs" color="primary" variant="soft">
                          默认
                        </UBadge>
                        <UBadge v-else size="xs" color="neutral" variant="soft">
                          备选
                        </UBadge>
                      </div>
                      <p class="text-muted">
                        {{ [address.province, address.city, address.district, address.street].filter(Boolean).join(' ') }}
                        <span v-if="address.postalCode" class="ml-2">邮编：{{ address.postalCode }}</span>
                      </p>
                    </div>
                  </label>
                </div>

                <div
                  v-else
                  class="flex flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-border/60 p-8 text-center"
                >
                  <UIcon name="i-lucide-map-pin-off" class="h-8 w-8 text-muted" />
                  <div class="space-y-1">
                    <p class="text-sm font-medium">暂无收货地址</p>
                    <p class="text-xs text-muted">请前往地址管理页面新增收货地址。</p>
                  </div>
                  <UButton size="sm" color="primary" to="/account/addresses" icon="i-lucide-plus">
                    新增地址
                  </UButton>
                </div>
              </div>

              <div class="space-y-3">
                <h3 class="text-sm font-medium text-foreground">商品清单</h3>
                <div class="space-y-3">
                  <div
                    v-for="item in cartItems"
                    :key="item.id"
                    class="rounded-xl border border-border/60 p-4"
                  >
                    <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                      <div class="space-y-1">
                        <p class="text-sm font-semibold">{{ item.productName }}</p>
                        <p class="text-xs text-muted">SKU：{{ item.productSku || '未设置' }}</p>
                        <p class="text-xs text-muted">分类：{{ item.category || '未分类' }}</p>
                      </div>
                      <div class="flex items-center gap-6 text-sm">
                        <span>单价：￥{{ formatPrice(item.price) }}</span>
                        <span>数量：{{ item.quantity }}</span>
                        <span class="font-semibold text-primary">小计：￥{{ formatPrice(item.subtotal) }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="flex flex-col gap-4 rounded-xl border border-border/60 p-4 md:flex-row md:items-center md:justify-between">
                <div class="space-y-1 text-sm">
                  <p>已选商品：{{ summary?.cart.totalItems ?? 0 }} 件 · 合计数量 {{ totalQuantity }}</p>
                  <p v-if="selectedAddress" class="text-muted">收货地址：{{ formatAddress(selectedAddress) }}</p>
                </div>
                <div class="flex flex-col items-end gap-3 text-sm">
                  <p class="text-lg font-semibold text-primary">应付金额：￥{{ formatPrice(totalAmount) }}</p>
                  <div class="flex items-center gap-2">
                    <UButton variant="ghost" color="neutral" icon="i-lucide-shopping-cart" to="/cart">
                      返回购物车
                    </UButton>
                    <UButton
                      color="primary"
                      icon="i-lucide-badge-check"
                      :disabled="!canSubmit"
                      :loading="processing"
                      @click="submitOrder"
                    >
                      提交订单
                    </UButton>
                  </div>
                </div>
              </div>
            </div>

            <div
              v-else
              class="flex flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-border/60 p-10 text-center"
            >
              <UIcon name="i-lucide-package-search" class="h-10 w-10 text-muted" />
              <div>
                <p class="text-base font-medium">购物车为空</p>
                <p class="text-sm text-muted">请返回商城挑选商品后再来结算。</p>
              </div>
              <UButton size="sm" color="primary" icon="i-lucide-store" to="/shop">
                前往商城
              </UButton>
            </div>
          </template>
        </div>
      </UCard>

      <UCard v-if="createdOrder" class="border-primary/40 bg-primary/5">
        <template #header>
          <div class="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
            <div>
              <h2 class="text-base font-semibold">订单详情</h2>
              <p class="text-sm text-muted">订单号：{{ createdOrder.orderNumber }}</p>
            </div>
            <UBadge :color="statusBadges[createdOrder.status].color" variant="soft">
              {{ statusBadges[createdOrder.status].label }}
            </UBadge>
          </div>
        </template>

        <div class="space-y-4">
          <div class="grid gap-2 text-sm md:grid-cols-2">
            <p>创建时间：{{ formatDate(createdOrder.createdAt) }}</p>
            <p>更新时间：{{ formatDate(createdOrder.updatedAt) }}</p>
            <p>收货人：{{ createdOrder.shippingRecipient || '未记录' }}</p>
            <p>联系电话：{{ createdOrder.shippingPhone || '未记录' }}</p>
            <p class="md:col-span-2">
              收货地址：
              {{ [
                createdOrder.shippingProvince,
                createdOrder.shippingCity,
                createdOrder.shippingDistrict,
                createdOrder.shippingStreet
              ]
                .filter(Boolean)
                .join(' ') || '未记录' }}
              <span v-if="createdOrder.shippingPostalCode" class="ml-2">邮编：{{ createdOrder.shippingPostalCode }}</span>
            </p>
          </div>

          <div class="space-y-2">
            <h3 class="text-sm font-medium">商品明细</h3>
            <div class="space-y-2">
              <div
                v-for="item in createdOrder.items"
                :key="item.id"
                class="flex flex-wrap items-center justify-between gap-2 rounded-lg border border-border/60 p-3"
              >
                <span class="text-sm font-medium">{{ item.productName }}</span>
                <span class="text-xs text-muted">SKU：{{ item.productSku || '未设置' }}</span>
                <span class="text-xs text-muted">数量：{{ item.quantity }}</span>
                <span class="text-sm font-semibold text-primary">单价：￥{{ formatPrice(item.unitPrice) }}</span>
              </div>
            </div>
          </div>

          <div class="flex flex-col items-end gap-3 border-t border-border/60 pt-3 text-sm">
            <p class="text-lg font-semibold text-primary">订单金额：￥{{ formatPrice(createdOrder.totalAmount) }}</p>
            <div class="flex items-center gap-2">
              <UButton color="neutral" variant="ghost" icon="i-lucide-store" to="/shop">
                继续购物
              </UButton>
              <UButton
                v-if="createdOrder.status === 'PENDING_PAYMENT'"
                color="primary"
                icon="i-lucide-credit-card"
                :loading="processing"
                @click="payOrder"
              >
                模拟付款
              </UButton>
            </div>
          </div>
        </div>
      </UCard>
    </div>
  </div>
</template>
