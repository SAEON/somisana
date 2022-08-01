import { useState, useEffect } from 'react'
import MapLibre from './_maplibre'
import Attribution from './_attribution'
import Link from '@mui/material/Link'

export default () => {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  if (isClient) {
    return (
      <MapLibre
        Attribution={() => (
          <Attribution>
            <Link href="https://carto.com/" target="_blank">
              &copy; CARTO
            </Link>{' '}
            <Link href="https://www.maptiler.com/copyright/" target="_blank">
              &copy; MapTiler
            </Link>{' '}
            <Link href="https://www.openstreetmap.org/copyright" target="_blank">
              &copy; OpenStreetMap contributors
            </Link>
          </Attribution>
        )}
      />
    )
  }
}
