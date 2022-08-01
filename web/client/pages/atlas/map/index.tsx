import { useState, useEffect } from 'react'
import MapLibre from './_maplibre'
import Attribution from './_attribution'

export default () => {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  if (isClient) {
    return <MapLibre Attribution={() => <Attribution>Powered by Esri</Attribution>} />
  }
}
