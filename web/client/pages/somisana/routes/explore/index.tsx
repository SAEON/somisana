import { useState, useEffect, lazy, Suspense } from 'react'
import { Linear as Loading } from '../../../../components/loading'
import Box from '@mui/material/Box'

const Map = lazy(() => import('./map'))

export default () => {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  return (
    <Box
      sx={{
        height: theme => `calc(100vh - ${theme.spacing(6)})`,
        position: 'relative',
      }}
    >
      {isClient && (
        <Suspense fallback={<Loading />}>
          <Map />
        </Suspense>
      )}
    </Box>
  )
}
