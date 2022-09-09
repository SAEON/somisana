import { lazy, Suspense, useState, useEffect } from 'react'
import Div from '../../../../components/div'
import { Linear as Loading } from '../../../../components/loading'
import Provider from './_context'
import Container from '@mui/material/Container'
import Title from './title'
import Charts from './charts'

const Map = lazy(() => import('./map'))

export default props => {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => setIsClient(true), [])

  if (!isClient) {
    return null
  }

  return (
    <Provider>
      <Div sx={{ my: theme => theme.spacing(2) }} />
      <Container>
        {/* TITLE */}
        <Title />

        {/* MAP */}
        <Suspense fallback={<Loading />}>
          <Div sx={{ display: 'flex', flex: 1 }}>
            <Map {...props} />
          </Div>
        </Suspense>

        {/* CHARTS */}
        <Charts />
      </Container>

      <Div sx={{ my: theme => theme.spacing(2) }} />
    </Provider>
  )
}
