import { useContext, memo, useMemo } from 'react'
import { context as mapContext } from '../../_context'
import { createPortal } from 'react-dom'
import { context as bandDataContext } from '../../../band-data/_context'
import { Linear as Loading } from '../../../../../../../components/loading'
// import Currents from './currents'
import TemperatureSalinity from './temperature-salinity'

const Render = memo(({ data, points }) => {
  const grid = useMemo(
    () =>
      points.reduce(
        (a, c) => {
          const [lng, lat, temperature, salinity, u, v] = c
          a.lng.push(lng)
          a.lat.push(lat)
          a.temperature.push(temperature)
          a.salinity.push(salinity)
          a.u.push(u)
          a.v.push(v)
          return a
        },
        {
          lng: [],
          lat: [],
          temperature: [],
          salinity: [],
          u: [],
          v: [],
        }
      ),
    [points]
  )

  return (
    <>
      <TemperatureSalinity data={data} grid={grid} />
      {/* <Currents data={data} grid={grid} /> */}
    </>
  )
})

export default () => {
  const { map } = useContext(mapContext)
  const gql = useContext(bandDataContext)

  const container = map.getContainer()

  if (gql.error) {
    throw gql.error
  }

  if (gql.loading) {
    return createPortal(<Loading sx={{ top: 0 }} />, container)
  }

  return <Render map={map} points={gql.data.data.json} data={gql.data.data} />
}
