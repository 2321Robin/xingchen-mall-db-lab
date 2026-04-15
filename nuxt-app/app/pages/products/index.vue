<script setup lang="ts">
import type { FetchError } from 'ofetch'
import type { TableColumn } from '#ui/types'
import { useDateFormat } from '@vueuse/core'

useSeoMeta({
  title: '商品管理 - 控制台',
  description: '浏览并维护星辰商城的商品列表，可快速创建、编辑或删除商品。'
})

type ProductStatus = 'DRAFT' | 'ACTIVE' | 'INACTIVE'

type Product = {
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

type CurrentUser = {
  role?: 'ADMIN' | 'CUSTOMER'
}

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const router = useRouter()
const currentUser = useState<CurrentUser | null>('currentUser', () => null)

onBeforeMount(() => {
  if (!currentUser.value || currentUser.value.role !== 'ADMIN') {
    router.push('/')
  }
})

const products = ref<Product[]>([])
const loading = ref(false)
const errorMessage = ref('')
const deletingIds = ref(new Set<number>())
const searchTerm = ref('')
const tableRows = computed(() => products.value.map(product => ({ ...product })))
const filteredRows = computed(() => {
  const keyword = searchTerm.value.trim().toLowerCase()

  if (!keyword) {
    return tableRows.value
  }

  return tableRows.value.filter((product) => {
    const name = (product.name ?? '').toLowerCase()
    const sku = (product.sku ?? '').toLowerCase()
    const category = (product.category ?? '').toLowerCase()
    return name.includes(keyword) || sku.includes(keyword) || category.includes(keyword)
  })
})

const statusBadges: Record<ProductStatus, { label: string, color: 'success' | 'primary' | 'secondary' | 'info' | 'warning' | 'error' | 'neutral' }> = {
  DRAFT: { label: '草稿', color: 'neutral' },
  ACTIVE: { label: '上架', color: 'success' },
  INACTIVE: { label: '下架', color: 'warning' }
}

type StatusBadge = { label: string, color: 'success' | 'primary' | 'secondary' | 'info' | 'warning' | 'error' | 'neutral' }

const resolveStatusBadge = (status?: ProductStatus | null): StatusBadge =>
  status && statusBadges[status]
    ? statusBadges[status]
    : { label: status ?? '未知', color: 'neutral' }

const columns: TableColumn<Product>[] = [
  { accessorKey: 'name', header: '商品名称' },
  { accessorKey: 'sku', header: 'SKU' },
  { accessorKey: 'category', header: '分类' },
  { accessorKey: 'price', header: '售价' },
  { accessorKey: 'stock', header: '库存' },
  { accessorKey: 'status', header: '状态' },
  { accessorKey: 'createdAt', header: '创建时间' },
  { id: 'actions', header: '操作' }
]

const fetchProducts = async () => {
  loading.value = true
  errorMessage.value = ''

  try {
    const data = await $fetch<Product[]>(`${apiBase}/api/admin/products`)
    products.value = [...data]
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
  }
}

onMounted(fetchProducts)

const handleDelete = async (product: Product) => {
  if (deletingIds.value.has(product.id)) {
    return
  }

  deletingIds.value.add(product.id)
  errorMessage.value = ''

  try {
    await $fetch(`${apiBase}/api/admin/products/${product.id}`, { method: 'DELETE' })
    products.value = products.value.filter(item => item.id !== product.id)
  } catch (error) {
    handleError(error)
  } finally {
    deletingIds.value.delete(product.id)
  }
}

const handleError = (error: unknown) => {
  if (isFetchError(error)) {
    errorMessage.value = error.data?.message || error.statusMessage || '操作失败，请稍后重试'
  } else {
    errorMessage.value = '操作失败，请稍后重试'
  }
}

const formatPrice = (value: number | null | undefined) =>
  typeof value === 'number' && Number.isFinite(value) ? value.toFixed(2) : '0.00'

const formatDate = (value: string) => useDateFormat(value, 'YYYY-MM-DD HH:mm').value

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="商品管理"
        description="维护商品信息，保持库存与定价的准确性。"
        :links="[
          {
            label: '返回主界面',
            icon: 'i-lucide-home',
            to: '/dashboard',
            color: 'neutral',
            variant: 'ghost'
          },
          {
            label: '新增商品',
            icon: 'i-lucide-plus',
            to: '/products/create',
            color: 'primary'
          }
        ]"
      />

      <UCard>
      <template #header>
        <div class="flex items-center justify-between">
          <div>
            <h2 class="text-base font-semibold">商品列表</h2>
            <p class="text-sm text-muted">
              共 {{ filteredRows.length }} 条{{ searchTerm ? '匹配' : '' }}商品记录
              <span v-if="searchTerm" class="text-muted">
                （全部 {{ products.length }} 条）
              </span>
              。
            </p>
          </div>
          <UButton icon="i-lucide-refresh-cw" variant="ghost" :loading="loading" @click="fetchProducts">
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

        <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <UInput
            v-model="searchTerm"
            icon="i-lucide-search"
            placeholder="输入商品名称或 SKU 关键字搜索"
            class="w-full md:w-80"
          />
        </div>

        <UTable :data="filteredRows" :columns="columns" :loading="loading">
          <template #price-cell="{ row }">
            ￥{{ formatPrice(row.original.price) }}
          </template>

          <template #category-cell="{ row }">
            {{ row.original.category || '未分类' }}
          </template>

          <template #status-cell="{ row }">
            <UBadge :color="resolveStatusBadge(row.original.status).color" variant="soft">
              {{ resolveStatusBadge(row.original.status).label }}
            </UBadge>
          </template>

          <template #createdAt-cell="{ row }">
            {{ formatDate(row.original.createdAt) }}
          </template>

          <template #actions-cell="{ row }">
            <div class="flex items-center gap-2">
              <UButton
                icon="i-lucide-pencil"
                size="xs"
                color="primary"
                variant="soft"
                :to="`/products/${row.original.id}`"
              >
                编辑
              </UButton>
              <UButton
                icon="i-lucide-trash-2"
                size="xs"
                color="error"
                variant="ghost"
                :loading="deletingIds.has(row.original.id)"
                @click="handleDelete(row.original)"
              >
                删除
              </UButton>
            </div>
          </template>
        </UTable>
      </div>
      </UCard>
    </div>
  </div>
</template>
