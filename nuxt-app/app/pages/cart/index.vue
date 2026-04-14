<script setup lang="ts">
import { computed, onBeforeMount, onMounted, onUnmounted, ref } from 'vue'
import type { FetchError } from 'ofetch'
import type { TableColumn } from '#ui/types'

useSeoMeta({
  title: '我的购物车 - 星辰商城',
  description: '查看并管理购物车中的商品，支持数量调整与删除。'
})

type ProductStatus = 'DRAFT' | 'ACTIVE' | 'INACTIVE'

type CartItem = {
  id: number
  productId: number
  productName: string
  productSku: string
  category: string
  price: number
  quantity: number
  stock: number
  status: ProductStatus
  subtotal: number
  createdAt: string
  updatedAt: string
}

type CartSummary = {
  items: CartItem[]
  totalItems: number
  totalQuantity: number
  totalAmount: number
}

const columns: TableColumn<CartItem>[] = [
  { accessorKey: 'productName', header: '商品' },
  { accessorKey: 'price', header: '单价' },
  { accessorKey: 'quantity', header: '数量' },
  { accessorKey: 'subtotal', header: '小计' },
  { id: 'actions', header: '操作' }
]

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const router = useRouter()
const currentUser = useState<{ userId?: number } | null>('currentUser', () => null)

onBeforeMount(() => {
  if (!currentUser.value) {
    router.push('/')
  }
})

const summary = ref<CartSummary>({ items: [], totalItems: 0, totalQuantity: 0, totalAmount: 0 })
const loading = ref(false)
const actionError = ref('')
const actionSuccess = ref('')
const updatingIds = ref<number[]>([])
const removingIds = ref<number[]>([])
const clearing = ref(false)

const hasItems = computed(() => summary.value.items.length > 0)
const totalItems = computed(() => summary.value.totalItems)
const totalQuantity = computed(() => summary.value.totalQuantity)
const totalAmountFormatted = computed(() => formatPrice(summary.value.totalAmount))

const isUpdating = (id: number) => updatingIds.value.includes(id)
const isRemoving = (id: number) => removingIds.value.includes(id)
const isProcessing = (id: number) => isUpdating(id) || isRemoving(id)

