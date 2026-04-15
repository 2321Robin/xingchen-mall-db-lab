<script setup lang="ts">
import type { FetchError } from 'ofetch'
import type { TableColumn } from '#ui/types'
import type { SelectItem } from '@nuxt/ui'
import { useDateFormat } from '@vueuse/core'

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
  userId: number
  username: string
  totalAmount: number
  status: OrderStatus
  createdAt: string
  updatedAt: string
  items: OrderItem[]
}

type CurrentUser = {
  role?: 'ADMIN' | 'CUSTOMER'
}

useSeoMeta({
  title: '订单管理 - 控制台',
  description: '查询与维护商城订单，支持调整价格及更新发货状态。'
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

const orders = ref<Order[]>([])
const loading = ref(false)
const pageErrorMessage = ref('')
const modalErrorMessage = ref('')
const processing = ref(false)
const selectedOrder = ref<Order | null>(null)
const searchTerm = ref('')

const tableRows = computed(() => orders.value.map(order => ({ ...order })))
const filteredRows = computed(() => {
  const keyword = searchTerm.value.trim().toLowerCase()

  if (!keyword) {
    return tableRows.value
  }

  return tableRows.value.filter((order) => {
    const orderNumber = (order.orderNumber ?? '').toLowerCase()
    const username = (order.username ?? '').toLowerCase()
    const status = (order.status ?? '').toLowerCase()
    const itemNames = Array.isArray(order.items)
      ? order.items.map(item => (item.productName ?? '').toLowerCase()).join(' ')
      : ''

    return (
      orderNumber.includes(keyword)
      || username.includes(keyword)
      || status.includes(keyword)
      || itemNames.includes(keyword)
    )
  })
})

const modalType = ref<'price' | 'status' | null>(null)
const isModalOpen = ref(false)

const priceForm = reactive<{ totalAmount: number | null }>({ totalAmount: null })
const statusForm = reactive<{ status: OrderStatus | null }>({ status: null })

const modalTitle = computed(() => {
  if (!modalType.value || !selectedOrder.value) {
    return '订单操作'
  }

  return modalType.value === 'price' ? '调整订单金额' : '更新订单状态'
})

const modalDescription = computed(() => {
  if (!modalType.value || !selectedOrder.value) {
    return '选择一个订单以执行相应操作。'
  }

  const orderNumber = selectedOrder.value.orderNumber

  return modalType.value === 'price'
    ? `调整订单金额，订单号：${orderNumber}`
    : `更新订单状态，订单号：${orderNumber}`
})

const statusOptions: SelectItem[] = [
  {
    label: '未付款（待用户完成支付）',
    value: 'PENDING_PAYMENT',
    description: '订单已创建但尚未完成支付，可提醒用户或取消。'
  },
  {
    label: '已付款（准备发货）',
    value: 'PAID',
    description: '买家已付款，请尽快安排备货与发货。'
  },
  {
    label: '已发货（物流配送中）',
    value: 'SHIPPED',
    description: '订单已交付物流，等待用户签收。'
  },
  {
    label: '已收货（交易完成）',
    value: 'DELIVERED',
    description: '用户确认收货或签收，订单流程结束。'
  }
]

const statusBadges: Record<OrderStatus, { label: string, color: 'neutral' | 'warning' | 'primary' | 'info' | 'success' }> = {
  PENDING_PAYMENT: { label: '未付款', color: 'warning' },
  PAID: { label: '已付款', color: 'primary' },
  SHIPPED: { label: '已发货', color: 'info' },
  DELIVERED: { label: '已收货', color: 'success' }
}

const columns: TableColumn<Order>[] = [
  { accessorKey: 'orderNumber', header: '订单号' },
  { accessorKey: 'username', header: '用户' },
  { accessorKey: 'totalAmount', header: '金额' },
  { accessorKey: 'status', header: '状态' },
  { accessorKey: 'createdAt', header: '创建时间' },
  { id: 'actions', header: '操作' }
]

const fetchOrders = async () => {
  loading.value = true
  pageErrorMessage.value = ''

  try {
    const data = await $fetch<Order[]>(`${apiBase}/api/admin/orders`)
    orders.value = [...data]
  } catch (error) {
    handleError(error, 'page')
  } finally {
    loading.value = false
  }
}

onMounted(fetchOrders)

const openPriceModal = (order: Order) => {
  selectedOrder.value = order
  priceForm.totalAmount = Number(order.totalAmount.toFixed(2))
  statusForm.status = null
  modalErrorMessage.value = ''
  processing.value = false
  modalType.value = 'price'
  isModalOpen.value = true
}

const openStatusModal = (order: Order) => {
  selectedOrder.value = order
  statusForm.status = order.status
  priceForm.totalAmount = null
  modalErrorMessage.value = ''
  processing.value = false
  modalType.value = 'status'
  isModalOpen.value = true
}

const submitPrice = async () => {
  if (!selectedOrder.value || priceForm.totalAmount === null || priceForm.totalAmount <= 0) {
    modalErrorMessage.value = '请输入有效的订单金额'
    return
  }

  processing.value = true
  modalErrorMessage.value = ''

  try {
    const updated = await $fetch<Order>(`${apiBase}/api/admin/orders/${selectedOrder.value.id}/price`, {
      method: 'PUT',
      body: {
        totalAmount: Number(priceForm.totalAmount.toFixed(2))
      }
    })

    orders.value = orders.value.map(order => (order.id === updated.id ? updated : order))
    closeModal()
  } catch (error) {
    handleError(error, 'modal')
  } finally {
    processing.value = false
  }
}

const submitStatus = async () => {
  if (!selectedOrder.value || !statusForm.status) {
    modalErrorMessage.value = '请选择订单状态'
    return
  }

  processing.value = true
  modalErrorMessage.value = ''

  try {
    const updated = await $fetch<Order>(`${apiBase}/api/admin/orders/${selectedOrder.value.id}/status`, {
      method: 'PUT',
      body: {
        status: statusForm.status
      }
    })

    orders.value = orders.value.map(order => (order.id === updated.id ? updated : order))
    closeModal()
  } catch (error) {
    handleError(error, 'modal')
  } finally {
    processing.value = false
  }
}

const handleError = (error: unknown, target: 'page' | 'modal' = 'page') => {
  const message = isFetchError(error)
    ? error.data?.message || error.statusMessage || '操作失败，请稍后重试'
    : '操作失败，请稍后重试'

  if (target === 'page') {
    pageErrorMessage.value = message
  } else {
    modalErrorMessage.value = message
  }
}

const closeModal = () => {
  isModalOpen.value = false
}

let modalResetTimer: ReturnType<typeof setTimeout> | null = null

watch(isModalOpen, (open) => {
  if (!open) {
    if (modalResetTimer) {
      clearTimeout(modalResetTimer)
    }
    modalResetTimer = setTimeout(() => {
      modalType.value = null
      selectedOrder.value = null
      priceForm.totalAmount = null
      statusForm.status = null
      modalErrorMessage.value = ''
      processing.value = false
      modalResetTimer = null
    }, 200)
  } else if (modalResetTimer) {
    clearTimeout(modalResetTimer)
    modalResetTimer = null
  }
})

onBeforeUnmount(() => {
  if (modalResetTimer) {
    clearTimeout(modalResetTimer)
  }
})
const formatAmount = (value: number | null | undefined) =>
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
        title="订单管理"
        description="对订单进行查询、改价和发货状态调整。"
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
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-base font-semibold">订单列表</h2>
              <p class="text-sm text-muted">
                共 {{ filteredRows.length }} 个{{ searchTerm ? '匹配' : '' }}订单
                <span v-if="searchTerm" class="text-muted">（全部 {{ orders.length }} 个）</span>
                。
              </p>
            </div>
            <UButton icon="i-lucide-refresh-cw" variant="ghost" :loading="loading" @click="fetchOrders">
              刷新
            </UButton>
          </div>
        </template>

        <div class="space-y-4">
          <UAlert
            v-if="pageErrorMessage"
            color="error"
            variant="soft"
            icon="i-lucide-alert-circle"
            :title="pageErrorMessage"
          />

          <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <UInput
              v-model="searchTerm"
              icon="i-lucide-search"
              placeholder="输入订单号、用户名或商品关键字搜索"
              class="w-full md:w-80"
            />
          </div>

          <UTable :data="filteredRows" :columns="columns" :loading="loading">
            <template #totalAmount-cell="{ row }">
              ￥{{ formatAmount(row.original.totalAmount) }}
            </template>

            <template #status-cell="{ row }">
              <UBadge :color="statusBadges[row.original.status].color" variant="soft">
                {{ statusBadges[row.original.status].label }}
              </UBadge>
            </template>

            <template #createdAt-cell="{ row }">
              {{ formatDate(row.original.createdAt) }}
            </template>

            <template #actions-cell="{ row }">
              <div class="flex items-center gap-2">
                <UButton
                  icon="i-lucide-badge-dollar-sign"
                  size="xs"
                  variant="soft"
                  color="primary"
                  @click="openPriceModal(row.original)"
                >
                  改价
                </UButton>
                <UButton
                  icon="i-lucide-truck"
                  size="xs"
                  variant="soft"
                  color="info"
                  @click="openStatusModal(row.original)"
                >
                  更改状态
                </UButton>
              </div>
            </template>
          </UTable>
        </div>
      </UCard>

      <UModal
        v-if="modalType && selectedOrder"
        v-model="isModalOpen"
        :ui="{ content: 'sm:max-w-md' }"
      >
        <div id="order-modal-title" class="sr-only">{{ modalTitle }}</div>
        <div id="order-modal-description" class="sr-only">{{ modalDescription }}</div>

        <UCard
          v-if="modalType === 'price' && selectedOrder"
          aria-labelledby="order-modal-title"
          aria-describedby="order-modal-description"
        >
          <template #header>
            <div>
              <h2 class="text-base font-semibold">{{ modalTitle }}</h2>
              <p class="text-sm text-muted">订单号：{{ selectedOrder.orderNumber }}</p>
            </div>
          </template>

          <div class="space-y-4">
            <UForm :state="priceForm" @submit.prevent="submitPrice">
              <UFormField label="订单金额 (元)" name="totalAmount" required>
                <p class="mb-1 text-xs text-muted">示例：299.00；修改后系统会保留两位小数。</p>
                <UInput v-model.number="priceForm.totalAmount" type="number" min="0" step="0.01" />
              </UFormField>
            </UForm>

            <UAlert
              v-if="modalErrorMessage"
              color="error"
              variant="soft"
              icon="i-lucide-alert-circle"
              :title="modalErrorMessage"
            />

            <div class="flex justify-end gap-3">
              <UButton color="neutral" variant="ghost" @click="closeModal">取消</UButton>
              <UButton :loading="processing" icon="i-lucide-save" @click="submitPrice">保存</UButton>
            </div>
          </div>
        </UCard>

        <UCard
          v-else-if="modalType === 'status' && selectedOrder"
          aria-labelledby="order-modal-title"
          aria-describedby="order-modal-description"
        >
          <template #header>
            <div>
              <h2 class="text-base font-semibold">{{ modalTitle }}</h2>
              <p class="text-sm text-muted">订单号：{{ selectedOrder.orderNumber }}</p>
            </div>
          </template>

          <div class="space-y-4">
            <UForm :state="statusForm" @submit.prevent="submitStatus">
              <UFormField label="订单状态" name="status" required>
                <p class="mb-1 text-xs text-muted">请选择当前订单所处阶段，方便用户跟踪。</p>
                <USelect
                  v-model="statusForm.status"
                  :items="statusOptions"
                  placeholder="请选择订单状态"
                  value-key="value"
                />
              </UFormField>
            </UForm>

            <UAlert
              v-if="modalErrorMessage"
              color="error"
              variant="soft"
              icon="i-lucide-alert-circle"
              :title="modalErrorMessage"
            />

            <div class="flex justify-end gap-3">
              <UButton color="neutral" variant="ghost" @click="closeModal">取消</UButton>
              <UButton :loading="processing" icon="i-lucide-save" @click="submitStatus">保存</UButton>
            </div>
          </div>
        </UCard>
      </UModal>
    </div>
  </div>
</template>
