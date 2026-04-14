<script setup lang="ts">
import type { FormSubmitEvent } from '#ui/types'
import type { FetchError } from 'ofetch'

useSeoMeta({
  title: '注册 - 星辰商城',
  description: '注册星辰商城账号，畅享便捷的电商购物与管理体验。'
})

type RegisterState = {
  account: string
  email: string
  phone: string
  password: string
  confirmPassword: string
  acceptTerms: boolean
}

type RegisterResponse = {
  userId: number
  username: string
  message: string
}

const config = useRuntimeConfig()
const apiBase = config.public.apiBase

const state = reactive<RegisterState>({
  account: '',
  email: '',
  phone: '',
  password: '',
  confirmPassword: '',
  acceptTerms: false
})

const isSubmitting = ref(false)
const formError = ref('')
const success = ref(false)
const successMessage = ref('')
const showPassword = reactive({
  password: false,
  confirmPassword: false
})

const validateEmail = (email: string) => {
  const pattern = /^(?:[a-z0-9_\-.+])+@(?:[a-z0-9-]+\.)+[a-z]{2,}$/i
  return pattern.test(email)
}

const validatePhone = (phone: string) => {
  const pattern = /^1[3-9]\d{9}$/
  return pattern.test(phone)
}

const onSubmit = async (event: FormSubmitEvent<RegisterState>) => {
  if (isSubmitting.value) {
    return
  }

  formError.value = ''
  success.value = false
  successMessage.value = ''

  const { account, email, phone, password, confirmPassword, acceptTerms } = event.data

  if (!account.trim()) {
    formError.value = '请输入账号昵称'
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

  if (password.length < 6) {
    formError.value = '密码长度至少为 6 位'
    return
  }

  if (password !== confirmPassword) {
    formError.value = '两次输入的密码不一致'
    return
  }

  if (!acceptTerms) {
    formError.value = '请阅读并同意服务协议'
    return
  }

  isSubmitting.value = true

  const payload = {
    username: account.trim(),
    email: email.trim(),
    phone: phone.trim(),
    password
  }

  try {
    const response = await $fetch<RegisterResponse>(`${apiBase}/api/auth/register`, {
      method: 'POST',
      body: payload
    })

    success.value = true
    successMessage.value = response.message || '注册成功'
    state.account = payload.username
    state.email = payload.email
    state.phone = payload.phone
    state.password = ''
    state.confirmPassword = ''
    state.acceptTerms = false
  } catch (error) {
    handleError(error)
  } finally {
    isSubmitting.value = false
  }
}

function handleError(error: unknown) {
  if (isFetchError(error)) {
    const fetchError = error as FetchError<{ message?: string }>
    formError.value = fetchError.data?.message || fetchError.statusMessage || '注册失败，请稍后再试'
  } else {
    formError.value = '注册失败，请稍后再试'
  }
  success.value = false
}

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}
</script>

