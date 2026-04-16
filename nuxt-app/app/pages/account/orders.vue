<script setup lang="ts">
import { computed, onBeforeMount, onMounted, onUnmounted, ref } from 'vue'
import type { FetchError } from 'ofetch'
import { useDateFormat } from '@vueuse/core'

useSeoMeta({
  title: '我的订单 - 星辰商城',
  description: '查看个人订单列表、明细，并支持待付款订单的支付操作。'
})

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const router = useRouter()
const currentUser = useState<{ userId?: number } | null>('currentUser', () => null)

type OrderStatus = 'PENDING_PAYMENT' | 'PAID' | 'SHIPPED' | 'DELIVERED'

type OrderItem = {
  id: number
  productName: string
  productSku: string | null
  quantity: number
  unitPrice: number
}

type ReviewSummary = {
  id: number
  orderItemId: number
  rating: number
  content: string | null
  createdAt: string
}

type ReviewState = 'reviewed' | 'missing' | 'error'

type Order = {
  id: number
  orderNumber: string
  userId: number
  username: string
  totalAmount: number
  status: OrderStatus
  createdAt: string
  updatedAt: string
  shippingRecipient: string | null
  shippingPhone: string | null
  shippingProvince: string | null
  shippingCity: string | null
  shippingDistrict: string | null
  shippingStreet: string | null
  shippingPostalCode: string | null
  items: OrderItem[]
}

type OrderStatusBadge = {
  label: string
  description: string
  color: 'warning' | 'primary' | 'info' | 'success'
}

onBeforeMount(() => {
  if (!currentUser.value) {
    router.push('/')
  }
})

const orders = ref<Order[]>([])
const loading = ref(false)
const errorMessage = ref('')
const actionError = ref('')
const actionSuccess = ref('')
const processingIds = ref<number[]>([])
const reviewLookup = ref<Record<number, ReviewSummary>>({})
const reviewStateLookup = ref<Record<number, ReviewState>>({})

const statusBadges: Record<OrderStatus, OrderStatusBadge> = {
  PENDING_PAYMENT: { label: '未付款', description: '订单已生成，等待付款完成。', color: 'warning' },
  PAID: { label: '已付款', description: '订单已完成付款，即将发货。', color: 'primary' },
  SHIPPED: { label: '已发货', description: '订单已发货，物流配送中。', color: 'info' },
  DELIVERED: { label: '已收货', description: '订单已确认收货，交易完成。', color: 'success' }
}

const hasOrders = computed(() => orders.value.length > 0)
const pendingPaymentCount = computed(() => orders.value.filter(order => order.status === 'PENDING_PAYMENT').length)
const totalOrderAmount = computed(() => orders.value.reduce((sum, order) => sum + Number(order.totalAmount || 0), 0))

const isReviewableStatus = (status: OrderStatus) => status === 'PAID' || status === 'SHIPPED' || status === 'DELIVERED'

const hasReview = (orderItemId: number) => Boolean(reviewLookup.value[orderItemId])
const getReviewState = (orderItemId: number) => reviewStateLookup.value[orderItemId]

const formatPrice = (value: number | null | undefined) => {
  if (typeof value !== 'number' || Number.isNaN(value)) {
    return '0.00'
  }
  return value.toFixed(2)
}

const formatDateTime = (value: string | null | undefined) => {
  if (!value) {
    return ''
  }
  return useDateFormat(value, 'YYYY-MM-DD HH:mm').value
}

const formatAddress = (order: Order) => {
  const parts = [order.shippingProvince, order.shippingCity, order.shippingDistrict, order.shippingStreet].filter(Boolean)
  const base = parts.join(' ')
  if (!base) {
    return '暂无收货地址信息'
  }
  const postal = order.shippingPostalCode ? `（邮编：${order.shippingPostalCode}）` : ''
  return `${base}${postal}`
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
  }, 2500)
}

const showError = (message: string) => {
  resetFeedbackTimer()
  actionSuccess.value = ''
  actionError.value = message
}

