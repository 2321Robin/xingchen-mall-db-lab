<script setup lang="ts">
import type { FetchError } from 'ofetch'
import type { FormSubmitEvent } from '#ui/types'
import type { SelectItem } from '@nuxt/ui'

type ProductStatus = 'DRAFT' | 'ACTIVE' | 'INACTIVE'

type FormState = {
  name: string
  sku: string
  price: number | null
  stock: number | null
  category: string
  status: ProductStatus
}

const route = useRoute()
const router = useRouter()
const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const currentUser = useState<{ role?: string } | null>('currentUser', () => null)

onBeforeMount(() => {
  if (!currentUser.value || currentUser.value.role !== 'ADMIN') {
    router.push('/')
  }
})

const productId = computed(() => Number(route.params.id))

const statusOptions: SelectItem[] = [
  {
    label: '草稿（暂存，前台不可见）',
    value: 'DRAFT',
    description: '仅管理员可见，适合先保存未完成的商品信息。'
  },
  {
    label: '上架（立即可见）',
    value: 'ACTIVE',
    description: '商品会在商城前台展示并可被用户购买。'
  },
  {
    label: '下架（暂时隐藏）',
    value: 'INACTIVE',
    description: '商品不会出现在前台，但信息仍被保留。'
  }
]

const state = reactive<FormState>({
  name: '',
  sku: '',
  price: null,
  stock: null,
  category: '',
  status: 'DRAFT'
})

const loading = ref(false)
const saving = ref(false)
const errorMessage = ref('')

const fetchProduct = async () => {
  loading.value = true
  errorMessage.value = ''

  try {
    const data = await $fetch<FormState & { id: number }>(`${apiBase}/api/admin/products/${productId.value}`)
    state.name = data.name
    state.sku = data.sku
    state.price = data.price
    state.stock = data.stock
    state.category = data.category
    state.status = data.status
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
  }
}

onMounted(fetchProduct)

const onSubmit = async (event: FormSubmitEvent<FormState>) => {
  if (saving.value) {
    return
  }

  errorMessage.value = ''
  const payload = event.data

  if (!payload.name.trim()) {
    errorMessage.value = '请填写商品名称'
    return
  }

  if (!payload.sku.trim()) {
    errorMessage.value = '请填写商品 SKU'
    return
  }

  if (!payload.category.trim()) {
    errorMessage.value = '请填写商品分类'
    return
  }

  if (payload.price === null || payload.price <= 0) {
    errorMessage.value = '请输入有效的销售价格'
    return
  }

  if (payload.stock === null || payload.stock < 0) {
    errorMessage.value = '库存数量不能为负数'
    return
  }

  saving.value = true

  try {
    await $fetch(`${apiBase}/api/admin/products/${productId.value}`, {
      method: 'PUT',
      body: {
        name: payload.name.trim(),
        sku: payload.sku.trim(),
        category: payload.category.trim(),
        price: Number(payload.price.toFixed(2)),
        stock: payload.stock,
        status: payload.status
      }
    })

    await router.push('/products')
  } catch (error) {
    handleError(error)
  } finally {
    saving.value = false
  }
}

const handleError = (error: unknown) => {
  if (isFetchError(error)) {
    errorMessage.value = error.data?.message || error.statusMessage || '操作失败，请稍后重试'
  } else {
    errorMessage.value = '操作失败，请稍后重试'
  }
}

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="编辑商品"
        description="更新商品的核心信息。"
        :links="[
          {
            label: '返回主界面',
            icon: 'i-lucide-home',
            to: '/dashboard',
            color: 'neutral',
            variant: 'ghost'
          },
          {
            label: '返回商品列表',
            icon: 'i-lucide-arrow-left',
            to: '/products',
            color: 'primary'
          }
        ]"
      />

      <UCard>
      <template #header>
        <div class="flex items-center justify-between">
          <div>
            <h2 class="text-base font-semibold">商品信息</h2>
            <p class="text-sm text-muted">编辑后保存即可生效。</p>
          </div>
          <UButton icon="i-lucide-refresh-cw" variant="ghost" :loading="loading" @click="fetchProduct">
            重新加载
          </UButton>
        </div>
      </template>

      <UForm :state="state" class="space-y-6" @submit="onSubmit">
        <div class="grid gap-4 md:grid-cols-2">
          <UFormField label="商品名称" name="name" required>
            <p class="mb-1 text-xs text-muted">示例：星辰蓝牙耳机；建议 10-20 个字，方便用户识别。</p>
            <UInput v-model="state.name" placeholder="例：星辰蓝牙耳机" />
          </UFormField>
          <UFormField label="商品 SKU" name="sku" required>
            <p class="mb-1 text-xs text-muted">示例：SC-AIR-01；建议遵循品牌-品类-序号的格式。</p>
            <UInput v-model="state.sku" placeholder="例：SC-AIR-01" />
          </UFormField>
          <UFormField label="商品分类" name="category" required class="md:col-span-2">
            <p class="mb-1 text-xs text-muted">示例：数码影音；分类用于前台筛选展示。</p>
            <UInput v-model="state.category" placeholder="例：数码影音" />
          </UFormField>
        </div>

        <div class="grid gap-4 md:grid-cols-3">
          <UFormField label="销售价 (元)" name="price" required>
            <p class="mb-1 text-xs text-muted">示例：199.00；系统会保存为两位小数。</p>
            <UInput v-model.number="state.price" type="number" min="0" step="0.01" />
          </UFormField>
          <UFormField label="库存数量" name="stock" required>
            <p class="mb-1 text-xs text-muted">示例：50；若暂未备货，可先填写 0。</p>
            <UInput v-model.number="state.stock" type="number" min="0" step="1" />
          </UFormField>
          <UFormField label="商品状态" name="status" required>
            <p class="mb-1 text-xs text-muted">请选择商品当前所处阶段。</p>
            <USelect
              v-model="state.status"
              :items="statusOptions"
              placeholder="请选择商品状态"
              value-key="value"
            />
          </UFormField>
        </div>

        <UAlert
          v-if="errorMessage"
          color="error"
          variant="soft"
          icon="i-lucide-alert-circle"
          :title="errorMessage"
        />

        <div class="flex justify-end gap-3">
          <UButton color="neutral" variant="ghost" to="/products">取消</UButton>
          <UButton type="submit" :loading="saving" icon="i-lucide-save">保存修改</UButton>
        </div>
      </UForm>
      </UCard>
    </div>
  </div>
</template>
