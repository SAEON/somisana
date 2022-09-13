import { lazy, Suspense, useState, useEffect } from 'react'
import Div from '../../../../components/div'
import { Linear as Loading } from '../../../../components/loading'
import ModelProvider from './_context'
import BandDataProvider from './band-data'
import PointDataProvider from './point-data'
import Container from '@mui/material/Container'
import Title from './title'
import Charts from './charts'
import DepthControl from './controls/depth'
import TimeControl from './controls/time'
import Grid from '@mui/material/Grid'

const Map = lazy(() => import('./map'))

export default props => {
  const [divRef, setRef] = useState(null)
  const [isClient, setIsClient] = useState(false)

  useEffect(() => setIsClient(true), [])

  if (!isClient) {
    return null
  }

  return (
    <ModelProvider>
      <BandDataProvider>
        {/* MAP OBJECT */}
        <Suspense fallback={<Loading />}>
          <Map divRef={divRef} {...props} />
        </Suspense>

        <Div sx={{ my: theme => theme.spacing(2) }} />

        {/* LAYOUT */}
        <Container>
          {/* TITLE */}
          <Title />

          {/* MAP */}
          <Div sx={{ display: 'flex', flex: 1 }}>
            <Div sx={{ display: 'flex', flex: 1, flexDirection: 'column', minHeight: 500 }}>
              <Div sx={{ minHeight: 500 }} ref={el => setRef(el)} />
              <TimeControl />
            </Div>
            <DepthControl />
          </Div>

          {/* CHARTS */}
          <Div sx={{ my: theme => theme.spacing(4) }} />
          <PointDataProvider>
            <Charts />
          </PointDataProvider>
        </Container>

        <Div sx={{ my: theme => theme.spacing(2) }} />
      </BandDataProvider>
    </ModelProvider>
  )
}
