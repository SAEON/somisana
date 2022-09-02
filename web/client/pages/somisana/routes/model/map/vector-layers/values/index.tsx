import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_context'
import { context as modelContext } from '../../../_context'
import { ctx as configContext } from '../../../../../../../modules/config'

const paint = {
  'circle-radius': ['case', ['boolean', ['feature-state', 'click'], false], 8, 3],
  'circle-stroke-width': 3,
  'circle-stroke-opacity': 0,
  'circle-color': {
    property: 'temperature',
    stops: [
      [0, '#080a83'],
      [3, '#0005f5'],
      [3.5, '#0800f5'],
      [4, '#1400f6'],
      [4.5, '#2100f6'],
      [5, '#2e00f6'],
      [5.5, '#3b00f6'],
      [6, '#4800f7'],
      [6.5, '#5400f7'],
      [7, '#6100f7'],
      [7.5, '#6e00f7'],
      [8, '#7b00f8'],
      [8.5, '#8800f8'],
      [9, '#9500f8'],
      [9.5, '#a200f8'],
      [10, '#af00f9'],
      [10.5, '#bc00f9'],
      [11, '#c900f9'],
      [11.5, '#d700f9'],
      [12, '#e400fa'],
      [12.5, '#f100fa'],
      [13, '#fa00f6'],
      [13.5, '#fa00e9'],
      [14, '#fb00dd'],
      [14.5, '#fb00d0'],
      [15, '#fb00c3'],
      [15.5, '#fb00b6'],
      [16, '#fc00a9'],
      [16.5, '#fc009d'],
      [17, '#fc0090'],
      [17.5, '#fc0083'],
      [18, '#fd0076'],
      [18.5, '#fd0069'],
      [19, '#fd005c'],
      [19.5, '#fd004f'],
      [20, '#fe0042'],
      [20.5, '#fe0035'],
      [21, '#fe0028'],
      [21.5, '#fe001a'],
      [22, '#ff000d'],
      [22.5, '#ff0000'],
    ],
  },
}

export default () => {
  const { TILESERV_BASE_URL } = useContext(configContext)
  const {
    map,
    model: { _id: modelid },
  } = useContext(mapContext)
  const { time_step } = useContext(modelContext)

  useEffect(() => {
    const run_date = '2022-09-01'
    const depth_level = 20
    const id = `values_${time_step}`
    const previousId = `values_${time_step - 1}`
    const nextId = `values_${time_step + 1}`

    if (map.getSource(id)) {
      map.setLayoutProperty(id, 'visibility', 'visible')
    } else {
      map.addSource(id, {
        type: 'vector',
        tiles: [
          `${TILESERV_BASE_URL}/public.values/{z}/{x}/{y}.pbf?filter=${encodeURIComponent(`
              depth_level=${depth_level}
              and time_step=${time_step}
              and modelid=${modelid}
              and run_date=${run_date}`)}`,
        ],
        url: `${TILESERV_BASE_URL}/public.values.json`,
        promoteId: 'id',
      })

      map.addLayer({
        id: id,
        type: 'circle',
        source: id,
        'source-layer': 'public.values',
        paint,
      })

      let featureClickId = null
      map.on('mouseenter', id, () => {
        map.getCanvas().style.cursor = 'pointer'
      })

      map.on('mouseleave', id, () => {
        map.getCanvas().style.cursor = ''
      })

      map.on('click', id, ({ features }) => {
        let oldId = featureClickId
        featureClickId = features[0].id
        map.setFeatureState(
          { source: id, id: featureClickId, sourceLayer: 'public.values' },
          { click: true }
        )
        if (oldId) {
          map.setFeatureState(
            { source: id, id: oldId, sourceLayer: 'public.values' },
            { click: false }
          )
        }
      })
    }

    if (map.getSource(previousId)) {
      map.setLayoutProperty(previousId, 'visibility', 'none')
    }

    if (map.getSource(nextId)) {
      map.setLayoutProperty(nextId, 'visibility', 'none')
    }
  }, [time_step, map])
}
