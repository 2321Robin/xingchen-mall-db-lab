<script setup lang="ts">
import type { FetchError } from 'ofetch'
import { computed, onBeforeMount, onMounted, onBeforeUnmount, reactive, ref, watch } from 'vue'
import { useDateFormat } from '@vueuse/core'
import type { TableColumn } from '#ui/types'

useSeoMeta({
  title: '收货地址管理 - 星辰商城',
  description: '管理您的收货地址列表，支持新增、编辑、删除以及设置默认地址。'
})

type CurrentUser = {
  userId: number
}

type AddressResponse = {
  id: number
  recipientName: string
  phone: string
  province: string
  city: string
  district: string
  street: string
  postalCode: string | null
  isDefault: boolean
  createdAt: string
  updatedAt: string
}

type AddressRow = AddressResponse & { fullAddress: string }

type AddressFormState = {
  recipientName: string
  phone: string
  province: string
  city: string
  district: string
  street: string
  postalCode: string
  isDefault: boolean
}

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const router = useRouter()
const currentUser = useState<CurrentUser | null>('currentUser', () => null)

const addresses = ref<AddressResponse[]>([])
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const submitting = ref(false)
const modalOpen = ref(false)
const modalMode = ref<'create' | 'edit' | null>(null)
const editingId = ref<number | null>(null)
const modalError = ref('')

const formState = reactive<AddressFormState>({
  recipientName: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  street: '',
  postalCode: '',
  isDefault: false
})

const fieldRowClass = 'flex flex-col gap-2 md:flex-row md:items-center md:gap-4'
const fieldLabelClass = 'min-w-[88px] text-sm font-medium text-muted md:text-right'
const addressFieldIds = {
  recipientName: 'address-recipient-name',
  phone: 'address-phone',
  province: 'address-province',
  city: 'address-city',
  district: 'address-district',
  street: 'address-street',
  postalCode: 'address-postal-code',
  isDefault: 'address-is-default'
} as const

const tableRows = computed<AddressRow[]>(() => addresses.value.map(item => ({
  ...item,
  fullAddress: `${item.province}${item.city}${item.district}${item.street}`
})))

const columns: TableColumn<AddressRow>[] = [
  { accessorKey: 'recipientName', header: '收货人' },
  { accessorKey: 'phone', header: '手机号' },
  { accessorKey: 'fullAddress', header: '详细地址' },
  { accessorKey: 'isDefault', header: '默认地址' },
  { accessorKey: 'updatedAt', header: '最近更新' },
  { id: 'actions', header: '操作' }
]

const formatDate = (value: string) => useDateFormat(value, 'YYYY-MM-DD HH:mm').value

const resetForm = () => {
  formState.recipientName = ''
  formState.phone = ''
  formState.province = ''
  formState.city = ''
  formState.district = ''
  formState.street = ''
  formState.postalCode = ''
  formState.isDefault = false
  modalError.value = ''
}

const populateForm = (address: AddressResponse) => {
  formState.recipientName = address.recipientName
  formState.phone = address.phone
  formState.province = address.province
  formState.city = address.city
  formState.district = address.district
  formState.street = address.street
  formState.postalCode = address.postalCode ?? ''
  formState.isDefault = address.isDefault
  modalError.value = ''
}

const fetchAddresses = async () => {
  if (!currentUser.value) {
    return
  }

  loading.value = true
  errorMessage.value = ''

  try {
    const data = await $fetch<AddressResponse[]>(`${apiBase}/api/user/addresses/${currentUser.value.userId}`)
    addresses.value = data
  } catch (error) {
    handlePageError(error)
  } finally {
    loading.value = false
  }
}

onBeforeMount(() => {
  if (!currentUser.value) {
    router.push('/')
    return
  }
})

onMounted(fetchAddresses)

const openCreate = () => {
  modalMode.value = 'create'
  editingId.value = null
  resetForm()
  modalOpen.value = true
}

const openEdit = (address: AddressResponse) => {
  modalMode.value = 'edit'
  editingId.value = address.id
  populateForm(address)
  modalOpen.value = true
}

const closeModal = () => {
  modalOpen.value = false
}

const modalTitle = computed(() => (modalMode.value === 'edit' ? '编辑收货地址' : '新增收货地址'))
const modalDescription = computed(() => (modalMode.value === 'edit'
  ? '更新联系人和配送信息，已设置的默认地址将保持同步。'
  : '填写完整的联系人与配送信息，确保快递准确送达。'))

const validateForm = () => {
  if (!formState.recipientName.trim()) {
    modalError.value = '请输入收货人姓名'
    return false
  }

  if (!/^1[3-9]\d{9}$/.test(formState.phone.trim())) {
    modalError.value = '请输入 11 位中国大陆手机号'
    return false
  }

  if (!formState.province.trim() || !formState.city.trim() || !formState.district.trim()) {
    modalError.value = '请选择完整的省市区信息'
    return false
  }

  if (!formState.street.trim()) {
    modalError.value = '请输入详细地址信息'
    return false
  }

  if (formState.postalCode && !/^\d{4,6}$/.test(formState.postalCode.trim())) {
    modalError.value = '邮政编码格式有误，请输入 4-6 位数字'
    return false
  }

  modalError.value = ''
  return true
}

