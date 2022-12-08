import { memo, useContext, useEffect } from 'react'
// import VectorField from './vector-field'
import { context as mapContext } from '../../../_context'
import { context as pageContext } from '../../../../_context'
import customLayer from './custom-layer'

// // https://observablehq.com/d/88b3d42d8403b554
// // https://github.com/greggman/twgl.js/

const Render = memo(({ map, data, showCurrents, grid, gridWidth, gridHeight }) => {
  useEffect(() => {
    if (showCurrents) {
      if (!map.getLayer()) map.addLayer(customLayer)
    } else {
      if (map.getLayer(customLayer.id)) map.removeLayer(customLayer.id)
    }
  })
})

export default ({ data, grid }) => {
  const { map } = useContext(mapContext)
  const {
    model: { gridHeight, gridWidth },
    showCurrents,
  } = useContext(pageContext)

  return (
    <Render
      data={data}
      grid={grid}
      gridWidth={gridWidth}
      gridHeight={gridHeight}
      map={map}
      showCurrents={showCurrents}
    />
  )
}
