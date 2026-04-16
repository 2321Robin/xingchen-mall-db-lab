<script setup lang="ts">
import { computed, onBeforeMount, reactive, ref, watch } from 'vue'
import { useDateFormat } from '@vueuse/core'
import type { FetchError } from 'ofetch'

useSeoMeta({
  title: '商品详情 - 星辰商城',
  description: '查看商品详情、库存信息与用户评价。'
})

type ProductStatus = 'DRAFT' | 'ACTIVE' | 'INACTIVE'

type ProductDetail = {
  id: number
  name: string
  sku: string
  category: string
  price: number
  stock: number
  status: ProductStatus
  createdAt: string
  updatedAt: string
}

type PublicReviewResponse = {
  id: number
  username: string
  rating: number
  content: string | null
  createdAt: string
}

type ReviewResponse = {
  id: number
  userId: number
  username: string
  productId: number
  productName: string
  orderItemId: number
  orderNumber: string
  rating: number
  content: string | null
  createdAt: string
  updatedAt: string
}

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const route = useRoute()
const router = useRouter()
const currentUser = useState<{ userId?: number } | null>('currentUser', () => null)

const loading = ref(false)
const actionError = ref('')
const actionSuccess = ref('')
const product = ref<ProductDetail | null>(null)
const myReview = ref<ReviewResponse | null>(null)
const reviews = ref<PublicReviewResponse[]>([])
const quantity = ref(1)
const adding = ref(false)
let activeLoadToken = 0

const productId = computed(() => Number(route.params.id))
const canPurchase = computed(() => product.value?.status === 'ACTIVE' && (product.value?.stock ?? 0) > 0)
const reviewCount = computed(() => reviews.value.length)
const averageRating = computed(() => {
  if (!reviews.value.length) {
    return null
  }
  const total = reviews.value.reduce((sum, item) => sum + item.rating, 0)
  return (total / reviews.value.length).toFixed(1)
})

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

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}

const extractErrorMessage = (error: unknown, fallback: string) => {
  if (isFetchError(error)) {
    return error.data?.message || error.statusMessage || fallback
  }
  return fallback
}

const resetState = () => {
  loading.value = false
  actionError.value = ''
  actionSuccess.value = ''
  product.value = null
  myReview.value = null
  reviews.value = []
  quantity.value = 1
  adding.value = false
}

const loadPage = async () => {
  if (!currentUser.value?.userId || !Number.isFinite(productId.value)) {
    actionError.value = '商品参数不合法'
    return
  }

  const token = ++activeLoadToken
  loading.value = true
  actionError.value = ''

  try {
    const productResponse = await $fetch<ProductDetail>(`${apiBase}/api/catalog/products/${productId.value}`)

    if (token !== activeLoadToken) {
      return
    }

    product.value = productResponse
    quantity.value = productResponse.stock > 0 ? 1 : 0

    const [myReviewResult, publicReviewsResult] = await Promise.allSettled([
      $fetch<ReviewResponse>(`${apiBase}/api/user/reviews/${currentUser.value.userId}/products/${productId.value}`),
      $fetch<PublicReviewResponse[]>(`${apiBase}/api/products/${productId.value}/reviews`)
    ])

    if (token !== activeLoadToken) {
      return
    }

    if (myReviewResult.status === 'fulfilled') {
      myReview.value = myReviewResult.value
    } else {
      myReview.value = null
    }

    if (publicReviewsResult.status === 'fulfilled') {
      reviews.value = publicReviewsResult.value
    } else {
      reviews.value = []
    }
  } catch (error) {
    if (token === activeLoadToken) {
      actionError.value = extractErrorMessage(error, '加载商品详情失败，请稍后重试')
      product.value = null
      myReview.value = null
      reviews.value = []
    }
  } finally {
    if (token === activeLoadToken) {
      loading.value = false
    }
  }
}

const increaseQuantity = () => {
  if (!product.value || !canPurchase.value) {
    return
  }
  quantity.value = Math.min(quantity.value + 1, product.value.stock)
}

const decreaseQuantity = () => {
  if (!product.value) {
    return
  }
  quantity.value = Math.max(quantity.value - 1, 1)
}

const addToCart = async () => {
  if (!currentUser.value?.userId || !product.value || adding.value || !canPurchase.value) {
    return
  }

  adding.value = true
  actionError.value = ''
  actionSuccess.value = ''

  try {
    await $fetch(`${apiBase}/api/user/cart/${currentUser.value.userId}`, {
      method: 'POST',
      body: {
        productId: product.value.id,
        quantity: quantity.value
      }
    })

    actionSuccess.value = `已加入购物车：“${product.value.name}” × ${quantity.value}`
    quantity.value = 1
  } catch (error) {
    actionError.value = extractErrorMessage(error, '加入购物车失败，请稍后重试')
  } finally {
    adding.value = false
  }
}

onBeforeMount(() => {
  if (!currentUser.value) {
    router.push('/')
  }
})

