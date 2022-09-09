import { useContext } from 'react'
import { context as modelContext } from '../_context'

export default () => {
  const ctx = useContext(modelContext)
  return JSON.stringify(ctx)
}
