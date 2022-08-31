import { lazy, Suspense, useState, useEffect } from 'react'
import Div from '../../../../components/div'
import { Linear as Loading } from '../../../../components/loading'
import Provider from './_context'

const Map = lazy(() => import('./map'))

export default props => {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => setIsClient(true), [])

  if (!isClient) {
    return null
  }

  return (
    <Provider>
      <Div sx={{ height: theme => `calc(100vh - ${theme.spacing(6)})`, display: 'flex', flex: 1 }}>
        <Suspense fallback={<Loading />}>
          <Map {...props} />
        </Suspense>
      </Div>
    </Provider>
  )
}
