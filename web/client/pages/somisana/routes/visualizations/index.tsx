import { lazy, Suspense } from 'react'
import Div from '../../../../components/div'
import { Linear as Loading } from '../../../../components/loading'

const Atlas = lazy(() => import('../../../maplibre-atlas/ssr'))

export default () => {
  return (
    <Div sx={{ height: 'calc(100vh - 48px)', display: 'flex', flex: 1 }}>
      <Suspense fallback={<Loading />}>
        <Atlas />
      </Suspense>
    </Div>
  )
}
