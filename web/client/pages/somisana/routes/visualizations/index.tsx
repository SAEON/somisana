import { lazy, Suspense } from 'react'
import Div from '../../../../components/div'
import Loading from '../../../../components/loading'

const Atlas = lazy(() => import('../../../atlas/ssr'))

export default () => {
  return (
    <Div sx={{ height: 'calc(100vh - 48px)', display: 'flex', flex: 1 }}>
      <Suspense fallback={<Loading />}>
        <Atlas />
      </Suspense>
    </Div>
  )
}
