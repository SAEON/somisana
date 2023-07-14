import { useState, lazy, Suspense } from 'react'
import { Linear as Loading } from '../../components/loading'
import Div from '../../components/div'
import { Typography, alpha } from '@mui/material'

const Map = lazy(() => import('./map'))

export default () => {
  const [ref, setRef] = useState(null)

  return (
    <Div
      ref={el => setRef(el)}
      sx={{
        height: theme => `calc(100vh - ${theme.spacing(6)})`,
        position: 'relative',
      }}
    >
      <Typography
        sx={{
          position: 'absolute',
          backgroundColor: theme => alpha(theme.palette.common.black, 0.75),
          zIndex: 1,
          top: 0,
          left: 0,
          padding: theme => theme.spacing(1),
          margin: theme => theme.spacing(1),
          boxShadow: theme => theme.shadows[9]
        }}
      >
        Welcome to the SAEON sustainable ocean modelling program<br />Click regions of interest for high
        quality forecast and nowcast data
      </Typography>
      <Suspense fallback={<Loading />}>
        <Map container={ref} />
      </Suspense>
    </Div>
  )
}
