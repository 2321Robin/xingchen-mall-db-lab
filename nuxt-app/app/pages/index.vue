<script setup lang="ts">
import { watch } from 'vue'
import type { FormSubmitEvent } from '#ui/types'
import type { FetchError } from 'ofetch'

useSeoMeta({
  title: '登录 - 星辰商城',
  description: '登录星辰商城，管理订单、商品与个人账户。'
})

type LoginResponse = {
  userId: number
  username: string
  role: string
  email: string
  message: string
}

const config = useRuntimeConfig()
const apiBase = config.public.apiBase

const state = reactive({
  account: '',
  password: '',
  rememberMe: false
})

const isSubmitting = ref(false)
const formError = ref('')
const success = ref(false)
const successMessage = ref('')
const showPassword = ref(false)
const currentUser = useState<LoginResponse | null>('currentUser', () => null)

if (import.meta.client) {
  watch(currentUser, (user) => {
    if (user) {
      navigateTo('/dashboard', { replace: true })
    }
  }, { immediate: true })
}

const onSubmit = async (event: FormSubmitEvent<typeof state>) => {
  if (isSubmitting.value) {
    return
  }

  formError.value = ''
  success.value = false
  successMessage.value = ''

  const { account, password } = event.data

  if (!account || !password) {
    formError.value = '请输入账号和密码'
    return
  }

  if (password.length < 6) {
    formError.value = '密码长度至少为 6 位'
    return
  }

  isSubmitting.value = true

  try {
    const response = await $fetch<LoginResponse>(`${apiBase}/api/auth/login`, {
      method: 'POST',
      body: {
        account,
        password
      }
    })

    success.value = true
    successMessage.value = response.message || '登录成功'
    currentUser.value = response

    await navigateTo('/dashboard')
  } catch (error) {
    handleError(error)
  } finally {
    isSubmitting.value = false
  }
}

function handleError(error: unknown) {
  if (isFetchError(error)) {
    const fetchError = error as FetchError<{ message?: string }>
    formError.value = fetchError.data?.message || fetchError.statusMessage || '登录失败，请稍后再试'
  } else {
    formError.value = '登录失败，请稍后再试'
  }
  success.value = false
}

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}
</script>

<template>
  <div class="flex items-center justify-center py-12 sm:py-16">
    <div class="w-full max-w-3xl space-y-10 px-4 sm:px-6">
      <div class="space-y-6 text-center">
        <div class="space-y-2">
          <UBadge color="primary" variant="soft">星辰商城 · B2C</UBadge>
          <h1 class="text-3xl font-semibold tracking-tight sm:text-4xl">
            欢迎登录商家管理中心
          </h1>
          <p class="text-muted">
            管理商品与订单，关注用户反馈，打造高效的线上零售体验。管理员与普通用户均可使用本账号中心登录。
          </p>
        </div>
      </div>

      <UCard class="mx-auto w-full max-w-xl">
        <template #header>
          <div class="space-y-2">
            <h2 class="text-xl font-semibold">账号登录</h2>
            <p class="text-sm text-muted">使用您的手机号、邮箱或管理员账号登录平台。</p>
          </div>
        </template>

        <UForm :state="state" class="space-y-6" @submit="onSubmit">
          <div class="space-y-4">
            <UFormGroup label="账号" name="account" required>
              <UInput
                v-model="state.account"
                size="lg"
                icon="i-lucide-user"
                autocomplete="username"
                placeholder="请输入手机号 / 邮箱 / 账号"
                class="w-full"
              />
            </UFormGroup>

            <UFormGroup label="密码" name="password" required>
              <UInput
                v-model="state.password"
                :type="showPassword ? 'text' : 'password'"
                size="lg"
                icon="i-lucide-lock"
                autocomplete="current-password"
                placeholder="请输入密码"
                class="w-full"
              >
                <template #trailing>
                  <UButton
                    variant="ghost"
                    color="neutral"
                    size="xs"
                    class="flex h-8 w-8 items-center justify-center p-0"
                    :aria-label="showPassword ? '隐藏密码' : '显示密码'"
                    @click.stop="showPassword = !showPassword"
                  >
                    <UIcon :name="showPassword ? 'i-lucide-eye-off' : 'i-lucide-eye'" />
                  </UButton>
                </template>
              </UInput>
            </UFormGroup>

            <div class="flex items-center justify-between">
              <UCheckbox v-model="state.rememberMe" label="记住登录状态" />
              <NuxtLink class="text-sm font-medium text-primary" to="/forgot-password">
                忘记密码？
              </NuxtLink>
            </div>

            <transition name="fade" mode="out-in">
              <UAlert
                v-if="formError"
                color="error"
                variant="soft"
                icon="i-lucide-alert-circle"
                :title="formError"
              />
              <UAlert
                v-else-if="success"
                color="success"
                variant="soft"
                icon="i-lucide-check-circle"
                :title="successMessage || '登录成功'"
                description="正在跳转..."
              />
            </transition>
          </div>

          <div class="space-y-3">
            <UButton
              type="submit"
              size="lg"
              block
              :loading="isSubmitting"
              icon="i-lucide-log-in"
            >
              登录
            </UButton>

            <UButton
              color="neutral"
              variant="ghost"
              size="lg"
              block
              to="/register"
              icon="i-lucide-user-plus"
            >
              立即注册
            </UButton>
          </div>
        </UForm>
      </UCard>
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
