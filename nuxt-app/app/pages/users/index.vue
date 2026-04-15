<script setup lang="ts">
import type { FetchError } from 'ofetch'
import type { TableColumn } from '#ui/types'
import { useDateFormat } from '@vueuse/core'

type UserRole = 'ADMIN' | 'CUSTOMER'

type User = {
  id: number
  username: string
  email: string
  phone: string | null
  role: UserRole
  active: boolean
  createdAt: string
  updatedAt: string
}

type CurrentUser = {
  role?: UserRole
}

useSeoMeta({
  title: '用户管理 - 控制台',
  description: '查看商城用户列表，并支持快速禁用或启用用户账号。'
})

const config = useRuntimeConfig()
const apiBase = config.public.apiBase
const router = useRouter()
const currentUser = useState<CurrentUser | null>('currentUser', () => null)

onBeforeMount(() => {
  if (!currentUser.value || currentUser.value.role !== 'ADMIN') {
    router.push('/')
  }
})

const users = ref<User[]>([])
const loading = ref(false)
const errorMessage = ref('')
const updatingIds = ref(new Set<number>())
const searchTerm = ref('')

const tableRows = computed(() => users.value.map(user => ({ ...user })))
const filteredRows = computed(() => {
  const keyword = searchTerm.value.trim().toLowerCase()

  if (!keyword) {
    return tableRows.value
  }

  return tableRows.value.filter((user) => {
    const username = (user.username ?? '').toLowerCase()
    const email = (user.email ?? '').toLowerCase()
    const phone = (user.phone ?? '').toLowerCase()
    const role = (user.role ?? '').toLowerCase()
    const statusLabel = user.active ? '启用' : '禁用'

    return (
      username.includes(keyword)
      || email.includes(keyword)
      || phone.includes(keyword)
      || role.includes(keyword)
      || statusLabel.toLowerCase().includes(keyword)
    )
  })
})

const columns: TableColumn<User>[] = [
  { accessorKey: 'username', header: '用户名' },
  { accessorKey: 'email', header: '邮箱' },
  { accessorKey: 'phone', header: '手机号' },
  { accessorKey: 'role', header: '角色' },
  { accessorKey: 'active', header: '状态' },
  { accessorKey: 'createdAt', header: '注册时间' },
  { id: 'actions', header: '操作' }
]

const fetchUsers = async () => {
  loading.value = true
  errorMessage.value = ''

  try {
    const data = await $fetch<User[]>(`${apiBase}/api/admin/users`)
    users.value = data
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
  }
}

onMounted(fetchUsers)

const handleToggle = async (user: User) => {
  if (updatingIds.value.has(user.id)) {
    return
  }

  updatingIds.value.add(user.id)
  errorMessage.value = ''

  try {
    const updated = await $fetch<User>(`${apiBase}/api/admin/users/${user.id}/status`, {
      method: 'PUT',
      body: {
        active: !user.active
      }
    })

    users.value = users.value.map(item => (item.id === updated.id ? updated : item))
  } catch (error) {
    handleError(error)
  } finally {
    updatingIds.value.delete(user.id)
  }
}

const handleError = (error: unknown) => {
  if (isFetchError(error)) {
    errorMessage.value = error.data?.message || error.statusMessage || '操作失败，请稍后重试'
  } else {
    errorMessage.value = '操作失败，请稍后重试'
  }
}

const formatDate = (value: string) => useDateFormat(value, 'YYYY-MM-DD HH:mm').value

function isFetchError(error: unknown): error is FetchError {
  return typeof error === 'object' && error !== null && 'statusCode' in error
}
</script>

<template>
  <div class="py-10">
    <div class="mx-auto max-w-6xl space-y-8 px-4 sm:px-6 lg:px-8">
      <UPageHeader
        title="用户管理"
        description="支持管理员快速查询用户基础信息并调整账号状态。"
        :links="[
          {
            label: '返回主界面',
            icon: 'i-lucide-home',
            to: '/dashboard',
            color: 'neutral',
            variant: 'ghost'
          }
        ]"
      />

      <UCard>
      <template #header>
        <div class="flex items-center justify-between">
          <div>
            <h2 class="text-base font-semibold">账号列表</h2>
            <p class="text-sm text-muted">
              共 {{ filteredRows.length }} 位{{ searchTerm ? '匹配' : '' }}用户
              <span v-if="searchTerm" class="text-muted">（全部 {{ users.length }} 位）</span>
              。
            </p>
          </div>
          <UButton icon="i-lucide-refresh-cw" variant="ghost" :loading="loading" @click="fetchUsers">
            刷新
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

        <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <UInput
            v-model="searchTerm"
            icon="i-lucide-search"
            placeholder="输入用户名、邮箱或手机号搜索"
            class="w-full md:w-80"
          />
        </div>

        <UTable :data="filteredRows" :columns="columns" :loading="loading">
          <template #role-cell="{ row }">
            <UBadge :color="row.original.role === 'ADMIN' ? 'primary' : 'neutral'" variant="soft">
              {{ row.original.role === 'ADMIN' ? '管理员' : '普通用户' }}
            </UBadge>
          </template>

          <template #active-cell="{ row }">
            <UBadge :color="row.original.active ? 'success' : 'error'" variant="soft">
              {{ row.original.active ? '启用' : '禁用' }}
            </UBadge>
          </template>

          <template #createdAt-cell="{ row }">
            {{ formatDate(row.original.createdAt) }}
          </template>

          <template #actions-cell="{ row }">
            <UButton
              :icon="row.original.active ? 'i-lucide-user-x' : 'i-lucide-user-check'"
              size="xs"
              :color="row.original.active ? 'warning' : 'success'"
              variant="soft"
              :loading="updatingIds.has(row.original.id)"
              @click="handleToggle(row.original)"
            >
              {{ row.original.active ? '禁用' : '启用' }}
            </UButton>
          </template>
        </UTable>
      </div>
      </UCard>
    </div>
  </div>
</template>
