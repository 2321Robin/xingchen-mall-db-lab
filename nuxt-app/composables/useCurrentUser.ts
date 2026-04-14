import { useState } from 'nuxt/app'

type CurrentUser = {
  userId: number
  username: string
  role: string
  email?: string
  message?: string
}

export const useCurrentUser = () => useState<CurrentUser | null>('currentUser', () => null)
