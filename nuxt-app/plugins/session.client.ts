import { watch } from 'vue'
import { defineNuxtPlugin, useCookie, useState } from 'nuxt/app'

type SessionUser = {
  userId: number
  username: string
  role: string
  email?: string
  message?: string
}

export default defineNuxtPlugin(() => {
  const state = useState<SessionUser | null>('currentUser', () => null)
  const sessionCookie = useCookie<SessionUser | null>('session_user', {
    default: () => null,
    sameSite: 'lax'
  })

  if (import.meta.client && !state.value && sessionCookie.value) {
    state.value = sessionCookie.value
  }

  if (import.meta.client) {
    watch(state, (value) => {
      sessionCookie.value = value
    }, { deep: true })
  }
})
