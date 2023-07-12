import { useEffect } from 'react'

export default ({ children, event = undefined, handle, target, readyState = undefined }) => {
  // Client only
  useEffect(() => {
    const el = target || globalThis

    if (event) {
      el.addEventListener(event, handle)
    }

    if (readyState) {
      if (el.readyState === readyState) {
        handle()
      }
    }

    return () => {
      if (event) {
        el.removeEventListener(event, handle)
      }
    }
  }, [event, handle, readyState, target])

  return children
}
