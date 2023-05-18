import { useContext, useEffect, useCallback } from 'react'
import { context as mapContext } from '../../_context'
import { context as pageContext } from '../../../_context'
import { context as configContext } from '../../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

var hoveredMPAId = null

const Render = ({ map, selectedMPAs, setSelectedMPAs, showMPAs, TILESERV_BASE_URL }) => {
  const theme = useTheme()

  const click = useCallback(
    e => {
      const features = map.queryRenderedFeatures(e.point)
      if (features[0].layer.id !== 'mpas') {
        return
      }
      setSelectedMPAs(obj => {
        const featureId = features[0].id
        return { ...obj, [featureId]: !obj[featureId] }
      })
    },
    [map, setSelectedMPAs]
  )

  const mousemove = useCallback(
    e => {
      if (e.features.length > 0) {
        map.getCanvas().style.cursor = 'pointer'
        if (hoveredMPAId) {
          map.setFeatureState(
            { source: 'mpas', id: hoveredMPAId, sourceLayer: 'public.mpas' },
            { hover: false }
          )
        }
        hoveredMPAId = e.features[0].id
        map.setFeatureState(
          { source: 'mpas', id: hoveredMPAId, sourceLayer: 'public.mpas' },
          { hover: true }
        )
      }
    },
    [map]
  )
  const mouseleave = useCallback(() => {
    map.getCanvas().style.cursor = ''
    if (hoveredMPAId) {
      map.setFeatureState(
        { source: 'mpas', id: hoveredMPAId, sourceLayer: 'public.mpas' },
        { hover: false }
      )
    }
    hoveredMPAId = null

    map.getCanvas().style.cursor = ''
  }, [map])

  // Add source, layer, and event handlers
  useEffect(() => {
    if (!showMPAs) {
      if (map.getLayer('mpas')) map.removeLayer('mpas')
      if (map.getSource('mpas')) map.removeSource('mpas')
      setSelectedMPAs({})
      return
    }
    map.addSource('mpas', {
      type: 'vector',
      tiles: [`${TILESERV_BASE_URL}/public.mpas/{z}/{x}/{y}.pbf`],
      url: `${TILESERV_BASE_URL}/public.mpas.json`,
      promoteId: 'ogc_fid',
    })

    map.addLayer({
      id: 'mpas',
      type: 'fill',
      source: 'mpas',
      'source-layer': 'public.mpas',
      paint: {
        'fill-outline-color': theme.palette.primary.dark,
        'fill-color': [
          'case',
          [
            'any',
            ['==', ['feature-state', 'hover'], true],
            ['==', ['feature-state', 'clicked'], true],
          ],
          theme.palette.primary.main,
          theme.palette.common.white,
        ],
        'fill-opacity': 0.5,
      },
    })

    map.on('mousemove', 'mpas', mousemove)
    map.on('mouseleave', 'mpas', mouseleave)
    map.on('click', 'mpas', click)

    return () => {
      map.off('mousemove', 'mpas', mousemove)
      map.off('mouseleave', 'mpas', mouseleave)
      map.off('click', 'mpas', click)
      map.removeLayer('mpas')
      map.removeSource('mpas')
    }
  }, [map, mousemove, showMPAs, mouseleave, click])

  // Update the map layers on data change
  useEffect(() => {
    Object.entries(selectedMPAs).forEach(([id, clicked]) => {
      map.setFeatureState({ source: 'mpas', id, sourceLayer: 'public.mpas' }, { clicked })
    })
  }, [selectedMPAs])
}

export default () => {
  const { TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)
  const { selectedMPAs, setSelectedMPAs, showMPAs } = useContext(pageContext)

  return (
    <Render
      TILESERV_BASE_URL={TILESERV_BASE_URL}
      map={map}
      showMPAs={showMPAs}
      selectedMPAs={selectedMPAs}
      setSelectedMPAs={setSelectedMPAs}
    />
  )
}
