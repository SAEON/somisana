import { useEffect, useRef, useMemo } from 'react'
import Map from 'ol/Map'
import View from 'ol/View'
import { defaults as defaultControls } from 'ol/control'
import LayerGroup from 'ol/layer/Group'
import Div from '../../../components/div'

export default ({ layers = [], viewOptions = {}, Attribution }) => {
  const ref = useRef(null)

  useEffect(() => {
    const map = new Map({
      layers: new LayerGroup({
        layers: [...layers].map((layer, i, arr) => {
          layer.setZIndex(arr.length - i)
          return layer
        }),
      }),
      controls: defaultControls({
        zoom: false,
        rotateOptions: undefined,
        rotate: false,
        attribution: false,
      }).extend([]),
      view: new View(
        Object.assign(
          {
            center: [25, -28],
            zoom: 6,
            projection: 'EPSG:4326',
            multiWorld: false,
          },
          viewOptions
        )
      ),
    })

    map.setTarget(ref.current)
    window.map = map // For easier debugging
  }, [])

  return (
    <Div
      ref={ref}
      sx={{
        position: 'absolute',
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
      }}
    >
      <Attribution />
    </Div>
  )
}
