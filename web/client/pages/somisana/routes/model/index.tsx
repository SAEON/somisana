import { lazy, Suspense } from 'react'
import Div from '../../../../components/div'
import { Linear as Loading } from '../../../../components/loading'

const Atlas = lazy(() => import('../../../esri-atlas/ssr'))

export default props => {
  return (
    <Div sx={{ height: theme => `calc(100vh - ${theme.spacing(6)})`, display: 'flex', flex: 1 }}>
      <Suspense fallback={<Loading />}>
        <Atlas {...props} />
      </Suspense>
    </Div>
  )
}