const handleSubmit = async () => {
  if (!currentUser.value || submitting.value) {
    return
  }

  if (!validateForm()) {
    return
  }

  submitting.value = true
  successMessage.value = ''

  const payload = {
    recipientName: formState.recipientName.trim(),
    phone: formState.phone.trim(),
    province: formState.province.trim(),
    city: formState.city.trim(),
    district: formState.district.trim(),
    street: formState.street.trim(),
    postalCode: formState.postalCode.trim() || null,
    isDefault: formState.isDefault
  }

  try {
    if (modalMode.value === 'edit' && editingId.value !== null) {
      await $fetch<AddressResponse>(`${apiBase}/api/user/addresses/${currentUser.value.userId}/${editingId.value}`, {
        method: 'PUT',
        body: payload
      })
      successMessage.value = '收货地址更新成功'
    } else {
      await $fetch<AddressResponse>(`${apiBase}/api/user/addresses/${currentUser.value.userId}`, {
        method: 'POST',
        body: payload
      })
      successMessage.value = '收货地址创建成功'
    }

    await fetchAddresses()
    closeModal()
  } catch (error) {
    handleModalError(error)
  } finally {
    submitting.value = false
  }
}

const handleDelete = async (address: AddressResponse) => {
  if (!currentUser.value || submitting.value) {
    return
  }

  const confirmed = window.confirm(`确认删除收货地址：${address.recipientName} ${address.phone}?`)
  if (!confirmed) {
    return
  }

  submitting.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    await $fetch(`${apiBase}/api/user/addresses/${currentUser.value.userId}/${address.id}`, {
      method: 'DELETE'
    })
    successMessage.value = '收货地址删除成功'
    await fetchAddresses()
  } catch (error) {
    handlePageError(error)
  } finally {
    submitting.value = false
  }
}

const handleSetDefault = async (address: AddressResponse) => {
  if (!currentUser.value || submitting.value || address.isDefault) {
    return
  }

  submitting.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    await $fetch<AddressResponse>(`${apiBase}/api/user/addresses/${currentUser.value.userId}/${address.id}/default`, {
      method: 'POST'
    })
    successMessage.value = '默认收货地址已更新'
    await fetchAddresses()
  } catch (error) {
    handlePageError(error)
  } finally {
    submitting.value = false
  }
}

const handlePageError = (error: unknown) => {
  if (isFetchError(error)) {
    errorMessage.value = error.data?.message || error.statusMessage || '操作失败，请稍后重试'
  } else {
    errorMessage.value = '操作失败，请稍后重试'
  }
}

const handleModalError = (error: unknown) => {
  if (isFetchError(error)) {
    modalError.value = error.data?.message || error.statusMessage || '操作失败，请稍后重试'
  } else {
    modalError.value = '操作失败，请稍后重试'
  }
}

let modalResetTimer: ReturnType<typeof setTimeout> | null = null