watch(productId, () => {
  resetState()
  if (currentUser.value?.userId) {
    loadPage()
  }
}, { immediate: true })
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="商品详情"
        description="查看商品基本信息、库存状态与用户评价。"
        :links="[
          {
            label: '返回主界面',
            icon: 'i-lucide-home',
            to: '/dashboard',
            color: 'neutral',
            variant: 'ghost'
          },
          {
            label: '返回商城',
            icon: 'i-lucide-arrow-left',
            to: '/shop',
            color: 'primary',
            variant: 'soft'
          }
        ]"
      />

      <UAlert
        v-if="actionError"
        color="error"
        variant="soft"
        icon="i-lucide-alert-circle"
        :title="actionError"
      />

      <UAlert
        v-if="actionSuccess"
        color="success"
        variant="soft"
        icon="i-lucide-check-circle"
        :title="actionSuccess"
      />

      <UCard v-if="loading">
        <div class="grid gap-4 lg:grid-cols-[1.1fr_0.9fr]">
          <USkeleton class="h-72 w-full rounded-xl" />
          <div class="space-y-4">
            <USkeleton class="h-8 w-2/3" />
            <USkeleton class="h-20 w-full" />
            <USkeleton class="h-32 w-full" />
          </div>
        </div>
      </UCard>

      <template v-else-if="product">
        <UCard>
          <div class="grid gap-8 lg:grid-cols-[1.1fr_0.9fr]">
            <div class="flex min-h-72 items-center justify-center rounded-2xl border border-dashed border-primary/30 bg-primary-500/5 p-8 text-center">
              <div class="space-y-3">
                <UIcon name="i-lucide-package-open" class="mx-auto h-14 w-14 text-primary" />
                <p class="text-lg font-semibold">{{ product.name }}</p>
                <p class="text-sm text-muted">{{ product.category || '未分类商品' }}</p>
              </div>
            </div>

            <div class="space-y-5">
              <div class="space-y-2">
                <div class="flex flex-wrap items-center gap-2">
                  <UBadge color="primary" variant="soft">{{ product.category || '未分类' }}</UBadge>
                  <UBadge :color="canPurchase ? 'success' : 'neutral'" variant="soft">
                    {{ canPurchase ? '可购买' : '暂不可购' }}
                  </UBadge>
                </div>
                <h2 class="text-2xl font-semibold">{{ product.name }}</h2>
                <p class="text-sm text-muted">SKU：{{ product.sku }}</p>
              </div>

              <div class="rounded-xl border border-border/60 p-4">
                <div class="flex items-end justify-between gap-4">
                  <div>
                    <p class="text-sm text-muted">当前售价</p>
                    <p class="text-3xl font-semibold text-primary">￥{{ formatPrice(product.price) }}</p>
                  </div>
                  <div class="text-right text-sm text-muted">
                    <p>库存：{{ product.stock }}</p>
                    <p>更新时间：{{ formatDateTime(product.updatedAt) }}</p>
                  </div>
                </div>
              </div>

              <div class="flex flex-wrap items-center gap-3">
                <div class="flex items-center gap-1 rounded-lg border border-border/60 px-2 py-1" role="group" aria-label="选择数量">
                  <UButton
                    icon="i-lucide-minus"
                    size="xs"
                    variant="ghost"
                    :disabled="quantity <= 1 || !canPurchase"
                    @click="decreaseQuantity"
                  />
                  <span class="w-10 text-center text-sm font-medium">{{ quantity }}</span>
                  <UButton
                    icon="i-lucide-plus"
                    size="xs"
                    variant="ghost"
                    :disabled="!canPurchase || quantity >= product.stock"
                    @click="increaseQuantity"
                  />
                </div>
                <UButton
                  icon="i-lucide-shopping-cart"
                  :disabled="!canPurchase"
                  :loading="adding"
                  @click="addToCart"
                >
                  {{ canPurchase ? '加入购物车' : '暂不可购' }}
                </UButton>
              </div>
            </div>
          </div>
        </UCard>

        <UCard v-if="myReview" class="border-primary/20 bg-primary-500/5">
          <template #header>
            <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
              <div>
                <h3 class="text-sm font-semibold">我的评价</h3>
                <p class="text-xs text-muted">你可以直接修改自己对该商品的评价。</p>
              </div>
              <UButton
                size="sm"
                color="primary"
                variant="soft"
                icon="i-lucide-pencil-line"
                :to="`/account/reviews/${myReview.orderItemId}`"
              >
                修改我的评价
              </UButton>
            </div>
          </template>

          <div class="space-y-2 text-sm">
            <p>评分：{{ myReview.rating }} 星</p>
            <p class="whitespace-pre-wrap text-muted">{{ myReview.content || '你还没有填写文字评价。' }}</p>
            <p class="text-xs text-muted">更新时间：{{ formatDateTime(myReview.updatedAt || myReview.createdAt) }}</p>
          </div>
        </UCard>

        <UCard>
          <template #header>
            <div class="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
              <div>
                <h2 class="text-base font-semibold">用户评价</h2>
                <p class="text-sm text-muted">查看已购用户的真实反馈。</p>
              </div>
              <div class="text-sm text-muted md:text-right">
                <p>评价数量：{{ reviewCount }}</p>
                <p v-if="averageRating">平均评分：{{ averageRating }} / 5</p>
                <p v-else>平均评分：暂无</p>
              </div>
            </div>
          </template>

          <div v-if="reviews.length" class="space-y-3">
            <div
              v-for="review in reviews"
              :key="review.id"
              class="rounded-lg border border-border/60 p-4"
            >
              <div class="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
                <div class="flex items-center gap-2">
                  <span class="text-sm font-medium">{{ review.username }}</span>
                  <UBadge color="warning" variant="soft">{{ review.rating }} 星</UBadge>
                </div>
                <span class="text-xs text-muted">{{ formatDateTime(review.createdAt) }}</span>
              </div>
              <p class="mt-3 whitespace-pre-wrap text-sm text-muted">
                {{ review.content || '用户未填写文字评价。' }}
              </p>
            </div>
          </div>

          <div
            v-else
            class="flex flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-border/60 p-10 text-center"
          >
            <UIcon name="i-lucide-message-square-heart" class="h-10 w-10 text-muted" />
            <div>
              <p class="text-base font-medium">暂无评价</p>
              <p class="text-sm text-muted">该商品暂时还没有公开评价，欢迎购买后前往订单页提交反馈。</p>
            </div>
          </div>
        </UCard>
      </template>
    </div>
  </div>
</template>
