<script setup lang="ts">
import type { FormSubmitEvent } from '#ui/types'
import type { FetchError } from 'ofetch'

useSeoMeta({
  title: '找回密码 - 星辰商城',
  description: '通过邮箱验证重置您的星辰商城账号密码。'
})

type ResetState = {
  identifier: string
  email: string
  newPassword: string
  confirmPassword: string
}

const config = useRuntimeConfig()
const apiBase = config.public.apiBase

const state = reactive<ResetState>({
  identifier: '',
  email: '',
  newPassword: '',
  confirmPassword: ''
})

const isSubmitting = ref(false)
const formError = ref('')
const success = ref(false)
const successMessage = ref('')
const showPassword = reactive({
  newPassword: false,
  confirmPassword: false
})

const validateEmail = (email: string) => {
  const pattern = /^(?:[a-z0-9_\-.+])+@(?:[a-z0-9-]+\.)+[a-z]{2,}$/i
  return pattern.test(email)
}

const onSubmit = async (event: FormSubmitEvent<ResetState>) => {
  if (isSubmitting.value) {
    return
  }

  formError.value = ''
  success.value = false
  successMessage.value = ''

  const { identifier, email, newPassword, confirmPassword } = event.data
  const trimmedIdentifier = identifier.trim()
  const trimmedEmail = email.trim()

  if (!trimmedIdentifier) {
    formError.value = '请输入账号或邮箱'
    return
  }

  if (!validateEmail(trimmedEmail)) {
    formError.value = '请输入正确的邮箱地址'
    return
  }

  if (newPassword.length < 6) {
    formError.value = '新密码长度至少为 6 位'
    return
  }

  if (newPassword !== confirmPassword) {
    formError.value = '两次输入的密码不一致'
    return
  }

  isSubmitting.value = true

  try {
    const payload = {
      identifier: trimmedIdentifier,
      email: trimmedEmail,
      newPassword
    }

    await $fetch(`${apiBase}/api/auth/forgot-password`, {
      method: 'POST',
      body: payload
    })

    success.value = true
    successMessage.value = '密码重置成功，请使用新密码登录'
    state.newPassword = ''
    state.confirmPassword = ''
  } catch (error) {
    handleError(error)
  } finally {
    isSubmitting.value = false
  }
}

function handleError(error: unknown) {
  if (isFetchError(error)) {
    const fetchError = error as FetchError<{ message?: string }>
    formError.value = fetchError.data?.message || fetchError.statusMessage || '重置密码失败，请稍后再试'
  } else {
    formError.value = '重置密码失败，请稍后再试'
  }
  success.value = false
}

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}
</script>

<template>
  <div class="flex items-center justify-center py-12 sm:py-16">
    <div class="grid w-full max-w-5xl gap-8 px-4 sm:px-6 lg:grid-cols-[1.1fr_0.9fr] lg:gap-12">
      <div class="space-y-6">
        <div class="space-y-2">
          <UBadge color="primary" variant="soft">星辰商城 · 密码找回</UBadge>
          <h1 class="text-3xl font-semibold tracking-tight sm:text-4xl">
            重置您的账号密码
          </h1>
          <p class="text-muted">
            请输入注册时使用的账号或手机号，并通过邮箱验证完成密码重置。
          </p>
        </div>

        <UCard class="border-dashed border-primary/40 bg-primary-500/5">
          <div class="space-y-4">
            <h2 class="text-lg font-semibold">温馨提示</h2>
            <ul class="space-y-2 text-sm text-muted">
              <li>• 新密码需至少 6 位，建议包含字母与数字。</li>
              <li>• 邮箱需与账号绑定邮箱一致，否则无法验证。</li>
              <li>• 如无法完成重置，请联系平台管理员协助处理。</li>
            </ul>
          </div>
        </UCard>
      </div>

      <UCard>
        <template #header>
          <div class="space-y-2">
            <h2 class="text-xl font-semibold">验证身份并设置新密码</h2>
            <p class="text-sm text-muted">我们会校验账号与邮箱是否匹配，请确保信息准确。</p>
          </div>
        </template>

        <UForm :state="state" class="space-y-6" @submit="onSubmit">
          <div class="space-y-4">
            <UFormGroup label="账号 / 手机号 / 邮箱" name="identifier" required>
              <UInput
                v-model="state.identifier"
                size="lg"
                icon="i-lucide-user-search"
                autocomplete="username"
                placeholder="请输入账号、手机号或邮箱"
                class="w-full"
              />
            </UFormGroup>

            <UFormGroup label="注册邮箱" name="email" required>
              <UInput
                v-model="state.email"
                type="email"
                size="lg"
                icon="i-lucide-mail"
                autocomplete="email"
                placeholder="请输入绑定邮箱"
                class="w-full"
              />
            </UFormGroup>

            <UFormGroup label="新密码" name="newPassword" required>
              <UInput
                v-model="state.newPassword"
                :type="showPassword.newPassword ? 'text' : 'password'"
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
                    :aria-label="showPassword.newPassword ? '隐藏密码' : '显示密码'"
                    @click.stop="showPassword.newPassword = !showPassword.newPassword"
                  >
                    <UIcon :name="showPassword.newPassword ? 'i-lucide-eye-off' : 'i-lucide-eye'" />
                  </UButton>
                </template>
              </UInput>
            </UFormGroup>

            <UFormGroup label="确认新密码" name="confirmPassword" required>
              <UInput
                v-model="state.confirmPassword"
                :type="showPassword.confirmPassword ? 'text' : 'password'"
                size="lg"
                icon="i-lucide-lock"
                autocomplete="new-password"
                placeholder="再次输入新密码"
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
                :title="successMessage || '密码重置成功'"
                description="请返回登录页面使用新密码登录。"
              />
            </transition>
          </div>

          <div class="space-y-3">
            <UButton
              type="submit"
              size="lg"
              block
              :loading="isSubmitting"
              icon="i-lucide-shield-check"
            >
              确认重置密码
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
