<script setup lang="ts">
import { computed, onBeforeMount, onMounted, onUnmounted, reactive, ref } from 'vue'
import { watchDebounced } from '@vueuse/core'
import type { FetchError } from 'ofetch'

const SELECT_ALL_CATEGORY = 'ALL'

type ProductStatus = 'DRAFT' | 'ACTIVE' | 'INACTIVE'

type ProductItem = {
  id: number
  name: string
  sku: string
  category: string
  price: number
  stock: number
  status: ProductStatus
}

type PagedResponse<T> = {
  items: T[]
  totalItems: number
  totalPages: number
  page: number
  pageSize: number
  hasNext: boolean
  hasPrevious: boolean
}

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const router = useRouter()
const currentUser = useState<{ userId?: number } | null>('currentUser', () => null)

useSeoMeta({
  title: '商城商品 - 星辰商城',
  description: '浏览星辰商城在售商品，支持关键字搜索与分类筛选。'
})

onBeforeMount(() => {
  if (!currentUser.value) {
    router.push('/')
  }
})

const filters = reactive({
  page: 1,
  pageSize: 12,
  keyword: '',
  category: SELECT_ALL_CATEGORY
})

const searchTerm = ref('')
const categories = ref<string[]>([])
const loadingCategories = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const actionError = ref('')
const actionSuccess = ref('')
const products = ref<ProductItem[]>([])
const addingProductIds = ref<number[]>([])
const pagination = reactive({
  totalItems: 0,
  totalPages: 0,
  hasNext: false,
  hasPrevious: false
})
const productQuantities = ref<Record<number, number>>({})

const categoryChips = computed(() => [
  { label: '全部', value: SELECT_ALL_CATEGORY },
  ...categories.value.map(value => ({ label: value, value }))
])

const formattedPage = computed(() => (pagination.totalPages === 0 ? 1 : filters.page))
const formattedTotalPages = computed(() => (pagination.totalPages === 0 ? 1 : pagination.totalPages))