const fetchOrders = async () => {
  if (!currentUser.value?.userId) {
    return
  }

  loading.value = true
  errorMessage.value = ''

  try {
    const data = await $fetch<Order[]>(`${apiBase}/api/user/orders/${currentUser.value.userId}`)
    orders.value = data
    await fetchReviewStatuses(data)
  } catch (error) {
    errorMessage.value = extractErrorMessage(error, '加载订单列表失败，请稍后重试')
    orders.value = []
    reviewLookup.value = {}
    reviewStateLookup.value = {}
  } finally {
    loading.value = false
  }
}

const fetchReviewStatuses = async (orderList: Order[]) => {
  if (!currentUser.value?.userId) {
    reviewLookup.value = {}
    reviewStateLookup.value = {}
    return
  }

  const eligibleItemIds = orderList
    .filter(order => isReviewableStatus(order.status))
    .flatMap(order => order.items.map(item => item.id))

  if (!eligibleItemIds.length) {
    reviewLookup.value = {}
    reviewStateLookup.value = {}
    return
  }

  const nextLookup: Record<number, ReviewSummary> = {}
  const nextStateLookup: Record<number, ReviewState> = {}

  await Promise.all(eligibleItemIds.map(async (orderItemId) => {
    try {
      const review = await $fetch<ReviewSummary>(`${apiBase}/api/user/reviews/${currentUser.value?.userId}/order-item/${orderItemId}`)
      nextLookup[orderItemId] = review
      nextStateLookup[orderItemId] = 'reviewed'
    } catch (error) {
      if (isFetchError(error) && error.statusCode === 404) {
        nextStateLookup[orderItemId] = 'missing'
      } else {
        nextStateLookup[orderItemId] = 'error'
      }
    }
  }))

  reviewLookup.value = nextLookup
  reviewStateLookup.value = nextStateLookup
}

const payOrder = async (order: Order) => {
  if (!currentUser.value?.userId) {
    await router.push('/')
    return
  }

  if (processingIds.value.includes(order.id)) {
    return
  }

  if (order.status !== 'PENDING_PAYMENT') {
    showError('当前订单状态无需支付')
    return
  }

  processingIds.value = [...processingIds.value, order.id]
  showError('')

  try {
    const updated = await $fetch<Order>(`${apiBase}/api/user/orders/${currentUser.value.userId}/${order.id}/pay`, {
      method: 'POST'
    })

    const nextOrders = orders.value.map(item => (item.id === updated.id ? updated : item))
    orders.value = nextOrders
    await fetchReviewStatuses(nextOrders)
    showSuccess('支付成功，订单状态已更新为已付款')
  } catch (error) {
    showError(extractErrorMessage(error, '支付失败，请稍后重试'))
  } finally {
    processingIds.value = processingIds.value.filter(id => id !== order.id)
  }
}

onMounted(fetchOrders)

