<script setup lang="ts">
import { computed, onBeforeMount, reactive, ref } from 'vue'
import type { FetchError } from 'ofetch'

useSeoMeta({
  title: '个人资料 - 星辰商城',
  description: '查看并更新您的账户昵称与联系方式。'
})

type CurrentUser = {
  userId: number
  username: string
  role: string
  email: string
  message?: string
}

type ProfileResponse = {
  id: number
  username: string
  email: string
  phone: string | null
  role: string
  active: boolean
  createdAt: string
  updatedAt: string
}

type ProfileState = {
  username: string
  email: string
  phone: string
}

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const router = useRouter()
const currentUser = useState<CurrentUser | null>('currentUser', () => null)

const state = reactive<ProfileState>({
  username: '',
  email: '',
  phone: ''
})

const originalProfile = ref<ProfileResponse | null>(null)
const loading = ref(false)
const saving = ref(false)
const formError = ref('')
const successMessage = ref('')
const fieldRowClass = 'flex flex-col gap-2 md:flex-row md:items-center md:gap-4'
const fieldLabelClass = 'min-w-[88px] text-sm font-medium text-muted md:text-right'
const profileFieldIds = {
  username: 'profile-username',
  email: 'profile-email',
  phone: 'profile-phone'
} as const

const hasChanges = computed(() => {
  if (!originalProfile.value) {
    return false
  }

  return (
    state.username.trim() !== (originalProfile.value.username ?? '')
    || state.email.trim().toLowerCase() !== (originalProfile.value.email ?? '').toLowerCase()
    || state.phone.trim() !== (originalProfile.value.phone ?? '')
  )
})

const validateEmail = (email: string) => {
  const pattern = /^(?:[a-z0-9_.+-])+@(?:[a-z0-9-]+\.)+[a-z]{2,}$/i
  return pattern.test(email)
}

const validatePhone = (phone: string) => {
  if (!phone.trim()) {
    return true
  }
  const pattern = /^1[3-9]\d{9}$/
  return pattern.test(phone.trim())
}

const fetchProfile = async () => {
  if (!currentUser.value) {
    return
  }

  loading.value = true
  formError.value = ''
  successMessage.value = ''

  try {
    const data = await $fetch<ProfileResponse>(`${apiBase}/api/user/profile/${currentUser.value.userId}`)
    originalProfile.value = data
    state.username = data.username
    state.email = data.email
    state.phone = data.phone ?? ''
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
  }
}

onBeforeMount(() => {
  if (!currentUser.value) {
    router.push('/')
    return
  }

  fetchProfile()
})

const handleSubmit = async () => {
  if (!currentUser.value || saving.value) {
    return
  }

  formError.value = ''
  successMessage.value = ''

  const username = state.username.trim()
  const email = state.email.trim()
  const phone = state.phone.trim()

  if (!username) {
    formError.value = '请输入昵称'
    return
  }

  if (!validateEmail(email)) {
    formError.value = '请输入正确的邮箱地址'
    return
  }

  if (!validatePhone(phone)) {
    formError.value = '请输入 11 位中国大陆手机号'
    return
  }

  saving.value = true

  try {
    const response = await $fetch<ProfileResponse>(`${apiBase}/api/user/profile/${currentUser.value.userId}`, {
      method: 'PUT',
      body: {
        username,
        email,
        phone
      }
    })

    originalProfile.value = response
    state.username = response.username
    state.email = response.email
    state.phone = response.phone ?? ''
    successMessage.value = '个人资料更新成功'

    currentUser.value = {
      ...currentUser.value,
      username: response.username,
      email: response.email
    }
  } catch (error) {
    handleError(error)
  } finally {
    saving.value = false
  }
}

const resetForm = () => {
  if (!originalProfile.value) {
    return
  }

  state.username = originalProfile.value.username
  state.email = originalProfile.value.email
  state.phone = originalProfile.value.phone ?? ''
  formError.value = ''
  successMessage.value = ''
}

function handleError(error: unknown) {
  if (isFetchError(error)) {
    const fetchError = error as FetchError<{ message?: string }>
    formError.value = fetchError.data?.message || fetchError.statusMessage || '操作失败，请稍后重试'
  } else {
    formError.value = '操作失败，请稍后重试'
  }
  successMessage.value = ''
}

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="个人资料"
        description="维护您的账户昵称和联系方式，以便接收通知与订单更新。"
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
              <h2 class="text-base font-semibold">基本信息</h2>
              <p class="text-sm text-muted">修改后将同步至登录记录及通知邮箱。</p>
            </div>
            <div class="flex items-center gap-3">
              <UButton
                color="neutral"
                variant="ghost"
                icon="i-lucide-rotate-ccw"
                :disabled="!hasChanges || saving"
                @click="resetForm"
              >
                重置
              </UButton>
              <UButton
                color="primary"
                icon="i-lucide-save"
                :disabled="!hasChanges"
                :loading="saving"
                @click="handleSubmit"
              >
                保存修改
              </UButton>
            </div>
          </div>
        </template>

        <div class="space-y-6">
          <UAlert
            v-if="formError"
            color="error"
            variant="soft"
            icon="i-lucide-alert-circle"
            :title="formError"
          />
          <UAlert
            v-else-if="successMessage"
            color="success"
            variant="soft"
            icon="i-lucide-check-circle"
            :title="successMessage"
          />

          <UForm :state="state" class="space-y-6" @submit.prevent="handleSubmit">
            <div class="grid gap-6 md:grid-cols-2">
              <div :class="fieldRowClass">
                <label :for="profileFieldIds.username" :class="fieldLabelClass">
                  昵称<span class="ml-1 text-error">*</span>：
                </label>
                <UInput
                  :id="profileFieldIds.username"
                  v-model="state.username"
                  size="lg"
                  icon="i-lucide-user"
                  autocomplete="name"
                  placeholder="请输入昵称"
                  class="md:flex-1"
                />
              </div>

              <div :class="fieldRowClass">
                <label :for="profileFieldIds.email" :class="fieldLabelClass">
                  联系邮箱<span class="ml-1 text-error">*</span>：
                </label>
                <UInput
                  :id="profileFieldIds.email"
                  v-model="state.email"
                  size="lg"
                  type="email"
                  icon="i-lucide-mail"
                  autocomplete="email"
                  placeholder="请输入联系邮箱"
                  class="md:flex-1"
                />
              </div>
            </div>

            <div :class="fieldRowClass">
              <label :for="profileFieldIds.phone" :class="fieldLabelClass">
                手机号码：
              </label>
              <UInput
                :id="profileFieldIds.phone"
                v-model="state.phone"
                size="lg"
                icon="i-lucide-phone"
                inputmode="numeric"
                autocomplete="tel"
                placeholder="请输入 11 位手机号，可留空"
                class="md:flex-1"
              />
            </div>
          </UForm>
        </div>
      </UCard>
    </div>
  </div>
</template>
