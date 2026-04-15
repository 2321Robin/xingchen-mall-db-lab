<script setup lang="ts">
import type { FormSubmitEvent } from '#ui/types'
import type { FetchError } from 'ofetch'

useSeoMeta({
  title: '修改密码 - 控制台',
  description: '管理员可在此更新登录密码，保障账户安全。'
})

type FormState = {
  oldPassword: string
  newPassword: string
  confirmPassword: string
}

const router = useRouter()
const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const currentUser = useState<{ username?: string, role?: string } | null>('currentUser', () => null)

onBeforeMount(() => {
  if (!currentUser.value) {
    router.push('/')
  }
})

const state = reactive<FormState>({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const submitting = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const fieldRowClass = 'flex flex-col gap-2 md:flex-row md:items-center md:gap-4'
const fieldLabelClass = 'min-w-[96px] text-sm font-medium text-muted md:text-right'
const fieldIds = {
  oldPassword: 'password-old',
  newPassword: 'password-new',
  confirmPassword: 'password-confirm'
} as const

const onSubmit = async (event: FormSubmitEvent<FormState>) => {
  if (submitting.value) {
    return
  }

  errorMessage.value = ''
  successMessage.value = ''

  const data = event.data

  if (!data.oldPassword || !data.newPassword) {
    errorMessage.value = '请填写完整的密码信息'
    return
  }

  if (data.newPassword.length < 6) {
    errorMessage.value = '新密码长度至少为 6 位'
    return
  }

  if (data.newPassword !== data.confirmPassword) {
    errorMessage.value = '两次输入的新密码不一致'
    return
  }

  if (!currentUser.value?.username) {
    errorMessage.value = '当前会话已失效，请重新登录'
    return
  }

  submitting.value = true

  try {
    await $fetch(`${apiBase}/api/auth/password`, {
      method: 'PUT',
      body: {
        username: currentUser.value.username,
        oldPassword: data.oldPassword,
        newPassword: data.newPassword
      }
    })

    successMessage.value = '密码修改成功'
    state.oldPassword = ''
    state.newPassword = ''
    state.confirmPassword = ''
  } catch (error) {
    handleError(error)
  } finally {
    submitting.value = false
  }
}

const handleError = (error: unknown) => {
  if (isFetchError(error)) {
    errorMessage.value = error.data?.message || error.statusMessage || '修改失败，请稍后重试'
  } else {
    errorMessage.value = '修改失败，请稍后重试'
  }
}

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}
</script>

<template>
  <div class="py-12">
    <div class="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-center">
        <UCard class="w-full max-w-xl">
      <template #header>
        <div>
          <h1 class="text-xl font-semibold">修改密码</h1>
          <p class="text-sm text-muted">使用旧密码验证身份，并设置一个新的登录密码。</p>
        </div>
      </template>

      <UForm :state="state" class="space-y-5" @submit="onSubmit">
        <div class="space-y-5">
          <div :class="fieldRowClass">
            <label :for="fieldIds.oldPassword" :class="fieldLabelClass">
              旧密码<span class="ml-1 text-error">*</span>：
            </label>
            <UInput
              :id="fieldIds.oldPassword"
              v-model="state.oldPassword"
              type="password"
              placeholder="请输入旧密码"
              autocomplete="current-password"
              size="lg"
              class="md:flex-1"
            />
          </div>

          <div :class="fieldRowClass">
            <label :for="fieldIds.newPassword" :class="fieldLabelClass">
              新密码<span class="ml-1 text-error">*</span>：
            </label>
            <UInput
              :id="fieldIds.newPassword"
              v-model="state.newPassword"
              type="password"
              placeholder="请输入新密码，至少 6 位"
              autocomplete="new-password"
              size="lg"
              class="md:flex-1"
            />
          </div>

          <div :class="fieldRowClass">
            <label :for="fieldIds.confirmPassword" :class="fieldLabelClass">
              确认新密码<span class="ml-1 text-error">*</span>：
            </label>
            <UInput
              :id="fieldIds.confirmPassword"
              v-model="state.confirmPassword"
              type="password"
              placeholder="再次输入新密码"
              autocomplete="new-password"
              size="lg"
              class="md:flex-1"
            />
          </div>
        </div>

        <transition name="fade" mode="out-in">
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
        </transition>

        <div class="flex justify-end gap-3">
          <UButton color="neutral" variant="ghost" to="/dashboard">返回主界面</UButton>
          <UButton type="submit" :loading="submitting" icon="i-lucide-save">确认修改</UButton>
        </div>
      </UForm>
        </UCard>
      </div>
    </div>
  </div>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
