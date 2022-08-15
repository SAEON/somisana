/**
 * This page doesn't support SSR
 */
import { useState, useEffect, lazy, Suspense } from 'react'
import { useParams } from 'react-router-dom'
import Box from '@mui/material/Box'
import { Linear as Loading } from '../../components/loading'

const Map = lazy(() => import('./map'))

export default () => {
  const { id } = useParams()
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  return (
    <>
      <Box
        sx={{
          height: 'calc(100vh - 48px)',
          display: 'flex',
          flex: 1,
        }}
      >
        {isClient && (
          <Suspense fallback={<Loading />}>
            <Map id={id} />
          </Suspense>
        )}
      </Box>
    </>
  )
}