<template>
  <div class="flex items-center justify-center py-12 sm:py-16">
    <div class="grid w-full max-w-6xl gap-8 px-4 sm:px-6 lg:grid-cols-[1.1fr_0.9fr] lg:gap-12">
      <div class="space-y-6">
        <div class="space-y-2">
          <UBadge color="primary" variant="soft">星辰商城 · 新用户注册</UBadge>
          <h1 class="text-3xl font-semibold tracking-tight sm:text-4xl">
            创建您的星辰商城账号
          </h1>
          <p class="text-muted">
            绑定邮箱与手机号即可完成注册。统一账户可用于商家后台与用户端，支持多地址管理、订单追踪与优惠提醒。
          </p>
        </div>

        <UCard class="border-dashed border-primary/40 bg-primary-500/5">
          <div class="space-y-4">
            <h2 class="text-lg font-semibold">注册小贴士</h2>
            <ul class="space-y-2 text-sm text-muted">
              <li>• 设置至少 6 位密码，建议包含字母与数字。</li>
              <li>• 邮箱用于接收订单通知与找回密码。</li>
              <li>• 手机号用于登录验证与物流动态提醒。</li>
            </ul>
          </div>
        </UCard>
      </div>

      <UCard>
        <template #header>
          <div class="space-y-2">
            <h2 class="text-xl font-semibold">填写注册信息</h2>
            <p class="text-sm text-muted">请准确填写联系方式，以便及时接收订单与发货通知。</p>
          </div>
        </template>

        <UForm :state="state" class="space-y-6" @submit="onSubmit">
          <div class="space-y-4">
            <UFormGroup label="账号昵称" name="account" required>
              <UInput
                v-model="state.account"
                size="lg"
                icon="i-lucide-user"
                autocomplete="username"
                placeholder="请输入账号昵称"
                class="w-full"
              />
            </UFormGroup>

            <UFormGroup label="邮箱" name="email" required>
              <UInput
                v-model="state.email"
                type="email"
                size="lg"
                icon="i-lucide-mail"
                autocomplete="email"
                placeholder="请输入常用邮箱"
                class="w-full"
              />
            </UFormGroup>

            <UFormGroup label="手机号" name="phone" required>
              <UInput
                v-model="state.phone"
                size="lg"
                icon="i-lucide-phone"
                inputmode="numeric"
                autocomplete="tel"
                placeholder="请输入中国大陆手机号"
                class="w-full"
              />
            </UFormGroup>

            <UFormGroup label="设置密码" name="password" required>
              <UInput
                v-model="state.password"
                :type="showPassword.password ? 'text' : 'password'"
                size="lg"
                icon="i-lucide-lock"
                autocomplete="new-password"
                placeholder="至少 6 位，建议包含字母和数字"
                class="w-full"
              >
                <template #trailing>
                  <UButton
                    variant="ghost"
                    color="neutral"
                    size="xs"
                    class="flex h-8 w-8 items-center justify-center p-0"
                    :aria-label="showPassword.password ? '隐藏密码' : '显示密码'"
                    @click.stop="showPassword.password = !showPassword.password"
                  >
                    <UIcon :name="showPassword.password ? 'i-lucide-eye-off' : 'i-lucide-eye'" />
                  </UButton>
                </template>
              </UInput>
            </UFormGroup>

            <UFormGroup label="确认密码" name="confirmPassword" required>
              <UInput
                v-model="state.confirmPassword"
                :type="showPassword.confirmPassword ? 'text' : 'password'"
                size="lg"
                icon="i-lucide-lock"
                autocomplete="new-password"
                placeholder="再次输入密码"
                class="w-full"
              >
                <template #trailing>
                  <UButton
                    variant="ghost"
                    color="neutral"
                    size="xs"
                    class="flex h-8 w-8 items-center justify-center p-0"
                    :aria-label="showPassword.confirmPassword ? '隐藏密码' : '显示密码'"
                    @click.stop="showPassword.confirmPassword = !showPassword.confirmPassword"
                  >
                    <UIcon :name="showPassword.confirmPassword ? 'i-lucide-eye-off' : 'i-lucide-eye'" />
                  </UButton>
                </template>
              </UInput>
            </UFormGroup>

            <div class="space-y-3">
              <UCheckbox
                v-model="state.acceptTerms"
                label="我已阅读并同意《星辰商城服务协议》与《隐私政策》"
              />
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
                  :title="successMessage || '注册成功'"
                  description="请使用新账号登录。"
                />
              </transition>
            </div>
          </div>

          <div class="space-y-3">
            <UButton
              type="submit"
              size="lg"
              block
              :loading="isSubmitting"
              icon="i-lucide-user-plus"
            >
              创建账号
            </UButton>

            <UButton
              color="neutral"
              variant="ghost"
              size="lg"
              block
              to="/"
              icon="i-lucide-log-in"
            >
              返回登录
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