const formatPrice = (value: number | string | null | undefined) => {
  const numeric = typeof value === 'string' ? Number(value) : value
  if (typeof numeric !== 'number' || Number.isNaN(numeric)) {
    return '0.00'
  }
  return numeric.toFixed(2)
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

const applySummary = (data: CartSummary) => {
  summary.value = {
    items: data.items ?? [],
    totalItems: data.totalItems ?? 0,
    totalQuantity: data.totalQuantity ?? 0,
    totalAmount: data.totalAmount ?? 0
  }
}

let feedbackTimer: ReturnType<typeof setTimeout> | undefined

const resetFeedbackTimer = () => {
  if (feedbackTimer) {
    clearTimeout(feedbackTimer)
    feedbackTimer = undefined
  }
}

const showSuccess = (message: string) => {
  resetFeedbackTimer()
  actionError.value = ''
  actionSuccess.value = message
  feedbackTimer = setTimeout(() => {
    actionSuccess.value = ''
    feedbackTimer = undefined
  }, 2500)
}

const showError = (message: string) => {
  resetFeedbackTimer()
  actionSuccess.value = ''
  actionError.value = message
}

const fetchCart = async () => {
  if (!currentUser.value?.userId) {
    return
  }

  loading.value = true

  try {
    const data = await $fetch<CartSummary>(`${apiBase}/api/user/cart/${currentUser.value.userId}`)
    applySummary(data)
    actionError.value = ''
  } catch (error) {
    showError(extractErrorMessage(error, '加载购物车失败，请稍后重试'))
    applySummary({ items: [], totalItems: 0, totalQuantity: 0, totalAmount: 0 })
  } finally {
    loading.value = false
  }
}

const updateQuantity = async (item: CartItem, nextQuantity: number) => {
  if (!currentUser.value?.userId) {
    return
  }

  const clamped = Math.max(1, Math.min(nextQuantity, item.stock > 0 ? item.stock : nextQuantity))
  const finalQuantity = clamped

  if (finalQuantity !== nextQuantity) {
    if (finalQuantity === 1 && nextQuantity < 1) {
      showError('购物车内商品数量最少为 1')
    }
  }

  if (finalQuantity === item.quantity || isProcessing(item.id)) {
    return
  }

  updatingIds.value = [...updatingIds.value, item.id]

  try {
    const data = await $fetch<CartSummary>(`${apiBase}/api/user/cart/${currentUser.value.userId}/${item.id}`, {
      method: 'PUT',
      body: {
        quantity: finalQuantity
      }
    })

    applySummary(data)
    showSuccess(`已更新“${item.productName}”数量为 ${finalQuantity}`)
  } catch (error) {
    showError(extractErrorMessage(error, '更新数量失败，请稍后重试'))
  } finally {
    updatingIds.value = updatingIds.value.filter(id => id !== item.id)
  }
}

const increaseQuantity = (item: CartItem) => {
  updateQuantity(item, item.quantity + 1)
}

const decreaseQuantity = (item: CartItem) => {
  if (item.quantity <= 1) {
    showError('购物车内商品数量最少为 1')
    return
  }

  updateQuantity(item, item.quantity - 1)
}

const removeItem = async (item: CartItem) => {
  if (!currentUser.value?.userId || isProcessing(item.id)) {
    return
  }

  removingIds.value = [...removingIds.value, item.id]

  try {
    const data = await $fetch<CartSummary>(`${apiBase}/api/user/cart/${currentUser.value.userId}/${item.id}`, {
      method: 'DELETE'
    })

    applySummary(data)
    showSuccess(`已移除“${item.productName}”`)
  } catch (error) {
    showError(extractErrorMessage(error, '移除商品失败，请稍后重试'))
  } finally {
    removingIds.value = removingIds.value.filter(id => id !== item.id)
  }
}

const clearCart = async () => {
  if (!currentUser.value?.userId || !hasItems.value || clearing.value) {
    return
  }

  clearing.value = true

  try {
    const data = await $fetch<CartSummary>(`${apiBase}/api/user/cart/${currentUser.value.userId}`, {
      method: 'DELETE'
    })

    applySummary(data)
    showSuccess('购物车已清空')
  } catch (error) {
    showError(extractErrorMessage(error, '清空购物车失败，请稍后重试'))
  } finally {
    clearing.value = false
  }
}

onMounted(fetchCart)

onUnmounted(() => {
  resetFeedbackTimer()
})
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="我的购物车"
        description="管理购物车商品，调整数量或清空购物车。"
        :links="[
          {
            label: '继续逛逛',
            icon: 'i-lucide-store',
            to: '/shop',
            color: 'primary'
          }
        ]"
      />

      <UCard>
        <template #header>
          <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
            <div>
              <h2 class="text-base font-semibold">购物车明细</h2>
              <p class="text-sm text-muted">
                共 {{ totalItems }} 件商品 · 合计数量 {{ totalQuantity }}
              </p>
            </div>
            <div class="flex items-center gap-2">
              <UButton icon="i-lucide-rotate-cw" variant="ghost" :loading="loading" @click="fetchCart">
                刷新
              </UButton>
              <UButton
                color="error"
                variant="soft"
                icon="i-lucide-trash-2"
                :disabled="!hasItems || clearing"
                :loading="clearing"
                @click="clearCart"
              >
                清空购物车
              </UButton>
            </div>
          </div>
        </template>

        <div class="space-y-6">
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
            <USkeleton v-for="skeleton in 4" :key="skeleton" class="h-32 rounded-xl" />
          </div>

          <template v-else>
            <UTable v-if="hasItems" :data="summary.items" :columns="columns" :loading="loading">
              <template #productName-cell="{ row }">
                <div class="space-y-1">
                  <p class="font-medium">{{ row.original.productName }}</p>
                  <p class="text-xs text-muted">SKU：{{ row.original.productSku }}</p>
                  <p class="text-xs text-muted">分类：{{ row.original.category || '未分类' }}</p>
                  <p v-if="row.original.status !== 'ACTIVE'" class="text-xs text-error">
                    商品已下架，建议移除
                  </p>
                  <p v-else-if="row.original.stock <= 0" class="text-xs text-error">
                    当前库存不足
                  </p>
                </div>
              </template>

              <template #price-cell="{ row }">
                ￥{{ formatPrice(row.original.price) }}
              </template>

              <template #quantity-cell="{ row }">
                <div class="flex items-center gap-2">
                  <UButton
                    icon="i-lucide-minus"
                    size="xs"
                    variant="soft"
                    :disabled="isProcessing(row.original.id) || row.original.quantity <= 1"
                    @click="decreaseQuantity(row.original)"
                  />
                  <span class="w-10 text-center text-sm">{{ row.original.quantity }}</span>
                  <UButton
                    icon="i-lucide-plus"
                    size="xs"
                    variant="soft"
                    :disabled="isProcessing(row.original.id) || row.original.quantity >= row.original.stock"
                    @click="increaseQuantity(row.original)"
                  />
                </div>
              </template>

              <template #subtotal-cell="{ row }">
                ￥{{ formatPrice(row.original.subtotal) }}
              </template>

              <template #actions-cell="{ row }">
                <UButton
                  color="error"
                  variant="ghost"
                  size="xs"
                  icon="i-lucide-x"
                  :loading="isRemoving(row.original.id)"
                  :disabled="isUpdating(row.original.id)"
                  @click="removeItem(row.original)"
                >
                  删除
                </UButton>
              </template>
            </UTable>

            <div
              v-else
              class="flex flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-border/60 p-12 text-center"
            >
              <UIcon name="i-lucide-shopping-bag" class="h-10 w-10 text-muted" />
              <div>
                <p class="text-base font-medium">购物车还是空的</p>
                <p class="text-sm text-muted">去商城挑选心仪的商品吧。</p>
              </div>
              <UButton icon="i-lucide-store" to="/shop" color="primary">
                立即前往
              </UButton>
            </div>
          </template>

          <div class="flex flex-col items-center justify-between gap-4 border-t border-border/60 pt-4 md:flex-row">
            <div class="space-y-1 text-center md:text-left">
              <p class="text-sm text-muted">共 {{ totalItems }} 件商品 · 合计数量 {{ totalQuantity }}</p>
              <p class="text-lg font-semibold text-primary">应付金额：￥{{ totalAmountFormatted }}</p>
            </div>
            <div class="flex items-center gap-2">
              <UButton color="neutral" variant="ghost" icon="i-lucide-package-search" to="/shop">
                继续购物
              </UButton>
              <UButton color="primary" icon="i-lucide-credit-card" :disabled="!hasItems" to="/checkout">
                去结算
              </UButton>
            </div>
          </div>
        </div>
      </UCard>
    </div>
  </div>
</template>
