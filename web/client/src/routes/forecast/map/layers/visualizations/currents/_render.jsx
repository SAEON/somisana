import { memo, useEffect } from 'react'
import customLayer from './custom-layer'

// // https://observablehq.com/d/88b3d42d8403b554
// // https://github.com/greggman/twgl.js/

export default memo(({ map, data, showCurrents, grid, gridWidth, gridHeight }) => {
  useEffect(() => {
    if (showCurrents) {
      if (!map.getLayer()) map.addLayer(customLayer)
    } else {
      if (map.getLayer(customLayer.id)) map.removeLayer(customLayer.id)
    }
  })
})
