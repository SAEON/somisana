/**
 * This page doesn't support SSR
 */
import { useState, useEffect, lazy, Suspense } from 'react'
import Box from '@mui/material/Box'
import { Linear as Loading } from '../../components/loading'
const Map = lazy(() => import('./map'))

export default () => {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  if (!isClient) {
    return null
  }

  return (
    <Suspense fallback={<Loading />}>
      <Box
        sx={{
          flexGrow: 1,
          background: theme => theme.palette.grey[100],
          transition: theme => theme.transitions.create(['background-color']),
        }}
      >
        <Map />
      </Box>
    </Suspense>
  )
}
