import permissions from './permissions.js'
import _deduplicate from '../lib/deduplicate-obj.js'

const deduplicate = arr => _deduplicate(arr, (p1, p2) => p1.name === p2.name)

export const user = {
  name: 'user',
  description: 'Default login role',
  permissions: deduplicate([]),
}

export const saeon = {
  name: 'saeon',
  description: 'Default login roles for @saeon.ac.za email addresses',
  permissions: deduplicate([...user.permissions]),
}

export const admin = {
  name: 'admin',
  description: 'Site administrators',
  permissions: deduplicate([...saeon.permissions]),
}

export const sysadmin = {
  name: 'sysadmin',
  description: 'System administrators',
  permissions: deduplicate([...admin.permissions]),
}

export default [user, saeon, admin, sysadmin]
