import { lazy, Suspense, useState, useEffect } from 'react'
import Div from '../../../../components/div'
import { Linear as Loading } from '../../../../components/loading'

const Dashboard = lazy(() => import('../dashboard'))

export default () => {
  const [ref, setRef] = useState(null)
  const [isClient, setIsClient] = useState(false)

  useEffect(() => setIsClient(true), [])

  if (!isClient) {
    return null
  }

  return (
    <Div sx={{ position: 'fixed', top: 0, bottom: 0, left: 0, right: 0 }} ref={el => setRef(el)}>
      <Div sx={{ display: 'flex', height: '100%', width: '100%' }}>
        {ref && (
          <Suspense fallback={<Loading />}>
            <Dashboard container={ref} />
          </Suspense>
        )}
      </Div>
    </Div>
  )
}
