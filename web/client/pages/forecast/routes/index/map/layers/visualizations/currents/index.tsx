import { useContext, lazy, Suspense } from 'react'
import { context as mapContext } from '../../../_context'
import { context as pageContext } from '../../../../_context'
import { Linear as Loading } from '../../../../../../../../components/loading'

const Render = lazy(() => import('./_render'))

export default ({ data, grid }) => {
  const { map } = useContext(mapContext)
  const {
    model: { gridHeight, gridWidth },
    showCurrents,
  } = useContext(pageContext)

  return (
    <Suspense fallback={<Loading />}>
      <Render
        data={data}
        grid={grid}
        gridWidth={gridWidth}
        gridHeight={gridHeight}
        map={map}
        showCurrents={showCurrents}
      />
    </Suspense>
  )
}
