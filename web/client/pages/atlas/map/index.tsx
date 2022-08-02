import { useState, useEffect } from 'react'
import Provider from './_context'

export default () => {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  if (isClient) {
    return <Provider />
  }
}