const formatPrice = (value: number | null | undefined) => {
  if (typeof value !== 'number' || Number.isNaN(value)) {
    return '0.00'
  }
  return value.toFixed(2)
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

const isAdding = (id: number) => addingProductIds.value.includes(id)

const canPurchase = (product: ProductItem) => product.status === 'ACTIVE' && product.stock > 0

const getQuantity = (product: ProductItem) => productQuantities.value[product.id] ?? 1

const setQuantity = (product: ProductItem, nextQuantity: number) => {
  const maxStock = product.stock > 0 ? product.stock : 1
  const clamped = Math.min(Math.max(nextQuantity, 1), maxStock)
  productQuantities.value = {
    ...productQuantities.value,
    [product.id]: clamped
  }
}

const increaseQuantity = (product: ProductItem) => {
  if (!canPurchase(product)) {
    return
  }

  const current = getQuantity(product)
  if (current >= product.stock) {
    return
  }

  setQuantity(product, current + 1)
}

const decreaseQuantity = (product: ProductItem) => {
  const current = getQuantity(product)
  if (current <= 1) {
    return
  }

  setQuantity(product, current - 1)
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

const addToCart = async (product: ProductItem) => {
  if (!currentUser.value?.userId) {
    await router.push('/')
    return
  }

  if (!canPurchase(product) || isAdding(product.id)) {
    return
  }

  const quantity = getQuantity(product)

  if (quantity < 1) {
    showError('请选择有效的数量')
    return
  }

  if (quantity > product.stock) {
    showError('购买数量超出库存')
    setQuantity(product, product.stock)
    return
  }

  addingProductIds.value = [...addingProductIds.value, product.id]

  try {
    await $fetch(`${apiBase}/api/user/cart/${currentUser.value.userId}`, {
      method: 'POST',
      body: {
        productId: product.id,
        quantity
      }
    })

    showSuccess(`已加入购物车：“${product.name}” × ${quantity}`)
    setQuantity(product, 1)
  } catch (error) {
    showError(extractErrorMessage(error, '加入购物车失败，请稍后重试'))
  } finally {
    addingProductIds.value = addingProductIds.value.filter(id => id !== product.id)
  }
}

let activeFetchToken = 0

const fetchProducts = async () => {
  const token = ++activeFetchToken
  loading.value = true
  errorMessage.value = ''

  const params: Record<string, string | number> = {
    page: filters.page,
    pageSize: filters.pageSize
  }

  if (filters.keyword) {
    params.keyword = filters.keyword
  }

  if (filters.category !== SELECT_ALL_CATEGORY) {
    params.category = filters.category
  }

  try {
    const data = await $fetch<PagedResponse<ProductItem>>(`${apiBase}/api/catalog/products`, { params })

    if (token !== activeFetchToken) {
      return
    }

    if (data.totalPages > 0 && data.items.length === 0 && filters.page > data.totalPages) {
      filters.page = data.totalPages
      await fetchProducts()
      return
    }

    products.value = data.items
    const nextQuantities: Record<number, number> = {}
    for (const item of data.items) {
      const existing = productQuantities.value[item.id]
      const base = typeof existing === 'number' ? existing : 1
      const maxStock = item.stock > 0 ? item.stock : 1
      nextQuantities[item.id] = Math.min(Math.max(base, 1), maxStock)
    }
    productQuantities.value = nextQuantities
    pagination.totalItems = data.totalItems
    pagination.totalPages = data.totalPages
    pagination.hasNext = data.hasNext
    pagination.hasPrevious = data.hasPrevious
    filters.page = data.page
    filters.pageSize = data.pageSize
  } catch (error) {
    if (token !== activeFetchToken) {
      return
    }

    errorMessage.value = extractErrorMessage(error, '商品加载失败，请稍后重试')
    products.value = []
    pagination.totalItems = 0
    pagination.totalPages = 0
    pagination.hasNext = false
    pagination.hasPrevious = false
  } finally {
    if (token === activeFetchToken) {
      loading.value = false
    }
  }
}

let activeCategoryToken = 0

const fetchCategories = async () => {
  const token = ++activeCategoryToken
  loadingCategories.value = true

  try {
    const data = await $fetch<string[]>(`${apiBase}/api/catalog/products/categories`)

    if (token !== activeCategoryToken) {
      return
    }

    categories.value = data

    if (filters.category !== SELECT_ALL_CATEGORY && !data.includes(filters.category)) {
      filters.category = SELECT_ALL_CATEGORY
    }
  } catch (error) {
    if (token !== activeCategoryToken) {
      return
    }

    errorMessage.value = extractErrorMessage(error, '加载分类失败，请稍后重试')
  } finally {
    if (token === activeCategoryToken) {
      loadingCategories.value = false
    }
  }
}

const selectCategory = (value: string) => {
  if (filters.category === value) {
    return
  }

  filters.category = value
  filters.page = 1
  fetchProducts()
}

const goToPage = (page: number) => {
  if (page < 1 || page === filters.page || loading.value) {
    return
  }

  filters.page = page
  fetchProducts()
}

const resetFilters = () => {
  if (!filters.keyword && filters.category === SELECT_ALL_CATEGORY) {
    return
  }

  searchTerm.value = ''
  filters.keyword = ''
  filters.category = SELECT_ALL_CATEGORY
  filters.page = 1
  fetchProducts()
}

watchDebounced(
  searchTerm,
  (value) => {
    const nextKeyword = value.trim()

    if (filters.keyword === nextKeyword) {
      return
    }

    filters.keyword = nextKeyword
    filters.page = 1
    fetchProducts()
  },
  { debounce: 400, maxWait: 800 }
)

onMounted(async () => {
  await fetchCategories()
  await fetchProducts()
})

onUnmounted(() => {
  resetFeedbackTimer()
})
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-7xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="商城商品"
        description="浏览星辰商城在售商品，支持关键字搜索与分类筛选。"
        :links="[
          {
            label: '购物车',
            icon: 'i-lucide-shopping-cart',
            to: '/cart',
            color: 'primary',
            variant: 'soft'
          },
          {
            label: '返回主界面',
            icon: 'i-lucide-home',
            to: '/dashboard',
            color: 'neutral',
            variant: 'ghost'
          }
        ]"
      />

      <UCard>
        <template #header>
          <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <div>
              <h2 class="text-base font-semibold">在售商品</h2>
              <p class="text-sm text-muted">共 {{ pagination.totalItems }} 件商品，可通过分类与搜索快速定位。</p>
            </div>
            <UButton icon="i-lucide-rotate-cw" variant="ghost" :loading="loading" @click="fetchProducts">
              刷新列表
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

        <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <UInput
            v-model="searchTerm"
            icon="i-lucide-search"
            placeholder="搜索商品名称或 SKU"
            class="w-full md:w-96"
          />

          <div class="flex flex-wrap gap-2">
            <UButton
              v-for="option in categoryChips"
              :key="option.value"
              size="sm"
              :color="filters.category === option.value ? 'primary' : 'neutral'"
              variant="soft"
              :disabled="loading || loadingCategories"
              @click="selectCategory(option.value)"
            >
              {{ option.label }}
            </UButton>
          </div>
        </div>

        <div v-if="loading" class="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          <USkeleton v-for="skeleton in Math.min(filters.pageSize, 6)" :key="skeleton" class="h-40 rounded-xl" />
        </div>

        <template v-else>
          <div v-if="products.length" class="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            <UCard
              v-for="product in products"
              :key="product.id"
              class="flex h-full flex-col justify-between"
            >
              <div class="space-y-3">
                <div class="flex items-start justify-between gap-3">
                  <div>
                    <h3 class="text-base font-semibold">{{ product.name }}</h3>
                    <p class="text-xs text-muted">SKU：{{ product.sku }}</p>
                  </div>
                  <UBadge color="primary" variant="soft">
                    {{ product.category || '未分类' }}
                  </UBadge>
                </div>
              </div>

              <div class="mt-4 space-y-3">
                <div class="flex items-center justify-between">
                  <div class="space-y-1">
                    <p class="text-lg font-semibold text-primary">￥{{ formatPrice(product.price) }}</p>
                    <span class="block text-xs text-muted">库存：{{ product.stock }}</span>
                  </div>
                </div>
                <div class="flex items-center justify-between gap-3">
                  <div class="flex items-center gap-1 rounded-lg border border-border/60 px-2 py-1" role="group" aria-label="选择数量">
                    <UButton
                      icon="i-lucide-minus"
                      size="xs"
                      variant="ghost"
                      :disabled="getQuantity(product) <= 1 || !canPurchase(product)"
                      @click="decreaseQuantity(product)"
                    />
                    <span class="w-10 text-center text-sm font-medium">{{ getQuantity(product) }}</span>
                    <UButton
                      icon="i-lucide-plus"
                      size="xs"
                      variant="ghost"
                      :disabled="!canPurchase(product) || getQuantity(product) >= product.stock"
                      @click="increaseQuantity(product)"
                    />
                  </div>
                  <UButton
                    size="sm"
                    color="neutral"
                    variant="soft"
                    icon="i-lucide-eye"
                    class="h-8 shrink-0"
                    :to="`/shop/${product.id}`"
                  >
                    查看详情
                  </UButton>
                  <UButton
                    icon="i-lucide-shopping-cart"
                    size="sm"
                    class="h-8 min-w-[7rem] flex-1 justify-center whitespace-nowrap"
                    :disabled="!canPurchase(product) || loading"
                    :loading="isAdding(product.id)"
                    @click="addToCart(product)"
                  >
                    {{ canPurchase(product) ? '加入购物车' : '暂不可购' }}
                  </UButton>
                </div>
              </div>
            </UCard>
          </div>

          <div
            v-else
            class="flex flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-border/60 p-10 text-center"
          >
            <UIcon name="i-lucide-package-search" class="h-10 w-10 text-muted" />
            <div>
              <p class="text-base font-medium">暂无匹配的商品</p>
              <p class="text-sm text-muted">尝试调整搜索条件或更换分类。</p>
            </div>
            <UButton size="sm" variant="ghost" icon="i-lucide-rotate-ccw" @click="resetFilters">
              清除筛选
            </UButton>
          </div>
        </template>

        <div class="flex flex-col items-center justify-between gap-4 border-t border-border/60 pt-4 md:flex-row">
          <p class="text-sm text-muted">
            第 {{ formattedPage }} / {{ formattedTotalPages }} 页 · 共 {{ pagination.totalItems }} 件商品
          </p>
          <div class="flex items-center gap-2">
            <UButton
              size="sm"
              variant="ghost"
              icon="i-lucide-chevron-left"
              :disabled="filters.page <= 1 || loading || !pagination.hasPrevious"
              @click="goToPage(filters.page - 1)"
            >
              上一页
            </UButton>
            <UButton
              size="sm"
              variant="ghost"
              icon="i-lucide-chevron-right"
              :disabled="loading || !pagination.hasNext"
              @click="goToPage(filters.page + 1)"
            >
              下一页
            </UButton>
          </div>
        </div>
      </div>
      </UCard>
    </div>
  </div>
</template>