onUnmounted(() => {
  resetFeedbackTimer()
})
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
      title="我的订单"
      description="查看历史订单状态并处理待付款订单。"
        :links="[
          {
          label: '返回主界面',
          icon: 'i-lucide-home',
          to: '/dashboard',
          color: 'neutral',
          variant: 'ghost'
        },
        {
          label: '去商城逛逛',
          icon: 'i-lucide-store',
          to: '/shop',
          color: 'primary'
        }
      ]"
      />

      <UCard>
      <template #header>
        <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div>
            <h2 class="text-base font-semibold">订单列表</h2>
            <p class="text-sm text-muted">
              共 {{ orders.length }} 笔订单，待付款 {{ pendingPaymentCount }} 笔 · 总金额 ￥{{ formatPrice(totalOrderAmount) }}
            </p>
          </div>
          <UButton icon="i-lucide-rotate-cw" variant="ghost" :loading="loading" @click="fetchOrders">
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
          <USkeleton v-for="skeleton in 4" :key="skeleton" class="h-40 rounded-xl" />
        </div>

        <template v-else>
          <div v-if="hasOrders" class="space-y-4">
            <UCard
              v-for="order in orders"
              :key="order.id"
              :ui="{ body: 'space-y-4' }"
              class="border-border/80"
            >
              <template #header>
                <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                  <div>
                    <h3 class="text-sm font-semibold">订单号：{{ order.orderNumber }}</h3>
                    <p class="text-xs text-muted">创建时间：{{ formatDateTime(order.createdAt) }}</p>
                  </div>
                  <UBadge :color="statusBadges[order.status].color" variant="soft">
                    {{ statusBadges[order.status].label }}
                  </UBadge>
                </div>
              </template>

              <div class="space-y-2 text-sm">
                <p>收货人：{{ order.shippingRecipient || '未记录' }} · 电话：{{ order.shippingPhone || '未记录' }}</p>
                <p>收货地址：{{ formatAddress(order) }}</p>
                <p class="text-muted">{{ statusBadges[order.status].description }}</p>
              </div>

              <div class="space-y-3">
                <div class="text-xs font-medium text-muted">商品明细</div>
                <div class="space-y-2">
                  <div
                    v-for="item in order.items"
                    :key="item.id"
                    class="flex flex-col gap-2 rounded-lg border border-border/60 p-3 md:flex-row md:items-center md:justify-between"
                  >
                    <div class="space-y-1">
                      <p class="text-sm font-semibold">{{ item.productName }}</p>
                      <p class="text-xs text-muted">SKU：{{ item.productSku || '未设置' }}</p>
                    </div>
                    <div class="flex flex-wrap items-center gap-3 text-sm md:justify-end">
                      <span>数量：{{ item.quantity }}</span>
                      <span>单价：￥{{ formatPrice(item.unitPrice) }}</span>
                       <UButton
                         v-if="isReviewableStatus(order.status) && getReviewState(item.id) === 'missing'"
                         size="xs"
                         color="warning"
                         variant="soft"
                         icon="i-lucide-message-square-plus"
                         title="前往评价页面"
                         :to="`/account/reviews/${item.id}`"
                       >
                         去评价
                       </UButton>
                      <UButton
                        v-else-if="hasReview(item.id)"
                         size="xs"
                         color="success"
                         variant="soft"
                         icon="i-lucide-badge-check"
                         title="查看或修改评价"
                         :to="`/account/reviews/${item.id}`"
                       >
                         已评价
                       </UButton>
                      <UButton
                        v-else-if="isReviewableStatus(order.status) && getReviewState(item.id) === 'error'"
                        size="xs"
                        color="neutral"
                        variant="soft"
                        icon="i-lucide-circle-alert"
                        @click="fetchOrders"
                      >
                        刷新评价状态
                      </UButton>
                    </div>
                  </div>
                </div>
              </div>

              <div class="flex flex-col gap-3 border-t border-border/60 pt-3 md:flex-row md:items-center md:justify-between">
                <div class="text-sm text-muted">
                  <p>最后更新时间：{{ formatDateTime(order.updatedAt) || '无' }}</p>
                </div>
                <div class="flex flex-wrap items-center gap-2">
                  <span class="text-base font-semibold text-primary">订单金额：￥{{ formatPrice(order.totalAmount) }}</span>
                  <UButton
                    v-if="order.status === 'PENDING_PAYMENT'"
                    color="primary"
                    icon="i-lucide-credit-card"
                    :disabled="processingIds.includes(order.id)"
                    :loading="processingIds.includes(order.id)"
                    @click="payOrder(order)"
                  >
                    模拟付款
                  </UButton>
                </div>
              </div>
            </UCard>
          </div>

          <div
            v-else
            class="flex flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-border/60 p-10 text-center"
          >
            <UIcon name="i-lucide-receipt" class="h-10 w-10 text-muted" />
            <div>
              <p class="text-base font-medium">暂无订单记录</p>
              <p class="text-sm text-muted">前往商城挑选商品并完成结算后可在此查看订单。</p>
            </div>
            <UButton size="sm" color="primary" icon="i-lucide-store" to="/shop">
              去商城选购
            </UButton>
          </div>
        </template>
      </div>
      </UCard>
    </div>
  </div>
</template>
