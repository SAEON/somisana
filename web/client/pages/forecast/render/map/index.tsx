import '../../../../../node_modules/maplibre-gl/dist/maplibre-gl.css'
import { useEffect, useState, useContext } from 'react'
import MapProvider from './_context'
import CoordinatesLayer from './layers/coordinates'
import MPAsLayer from './layers/marine-protected-areas'
import MetadataLayer from './layers/metadata'
import VisualizationsLayer from './layers/visualizations'
import { useSnackbar } from 'notistack'
import { context as configContext } from '../../../../modules/config'

export default ({ container }) => {
  const { NODE_ENV } = useContext(configContext)
  const [noticeSeen, setNoticeSeen] = useState(false)
  const { enqueueSnackbar } = useSnackbar()
  useEffect(() => {
    if (!noticeSeen && NODE_ENV !== 'development') {
      enqueueSnackbar(
        'Welcome to the SOMISANA forecast tools. Please note that this software is still in development (feedback welcome!)',
        {
          variant: 'info',
          anchorOrigin: {
            vertical: 'bottom',
            horizontal: 'left',
          },
        }
      )
      enqueueSnackbar(
        'Configure color scale, min/max, and contouring thresholds in the settings menu',
        {
          variant: 'default',
          anchorOrigin: {
            vertical: 'bottom',
            horizontal: 'left',
          },
        }
      )
      setNoticeSeen(true)
    }
  }, [noticeSeen])

  return (
    container && (
      <MapProvider container={container}>
        <MetadataLayer />
        <MPAsLayer />
        <CoordinatesLayer />
        <VisualizationsLayer />
      </MapProvider>
    )
  )
}