/**
 * This page doesn't support SSR
 */
import { useState, useEffect, lazy, Suspense, useContext, useMemo } from 'react'
import { ctx as configContext } from '../../modules/config'
import { createPortal } from 'react-dom'
import Box from '@mui/material/Box'
import { Linear as Loading } from '../../components/loading'

const Map = lazy(() => import('./map'))

export default () => {
  const [isClient, setIsClient] = useState(false)
  const { IMPORT_MAP } = useContext(configContext)

  useEffect(() => {
    setIsClient(true)
  }, [])

  const maplibreVersion = useMemo(
    () => IMPORT_MAP?.scopes['../']['maplibre-gl'].match(/maplibre-gl@(.*)\/dist/)[1],
    []
  )

  if (!isClient) {
    return null
  }

  return (
    <>
      {/* Render the stylesheet into the head */}
      {createPortal(
        <link
          rel="stylesheet"
          href={`https://unpkg.com/maplibre-gl@${maplibreVersion}/dist/maplibre-gl.css`}
        />,
        document.getElementsByTagName('head')[0]
      )}
      <Suspense fallback={<Loading />}>
        <Box
          sx={{
            display: 'flex',
            flexGrow: 1,
            background: theme => theme.palette.grey[100],
            transition: theme => theme.transitions.create(['background-color']),
          }}
        >
          <Map />
        </Box>
      </Suspense>
    </>
  )
}
