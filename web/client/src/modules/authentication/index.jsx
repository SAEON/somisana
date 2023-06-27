import { useState, useEffect, createContext } from 'react'
import { API_HTTP } from '../config/env'

export const context = createContext()

export default ({ children }) => {
  const [user, setUser] = useState(false)
  const [authenticating, setAuthenticating] = useState(false)

  const authenticate = () => {
    if (user) {
      return true
    } else {
      window.location.href = `${`${API_HTTP}/login`.replace('//', '/')}?redirect=${
        window.location.href
      }`
    }
  }

  useEffect(() => {
    const abortController = new AbortController()

    ;(async () => {
      setAuthenticating(true)
      try {
        const response = await fetch(`${API_HTTP}/authenticate`, {
          credentials: 'include',
          mode: 'cors',
          signal: abortController.signal,
        })
        const userInfo = await response.json()
        setUser(userInfo)
        setAuthenticating(false)
      } catch (error) {
        // This is probably fine
        console.warn('Error authenticating user ::' + error.message)
      }
    })()

    return () => {
      abortController.abort()
    }
  }, [])

  return (
    <context.Provider
      value={{
        user,
        authenticating,
        authenticate,
      }}
    >
      {children}
    </context.Provider>
  )
}
