import { useContext, lazy, Suspense } from 'react'
import { context as mapContext } from '../../_context'
import { createPortal } from 'react-dom'
import { context as bandDataContext } from '../../../band-data/_context'
import { Linear as Loading } from '../../../../../components/loading'

const TemperatureSalinity = lazy(() => import('./temperature-salinity'))
const Currents = lazy(() => import('./currents'))

export default () => {
  const { map } = useContext(mapContext)
  const { grid, ...gql } = useContext(bandDataContext)

  if (gql.error) {
    throw gql.error
  }

  if (gql.loading) {
    return createPortal(<Loading sx={{ top: 0 }} />, map.getContainer())
  }

  return (
    <Suspense fallback={<Loading />}>
      <TemperatureSalinity data={gql.data.data} grid={grid} />
      <Currents data={gql.data.data} grid={grid} />
    </Suspense>
  )
}
