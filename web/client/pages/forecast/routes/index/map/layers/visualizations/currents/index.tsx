import { memo, useContext } from 'react'
// import VectorField from './vector-field'
import { context as mapContext } from '../../../_context'
import { context as pageContext } from '../../../../_context'
import customLayer from './vector-field/custom-layer'
import modeledData from './_data'

// https://observablehq.com/d/88b3d42d8403b554
// https://github.com/greggman/twgl.js/
// TODO - figure out gl, dataCanvas, customLayer, VectorField

const Render = memo(({ map, data, showCurrents, grid, gridWidth, gridHeight }) => {
  if (showCurrents) {
    const minLon = -180
    const minLat = -80

    const dataWidth = 361
    const dataHeight = 161

    const width = dataWidth
    const height = dataHeight

    const outputU = new Float32Array(width * height) //u-component of vector
    const outputV = new Float32Array(width * height) //v-component of vector
    const data = new Uint8Array(width * height * 4) //data for RGBA WebGL texture

    for (let i = 0; i < modeledData.length; i++) {
      //taking advantage of lat and lon being integers to use them as indices to arrays
      const lon = +modeledData[i][0]
      const lat = +modeledData[i][1]
      const lonIdx = lon - minLon
      const latIdx = lat - minLat

      outputU[latIdx * width + lonIdx] = +modeledData[i][2]
      outputV[latIdx * width + lonIdx] = +modeledData[i][3]

      //duplicate to help world wrapping across dateline
      if (lon == -180) {
        outputU[latIdx * width + width - 1] = +modeledData[i][2]
        outputV[latIdx * width + width - 1] = +modeledData[i][3]
      }
    }

    for (let i = 0; i < outputU.length; i++) {
      const ptr = i * 4
      //scale data from 0 to 255 using min/max of -110/110 (min/max derived from known data range)
      data[ptr] = Math.floor((255 * (outputU[i] - -110)) / 220)
      data[ptr + 1] = Math.floor((255 * (outputV[i] - -110)) / 220)
      //make alpha channel 255 to be able to see the image (alpha is not relevant to actual calculations)
      data[ptr + 3] = 255
    }

    if (!map.getLayer(customLayer.id)) map.addLayer(customLayer)
  }

  return null
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
