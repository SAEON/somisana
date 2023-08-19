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
        'fill-color': theme.palette.common.black,
        'fill-opacity': [
          'case',
          ['boolean', ['feature-state', 'hovered'], false],
          0.2,
          0.1,
        ],
      },
    })

    map.addLayer({
      id: 'domains-outline',
      type: 'fill',
      source: 'domains',
      'source-layer': 'public.models',
      paint: {
        'fill-outline-color': theme.palette.common.black,
        'fill-color': 'transparent',
        'fill-opacity': [
          'case',
          ['boolean', ['feature-state', 'hovered'], false],
          0.5,
          0.5,
        ],
      },
    })

    map.moveLayer('domains')
    map.moveLayer('domains-outline')

    map.on('click', 'domains', click)
    map.on('mouseenter', 'domains', mouseenter)
    map.on('mouseleave', 'domains', mouseleave)

    return () => {
      map.on('click', 'domains', click)
      map.off('mouseenter', 'domains', mouseenter)
      map.off('mouseleave', 'domains', mouseleave)
      map.removeLayer('domains')
      map.removeLayer('domains-outline')
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
