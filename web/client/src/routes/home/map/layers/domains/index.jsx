import { useContext, useEffect, useCallback } from 'react'
import { context as mapContext } from '../../_map-context'
import { context as configContext } from '../../../../../modules/config'
import { useNavigate } from 'react-router-dom'
import { useTheme } from '@mui/material/styles'

let hoveredId = null

const Render = ({ map, REACT_APP_TILESERV_BASE_URL }) => {
  const navigate = useNavigate()
  const theme = useTheme()

  const mouseenter = useCallback(
    e => {
      map.getCanvas().style.cursor = 'pointer'
      const id = e.features[0].id
      hoveredId = id
      map.setFeatureState(
        { source: 'domains', id, sourceLayer: 'public.models' },
        { hovered: true }
      )
    },
    [map]
  )
  const mouseleave = useCallback(() => {
    map.getCanvas().style.cursor = ''

    if (hoveredId) {
      map.setFeatureState(
        { source: 'domains', id: hoveredId, sourceLayer: 'public.models' },
        { hovered: false }
      )
      hoveredId = null
    }
  }, [map])
  const click = useCallback(
    e => {
      e['bubble'] = 'no'
      const { features } = e
      const { id } = features[0]
      navigate(`/regions/${id}`)
    },
    [navigate]
  )

  // Add source, layer, and event handlers
  useEffect(() => {
    map.addSource('domains', {
      type: 'vector',
      tiles: [`${REACT_APP_TILESERV_BASE_URL}/public.models/{z}/{x}/{y}.pbf`],
      url: `${REACT_APP_TILESERV_BASE_URL}/public.models.json`,
      promoteId: 'id',
    })

    map.addLayer({
      id: 'domains',
      type: 'fill',
      source: 'domains',
      'source-layer': 'public.models',
      paint: {
        'fill-outline-color': theme.palette.common.black,
        'fill-color': [
          'case',
          ['boolean', ['feature-state', 'hovered'], false],
          theme.palette.common.black,
          'transparent',
        ],
        'fill-opacity': [
          'case',
          ['boolean', ['feature-state', 'hovered'], false],
          0.5,
          1,
        ],
      },
    })

    map.on('click', 'domains', click)
    map.on('mouseenter', 'domains', mouseenter)
    map.on('mouseleave', 'domains', mouseleave)

    map.on('sourcedata', function (e) {
      if (e.sourceId === 'domains' && e.dataType === 'source' && map.isSourceLoaded('domains')) {
        if (map.getLayer('domains')) {
          const features = map.queryRenderedFeatures({ layers: ['domains'] })
          const bounds = features.reduce(
            (a, f) => {
              const { min_y, min_x, max_y, max_x } = f.properties
              a.min_y = a.min_y ? Math.min(a.min_y, min_y) : min_y
              a.min_x = a.min_x ? Math.min(a.min_x, min_x) : min_x
              a.max_x = a.max_x ? Math.max(a.max_x, max_x) : max_x
              a.max_y = a.max_y ? Math.max(a.max_y, max_y) : max_y
              return a
            },
            { min_y: null, min_x: null, max_y: null, max_x: null }
          )

          map.fitBounds(
            [
              [bounds.min_x, bounds.min_y],
              [bounds.max_x, bounds.max_y],
            ],
            {
              linear: false,
              padding: 1000,
              curve: 1,
              speed: 1,
            }
          )
        }
      }
    })

    return () => {
      map.on('click', 'domains', click)
      map.off('mouseenter', 'domains', mouseenter)
      map.off('mouseleave', 'domains', mouseleave)
      map.removeLayer('domains')
      map.removeSource('domains')
    }
  }, [
    map,
    REACT_APP_TILESERV_BASE_URL,
    theme.palette.common.black,
    click,
    mouseenter,
    mouseleave,
  ])
}

export default () => {
  const { REACT_APP_TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)

  return <Render REACT_APP_TILESERV_BASE_URL={REACT_APP_TILESERV_BASE_URL} map={map} />
}
