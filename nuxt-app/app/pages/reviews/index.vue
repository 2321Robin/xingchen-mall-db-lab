<script setup lang="ts">
import type { FetchError } from 'ofetch'
import type { TableColumn } from '#ui/types'
import { useDateFormat } from '@vueuse/core'

type ReviewRow = {
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

type CurrentUser = {
  role?: 'ADMIN' | 'CUSTOMER'
}

useSeoMeta({
  title: '评价管理 - 控制台',
  description: '管理员查看商城用户评价列表，了解商品反馈情况。'
})

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const router = useRouter()
const currentUser = useState<CurrentUser | null>('currentUser', () => null)

onBeforeMount(() => {
  if (!currentUser.value || currentUser.value.role !== 'ADMIN') {
    router.push('/')
  }
})

const reviews = ref<ReviewRow[]>([])
const loading = ref(false)
const errorMessage = ref('')
const searchTerm = ref('')

const columns: TableColumn<ReviewRow>[] = [
  { accessorKey: 'username', header: '评价用户' },
  { accessorKey: 'productName', header: '商品' },
  { accessorKey: 'orderNumber', header: '订单号' },
  { accessorKey: 'rating', header: '评分' },
  { accessorKey: 'content', header: '评价内容' },
  { accessorKey: 'createdAt', header: '提交时间' }
]

const filteredRows = computed(() => {
  const keyword = searchTerm.value.trim().toLowerCase()

  if (!keyword) {
    return reviews.value
  }

  return reviews.value.filter((review) => {
    const username = (review.username ?? '').toLowerCase()
    const productName = (review.productName ?? '').toLowerCase()
    const orderNumber = (review.orderNumber ?? '').toLowerCase()
    const content = (review.content ?? '').toLowerCase()
    const rating = String(review.rating)

    return (
      username.includes(keyword)
      || productName.includes(keyword)
      || orderNumber.includes(keyword)
      || content.includes(keyword)
      || rating.includes(keyword)
    )
  })
})

const fetchReviews = async () => {
  loading.value = true
  errorMessage.value = ''

  try {
    reviews.value = await $fetch<ReviewRow[]>(`${apiBase}/api/admin/reviews`)
  } catch (error) {
    errorMessage.value = isFetchError(error)
      ? error.data?.message || error.statusMessage || '加载评价列表失败，请稍后重试'
      : '加载评价列表失败，请稍后重试'
  } finally {
    loading.value = false
  }
}

const formatDate = (value: string) => useDateFormat(value, 'YYYY-MM-DD HH:mm').value

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}

onMounted(fetchReviews)
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="评价管理"
        description="查看用户已提交的商品评价，快速了解商品反馈与购买体验。"
        :links="[
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
          <div class="flex items-center justify-between gap-4">
            <div>
              <h2 class="text-base font-semibold">评价列表</h2>
              <p class="text-sm text-muted">共 {{ filteredRows.length }} 条{{ searchTerm ? '匹配' : '' }}评价记录。</p>
            </div>
            <UButton icon="i-lucide-refresh-cw" variant="ghost" :loading="loading" @click="fetchReviews">
              刷新
            </UButton>
          </div>
        </template>

        <div class="space-y-4">
          <UAlert
            v-if="errorMessage"
            color="error"
            variant="soft"
            icon="i-lucide-alert-circle"
            :title="errorMessage"
          />

          <UInput
            v-model="searchTerm"
            icon="i-lucide-search"
            placeholder="输入用户、商品、订单号或评价内容搜索"
            class="w-full md:w-96"
          />

          <UTable :data="filteredRows" :columns="columns" :loading="loading">
            <template #rating-cell="{ row }">
              <UBadge color="warning" variant="soft">{{ row.original.rating }} 星</UBadge>
            </template>

            <template #content-cell="{ row }">
              <span class="line-clamp-2 max-w-xs text-sm text-muted">
                {{ row.original.content || '未填写文字评价' }}
              </span>
            </template>

            <template #createdAt-cell="{ row }">
              {{ formatDate(row.original.createdAt) }}
            </template>
          </UTable>
        </div>
      </UCard>
    </div>
  </div>
</template>
