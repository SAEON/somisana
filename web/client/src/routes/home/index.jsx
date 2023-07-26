import { useState, lazy, Suspense } from 'react'
import { Linear as Loading } from '../../components/loading'
import Div from '../../components/div'
import { Typography, alpha } from '@mui/material'

const Map = lazy(() => import('./map'))

export default () => {
  const [ref, setRef] = useState(null)

  return (
    <Div
      sx={{
        display: 'flex',
        flexDirection: 'column',
        height: theme => `calc(100vh - ${theme.spacing(6)})`,
        position: 'relative',
      }}
    >
      <Div
        sx={{
          backgroundColor: theme => theme.palette.background.paper,
          padding: theme => theme.spacing(1)
        }}
      >
        <Typography variant="h5" variantMapping={{h5: 'h2'}} sx={{ display: 'block', textAlign: 'center' }}>
          Sustainable Ocean Modelling Initiative: A South African Approach
        </Typography>
      </Div>
      <Div ref={el => setRef(el)} sx={{ display: 'flex', flex: 1 }}>
        <Suspense fallback={<Loading />}>
          <Map container={ref} />
        </Suspense>
      </Div>
      <Div
        sx={{
          backgroundColor: theme => theme.palette.background.paper,
          padding: theme => theme.spacing(1),
        }}
      >
        <Typography variant="overline" variantMapping={{overline: 'h3'}} sx={{ display: 'block', textAlign: 'center' }}>
          High-resolution South African EEZ ocean data
        </Typography>
      </Div>
    </Div>
  )
}