watch(modalOpen, (open) => {
  if (!open) {
    if (modalResetTimer) {
      clearTimeout(modalResetTimer)
    }
    modalResetTimer = setTimeout(() => {
      if (modalOpen.value) {
        return
      }
      modalMode.value = null
      editingId.value = null
      resetForm()
      modalError.value = ''
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
    modalResetTimer = null
  }
})

function isFetchError(error: unknown): error is FetchError<{ message?: string }> {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="收货地址管理"
        description="维护您的收货地址，用于下单时快速选择配送信息。"
        :links="[
          {
            label: '返回主界面',
            icon: 'i-lucide-home',
            to: '/',
            color: 'neutral',
            variant: 'ghost'
          }
        ]"
      />
      <UCard :loading="loading">
      <template #header>
        <div class="flex items-center justify-between">
          <div>
            <h2 class="text-base font-semibold">地址列表</h2>
            <p class="text-sm text-muted">共 {{ addresses.length }} 个收货地址，默认地址将用于优先配送。</p>
          </div>
          <UButton icon="i-lucide-plus" :disabled="submitting" @click="openCreate">
            新增地址
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
        <UAlert
          v-else-if="successMessage"
          color="success"
          variant="soft"
          icon="i-lucide-check-circle"
          :title="successMessage"
        />

        <UTable :data="tableRows" :columns="columns" :loading="loading">
          <template #fullAddress-cell="{ row }">
            <div class="space-y-1">
              <p>{{ row.original.province }} {{ row.original.city }} {{ row.original.district }}</p>
              <p class="text-sm text-muted">{{ row.original.street }}</p>
              <p v-if="row.original.postalCode" class="text-xs text-muted">邮编：{{ row.original.postalCode }}</p>
            </div>
          </template>

          <template #isDefault-cell="{ row }">
            <UBadge :color="row.original.isDefault ? 'success' : 'neutral'" variant="soft">
              {{ row.original.isDefault ? '默认地址' : '普通地址' }}
            </UBadge>
          </template>

          <template #updatedAt-cell="{ row }">
            {{ formatDate(row.original.updatedAt) }}
          </template>

          <template #actions-cell="{ row }">
            <div class="flex items-center gap-2">
              <UButton
                size="xs"
                color="primary"
                variant="soft"
                :icon="row.original.isDefault ? 'i-lucide-badge-check' : 'i-lucide-check-circle'"
                :disabled="row.original.isDefault || submitting"
                @click="handleSetDefault(row.original)"
              >
                {{ row.original.isDefault ? '默认' : '设为默认' }}
              </UButton>
              <UButton
                size="xs"
                color="neutral"
                variant="soft"
                icon="i-lucide-pencil"
                :disabled="submitting"
                @click="openEdit(row.original)"
              >
                编辑
              </UButton>
              <UButton
                size="xs"
                color="error"
                variant="soft"
                icon="i-lucide-trash-2"
                :loading="submitting"
                @click="handleDelete(row.original)"
              >
                删除
              </UButton>
            </div>
          </template>
        </UTable>
      </div>
      </UCard>

      <UModal
      v-if="modalMode"
      v-model="modalOpen"
      :aria-labelledby="'address-modal-title'"
      :aria-describedby="'address-modal-description'"
      :ui="{ content: 'sm:max-w-xl' }"
    >
      <div id="address-modal-title" class="sr-only">{{ modalTitle }}</div>
      <div id="address-modal-description" class="sr-only">{{ modalDescription }}</div>
      <UCard>
        <template #header>
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-lg font-semibold">{{ modalTitle }}</h3>
              <p class="text-sm text-muted">{{ modalDescription }}</p>
            </div>
            <UButton variant="ghost" icon="i-lucide-x" @click="closeModal" />
          </div>
        </template>

        <UForm :state="formState" class="space-y-5" @submit.prevent="handleSubmit">
          <div class="grid gap-5 md:grid-cols-2">
            <div :class="fieldRowClass">
              <label :for="addressFieldIds.recipientName" :class="fieldLabelClass">
                收货人姓名<span class="ml-1 text-error">*</span>：
              </label>
              <UInput
                :id="addressFieldIds.recipientName"
                v-model="formState.recipientName"
                placeholder="请输入收货人姓名"
                class="md:flex-1"
              />
            </div>

            <div :class="fieldRowClass">
              <label :for="addressFieldIds.phone" :class="fieldLabelClass">
                手机号<span class="ml-1 text-error">*</span>：
              </label>
              <UInput
                :id="addressFieldIds.phone"
                v-model="formState.phone"
                placeholder="请输入 11 位手机号"
                inputmode="numeric"
                class="md:flex-1"
              />
            </div>
          </div>

          <div class="grid gap-5 md:grid-cols-3">
            <div :class="fieldRowClass">
              <label :for="addressFieldIds.province" :class="fieldLabelClass">
                省份<span class="ml-1 text-error">*</span>：
              </label>
              <UInput
                :id="addressFieldIds.province"
                v-model="formState.province"
                placeholder="如：广东省"
                class="md:flex-1"
              />
            </div>
            <div :class="fieldRowClass">
              <label :for="addressFieldIds.city" :class="fieldLabelClass">
                城市<span class="ml-1 text-error">*</span>：
              </label>
              <UInput
                :id="addressFieldIds.city"
                v-model="formState.city"
                placeholder="如：广州市"
                class="md:flex-1"
              />
            </div>
            <div :class="fieldRowClass">
              <label :for="addressFieldIds.district" :class="fieldLabelClass">
                区/县<span class="ml-1 text-error">*</span>：
              </label>
              <UInput
                :id="addressFieldIds.district"
                v-model="formState.district"
                placeholder="如：天河区"
                class="md:flex-1"
              />
            </div>
          </div>

          <div :class="fieldRowClass">
            <label :for="addressFieldIds.street" :class="fieldLabelClass">
              详细地址<span class="ml-1 text-error">*</span>：
            </label>
            <UTextarea
              :id="addressFieldIds.street"
              v-model="formState.street"
              placeholder="街道、门牌号等详细信息"
              :rows="3"
              class="md:flex-1"
            />
          </div>

          <div class="grid gap-5 md:grid-cols-2">
            <div :class="fieldRowClass">
              <label :for="addressFieldIds.postalCode" :class="fieldLabelClass">
                邮政编码：
              </label>
              <UInput
                :id="addressFieldIds.postalCode"
                v-model="formState.postalCode"
                placeholder="可选，4-6 位数字"
                inputmode="numeric"
                class="md:flex-1"
              />
            </div>
          </div>

          <UAlert
            v-if="modalError"
            color="error"
            variant="soft"
            icon="i-lucide-alert-circle"
            :title="modalError"
          />

          <div class="flex justify-end gap-3">
            <UButton color="neutral" variant="ghost" :disabled="submitting" @click="closeModal">
              取消
            </UButton>
            <UButton type="submit" :loading="submitting">
              {{ modalMode === 'edit' ? '保存修改' : '确认创建' }}
            </UButton>
          </div>
        </UForm>
      </UCard>
    </UModal>
    </div>
  </div>
</template>
