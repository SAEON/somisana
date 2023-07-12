import { lazy, Suspense } from 'react'
import { Linear as Loading } from '../../../../components/loading'
import { useParams } from 'react-router-dom'
import Div from '../../../../components/div'

const Forecast = lazy(() => import('../../../forecast/render/index'))

export default () => {
  const { id } = useParams()
  return (
    <Div
      sx={{
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'flex-start',
        flexGrow: 1,
        height: `calc(100vh - 48px)`,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <Suspense fallback={<Loading />}>
        <Forecast modelid={id} />
      </Suspense>
    </Div>
  )
}
