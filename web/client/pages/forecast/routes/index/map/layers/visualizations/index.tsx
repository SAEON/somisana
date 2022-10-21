import { useContext } from 'react'
import { context as mapContext } from '../../_context'
import { createPortal } from 'react-dom'
import { context as bandDataContext } from '../../../band-data/_context'
import { Linear as Loading } from '../../../../../../../components/loading'
import Currents from './currents'
import TemperatureSalinity from './temperature-salinity'

export default () => {
  const gql = useContext(bandDataContext)
  const {
    map,
    model: { gridWidth = 0, gridHeight = 0 } = {},
    scaleMin,
    setScaleMin,
    scaleMax,
    setScaleMax,
    setTimeStep,
    animateTimeStep,
    selectedVariable,
    color,
    showCurrents,
  } = useContext(mapContext)
  const container = map.getContainer()

  if (gql.error) {
    throw gql.error
  }

  if (gql.loading) {
    return createPortal(<Loading sx={{ top: 0 }} />, container)
  }

  const { json: points } = gql.data.data

  const grid = points.reduce(
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
  )

  return (
    <>
      <TemperatureSalinity
        map={map}
        gridWidth={gridWidth}
        gridHeight={gridHeight}
        data={gql.data.data}
        scaleMin={scaleMin}
        setScaleMin={setScaleMin}
        setScaleMax={setScaleMax}
        scaleMax={scaleMax}
        color={color}
        setTimeStep={setTimeStep}
        animateTimeStep={animateTimeStep}
        selectedVariable={selectedVariable}
        grid={grid}
      />
      <Currents
        gridWidth={gridWidth}
        gridHeight={gridHeight}
        map={map}
        data={gql.data.data}
        grid={grid}
        showCurrents={showCurrents}
      />
    </>
  )
}
