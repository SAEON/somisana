import { useState, useEffect } from 'react'
import MapLibre from './_maplibre'
import Attribution from './_attribution'
import Typography from '@mui/material/Typography'

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
            <Typography variant="caption">Powered by Esri</Typography>
          </Attribution>
        )}
      />
    )
  }
}
