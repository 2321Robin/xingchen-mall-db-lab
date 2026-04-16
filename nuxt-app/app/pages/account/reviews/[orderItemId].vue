<script setup lang="ts">
import { computed, onBeforeMount, reactive, ref, watch } from 'vue'
import { useDateFormat } from '@vueuse/core'
import type { FetchError } from 'ofetch'

type CurrentUser = {
  userId?: number
}

type OrderStatus = 'PENDING_PAYMENT' | 'PAID' | 'SHIPPED' | 'DELIVERED'

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
  status: OrderStatus
  createdAt: string
  items: OrderItem[]
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

type ReviewContext = {
  orderId: number
  orderNumber: string
  orderStatus: OrderStatus
  orderCreatedAt: string
  item: OrderItem
}

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const route = useRoute()
const router = useRouter()
const currentUser = useState<CurrentUser | null>('currentUser', () => null)

const loading = ref(false)
const submitting = ref(false)
const loadError = ref('')
const formError = ref('')
const successMessage = ref('')
const context = ref<ReviewContext | null>(null)
const existingReview = ref<ReviewResponse | null>(null)

const state = reactive({
  rating: 5,
  content: ''
})

const ratingOptions = [1, 2, 3, 4, 5].map(value => ({
  label: `${value} 星`,
  value
}))

const orderItemId = computed(() => Number(route.params.orderItemId))
const isEditMode = computed(() => Boolean(existingReview.value))
const submitLabel = computed(() => isEditMode.value ? '保存修改' : '提交评价')
const pageDescription = computed(() => isEditMode.value
  ? '你可以修改这条评价内容和评分。'
  : '为已购买商品提交评价，记录真实购物体验。')

useSeoMeta({
  title: '商品评价 - 星辰商城',
  description: () => pageDescription.value
})

const isReviewableStatus = (status: OrderStatus) => status === 'PAID' || status === 'SHIPPED' || status === 'DELIVERED'

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

const fetchReviewContext = async () => {
  if (!currentUser.value?.userId || !Number.isFinite(orderItemId.value)) {
    loadError.value = '订单商品参数不合法'
    return
  }

  const orders = await $fetch<Order[]>(`${apiBase}/api/user/orders/${currentUser.value.userId}`)
  let matchedContext: ReviewContext | null = null

  for (const order of orders) {
    const item = order.items.find(entry => entry.id === orderItemId.value)
    if (!item) {
      continue
    }

    matchedContext = {
      orderId: order.id,
      orderNumber: order.orderNumber,
      orderStatus: order.status,
      orderCreatedAt: order.createdAt,
      item
    }
    break
  }

  if (!matchedContext) {
    throw new Error('未找到对应的订单商品信息')
  }

  if (!isReviewableStatus(matchedContext.orderStatus)) {
    throw new Error('当前订单状态不支持评价')
  }

  context.value = matchedContext
}

const fetchExistingReview = async () => {
  if (!currentUser.value?.userId || !Number.isFinite(orderItemId.value)) {
    return
  }

  try {
    existingReview.value = await $fetch<ReviewResponse>(`${apiBase}/api/user/reviews/${currentUser.value.userId}/order-item/${orderItemId.value}`)
    state.rating = existingReview.value.rating
    state.content = existingReview.value.content ?? ''
  } catch (error) {
    if (isFetchError(error) && error.statusCode === 404) {
      existingReview.value = null
      return
    }
    throw error
  }
}

const loadPage = async () => {
  if (!currentUser.value?.userId) {
    return
  }

  loading.value = true
  loadError.value = ''
  formError.value = ''

  try {
    await fetchReviewContext()
    await fetchExistingReview()
  } catch (error) {
    loadError.value = extractErrorMessage(error, error instanceof Error ? error.message : '加载评价页面失败，请稍后重试')
    context.value = null
    existingReview.value = null
  } finally {
    loading.value = false
  }
}

const resetPageState = () => {
  loadError.value = ''
  formError.value = ''
  successMessage.value = ''
  context.value = null
  existingReview.value = null
  state.rating = 5
  state.content = ''
}

const submitReview = async () => {
  if (!currentUser.value?.userId || !context.value || submitting.value) {
    return
  }

  formError.value = ''
  successMessage.value = ''

  if (state.rating < 1 || state.rating > 5) {
    formError.value = '评分必须在 1 到 5 星之间'
    return
  }

  if (state.content.trim().length > 500) {
    formError.value = '评价内容不能超过 500 字'
    return
  }

  submitting.value = true

  try {
    const editing = isEditMode.value
    const endpoint = editing
      ? `${apiBase}/api/user/reviews/${currentUser.value.userId}/order-item/${context.value.item.id}`
      : `${apiBase}/api/user/reviews/${currentUser.value.userId}`

    const method = editing ? 'PUT' : 'POST'

    const response = await $fetch<ReviewResponse>(endpoint, {
      method,
      body: {
        orderItemId: context.value.item.id,
        rating: state.rating,
        content: state.content.trim() || null
      }
    })

    existingReview.value = response
    state.rating = response.rating
    state.content = response.content ?? ''
    successMessage.value = editing ? '评价修改成功' : '评价提交成功'
  } catch (error) {
    formError.value = extractErrorMessage(error, isEditMode.value ? '评价修改失败，请稍后重试' : '评价提交失败，请稍后重试')
  } finally {
    submitting.value = false
  }
}

