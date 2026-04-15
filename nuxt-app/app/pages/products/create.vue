<script setup lang="ts">
import type { FormSubmitEvent } from '#ui/types'
import type { FetchError } from 'ofetch'
import type { SelectItem } from '@nuxt/ui'

useSeoMeta({
  title: '新增商品 - 控制台',
  description: '创建星辰商城的新商品，填写必要的基础信息。'
})

type ProductStatus = 'DRAFT' | 'ACTIVE' | 'INACTIVE'

type FormState = {
  name: string
  sku: string
  category: string
  price: number | null
  stock: number | null
  status: ProductStatus
}

const router = useRouter()
const config = useRuntimeConfig()
const apiBase = config.public.apiBase

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
  category: '',
  price: null,
  stock: 0,
  status: 'DRAFT'
})

const isSaving = ref(false)
const errorMessage = ref('')
const showValidation = ref(false)

const onSubmit = async (event: FormSubmitEvent<FormState>) => {
  if (isSaving.value) {
    return
  }

  showValidation.value = true
  errorMessage.value = ''
  const payload = event.data

  const nameValid = !!payload.name.trim()
  const skuValid = !!payload.sku.trim()
  const categoryValid = !!payload.category.trim()
  const priceValid = payload.price !== null && payload.price > 0
  const stockValid = payload.stock !== null && payload.stock >= 0
  const statusValid = !!payload.status

  if (!nameValid || !skuValid || !categoryValid || !priceValid || !stockValid || !statusValid) {
    errorMessage.value = '请检查表单必填项'
    return
  }

  const name = payload.name.trim()
  const sku = payload.sku.trim()
  const category = payload.category.trim()
  const price = Number((payload.price as number).toFixed(2))
  const stock = payload.stock as number

  isSaving.value = true

  try {
    await $fetch(`${apiBase}/api/admin/products`, {
      method: 'POST',
      body: {
        name,
        sku,
        category,
        price,
        stock,
        status: payload.status
      }
    })

    await router.push('/products')
  } catch (error) {
    handleError(error)
  } finally {
    isSaving.value = false
  }
}

function handleError(error: unknown) {
  if (isFetchError(error)) {
    errorMessage.value = error.data?.message || error.statusMessage || '保存失败，请稍后重试'
  } else {
    errorMessage.value = '保存失败，请稍后重试'
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
        title="新增商品"
        description="仅需填写基础字段，即可将商品加入系统。"
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

      <UForm :state="state" class="space-y-6" @submit="onSubmit">
      <UCard>
        <template #header>
          <div>
            <h2 class="text-base font-semibold">基础信息</h2>
            <p class="text-sm text-muted">填写商品名称与 SKU，确保前后台一致。</p>
          </div>
        </template>

        <div class="grid gap-4 md:grid-cols-2">
          <UFormField
            label="商品名称"
            name="name"
            required
            help="请输入商品名称"
            :error="showValidation && !state.name.trim() ? '请填写商品名称' : undefined"
          >
            <p class="mb-1 text-xs text-muted">示例：星辰蓝牙耳机；建议 10-20 个字，方便用户识别。</p>
            <UInput v-model="state.name" placeholder="例：星辰蓝牙耳机" />
          </UFormField>
          <UFormField
            label="商品 SKU"
            name="sku"
            required
            help="请输入唯一的 SKU 编码"
            :error="showValidation && !state.sku.trim() ? '请填写商品 SKU' : undefined"
          >
            <p class="mb-1 text-xs text-muted">示例：SC-AIR-01；建议遵循品牌-品类-序号的格式。</p>
            <UInput v-model="state.sku" placeholder="例：SC-AIR-01" />
          </UFormField>
          <UFormField
            label="商品分类"
            name="category"
            required
            help="请输入商品所在分类"
            :error="showValidation && !state.category.trim() ? '请填写商品分类' : undefined"
            class="md:col-span-2"
          >
            <p class="mb-1 text-xs text-muted">示例：数码影音；分类用于前台筛选展示。</p>
            <UInput v-model="state.category" placeholder="例：数码影音" />
          </UFormField>
        </div>
      </UCard>

      <UCard>
        <template #header>
          <div>
            <h2 class="text-base font-semibold">价格与库存</h2>
            <p class="text-sm text-muted">确保价格为 2 位小数，库存为非负整数。</p>
          </div>
        </template>

        <div class="grid gap-4 md:grid-cols-3">
          <UFormField
            label="销售价 (元)"
            name="price"
            required
            help="请输入大于 0 的售价"
            :error="showValidation && !(state.price !== null && state.price > 0) ? '请输入有效的销售价格' : undefined"
          >
            <p class="mb-1 text-xs text-muted">示例：199.00；系统会保存为两位小数。</p>
            <UInput v-model.number="state.price" type="number" min="0" step="0.01" />
          </UFormField>
          <UFormField
            label="库存数量"
            name="stock"
            required
            help="请输入非负整数的库存数量"
            :error="showValidation && !(state.stock !== null && state.stock >= 0) ? '库存数量不能为负数' : undefined"
          >
            <p class="mb-1 text-xs text-muted">示例：50；若暂未备货，可先填写 0。</p>
            <UInput v-model.number="state.stock" type="number" min="0" step="1" />
          </UFormField>
          <UFormField
            label="商品状态"
            name="status"
            required
            help="草稿：仅内部可见；上架：立即对外展示；下架：暂时隐藏"
            :error="showValidation && !state.status ? '请选择商品状态' : undefined"
          >
            <p class="mb-1 text-xs text-muted">请选择商品当前所处阶段。</p>
            <USelect v-model="state.status" :items="statusOptions" placeholder="请选择商品状态" value-key="value" />
          </UFormField>
        </div>
      </UCard>

      <div class="space-y-3">
        <UAlert
          v-if="errorMessage"
          color="error"
          variant="soft"
          icon="i-lucide-alert-circle"
          :title="errorMessage"
        />

        <div class="flex justify-end gap-3">
          <UButton color="neutral" variant="ghost" to="/products">取消</UButton>
          <UButton type="submit" :loading="isSaving" icon="i-lucide-save">保存商品</UButton>
        </div>
      </div>
      </UForm>
    </div>
  </div>
</template>