onBeforeMount(() => {
  if (!currentUser.value) {
    router.push('/')
  }
})

watch(orderItemId, () => {
  resetPageState()
  if (currentUser.value?.userId) {
    loadPage()
  }
}, { immediate: true })
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-4xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="商品评价"
        :description="pageDescription"
        :links="[
          {
            label: '返回主界面',
            icon: 'i-lucide-home',
            to: '/dashboard',
            color: 'neutral',
            variant: 'ghost'
          },
          {
            label: '返回我的订单',
            icon: 'i-lucide-arrow-left',
            to: '/account/orders',
            color: 'primary',
            variant: 'soft'
          }
        ]"
      />

      <UAlert
        v-if="loadError"
        color="error"
        variant="soft"
        icon="i-lucide-alert-circle"
        :title="loadError"
      />

      <template v-else>
        <UCard v-if="loading">
          <div class="space-y-4">
            <USkeleton class="h-6 w-40" />
            <USkeleton class="h-20 w-full" />
            <USkeleton class="h-48 w-full" />
          </div>
        </UCard>

        <template v-else-if="context">
          <UCard>
            <template #header>
              <div class="space-y-1">
                <h2 class="text-base font-semibold">订单商品信息</h2>
                <p class="text-sm text-muted">请基于真实购物体验填写评价内容。</p>
              </div>
            </template>

            <div class="grid gap-4 md:grid-cols-2">
              <div class="space-y-2 text-sm">
                <p><span class="font-medium">订单号：</span>{{ context.orderNumber }}</p>
                <p><span class="font-medium">下单时间：</span>{{ formatDateTime(context.orderCreatedAt) }}</p>
                <p><span class="font-medium">商品名称：</span>{{ context.item.productName }}</p>
                <p><span class="font-medium">商品 SKU：</span>{{ context.item.productSku || '未设置' }}</p>
              </div>
              <div class="space-y-2 text-sm">
                <p><span class="font-medium">购买数量：</span>{{ context.item.quantity }}</p>
                <p><span class="font-medium">成交单价：</span>￥{{ formatPrice(context.item.unitPrice) }}</p>
                <p><span class="font-medium">订单状态：</span>{{ context.orderStatus }}</p>
              </div>
            </div>
          </UCard>

          <UCard>
            <template #header>
              <div class="space-y-1">
                <h2 class="text-base font-semibold">{{ isEditMode ? '修改评价' : '填写评价' }}</h2>
                <p class="text-sm text-muted">
                  {{ isEditMode ? '你可以修改这条评价内容和评分。' : '评分范围为 1 到 5 星，评价内容最多 500 字。' }}
                </p>
              </div>
            </template>

            <div class="space-y-4">
              <UAlert
                v-if="formError"
                color="error"
                variant="soft"
                icon="i-lucide-alert-triangle"
                :title="formError"
              />

              <UAlert
                v-if="successMessage"
                color="success"
                variant="soft"
                icon="i-lucide-check-circle"
                :title="successMessage"
              />

              <UForm :state="state" class="space-y-5" @submit.prevent="submitReview">
                <UFormField label="评分" name="rating" required>
                  <USelect
                    v-model="state.rating"
                    :items="ratingOptions"
                    value-key="value"
                    placeholder="请选择评分"
                    class="w-full"
                  />
                </UFormField>

                <UFormField label="评价内容" name="content">
                  <UTextarea
                    v-model="state.content"
                    :rows="6"
                    placeholder="可以填写商品质量、包装、物流体验、使用感受等内容"
                    class="w-full"
                  />
                </UFormField>

                <div class="flex flex-wrap items-center gap-3">
                  <UButton
                    type="submit"
                    color="primary"
                    :icon="isEditMode ? 'i-lucide-save' : 'i-lucide-send'"
                    :loading="submitting"
                    :disabled="submitting"
                  >
                    {{ submitLabel }}
                  </UButton>
                  <UButton
                    color="neutral"
                    variant="ghost"
                    icon="i-lucide-arrow-left"
                    to="/account/orders"
                  >
                    返回我的订单
                  </UButton>
                </div>
              </UForm>

              <div v-if="existingReview" class="rounded-lg border border-success/30 bg-success/5 p-4 text-sm">
                <p class="font-medium text-success">已保存的评价</p>
                <p class="mt-2">评分：{{ existingReview.rating }} 星</p>
                <p class="mt-1">提交时间：{{ formatDateTime(existingReview.createdAt) }}</p>
                <p class="mt-1">更新时间：{{ formatDateTime(existingReview.updatedAt) }}</p>
                <p class="mt-2 whitespace-pre-wrap text-muted">
                  {{ existingReview.content || '未填写文字评价。' }}
                </p>
              </div>
            </div>
          </UCard>
        </template>
      </template>
    </div>
  </div>
</template>
