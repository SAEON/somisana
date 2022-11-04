import { useEffect, useState } from 'react'
import MapProvider from './_context'
import CoordinatesLayer from './layers/coordinates'
import MetadataLayer from './layers/metadata'
import VisualizationsLayer from './layers/visualizations'
import { useSnackbar } from 'notistack'

export default ({ container }) => {
  const [noticeSeen, setNoticeSeen] = useState(false)
  const { enqueueSnackbar } = useSnackbar()

  useEffect(() => {
    if (!noticeSeen) {
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
      setNoticeSeen(true)
    }
  }, [noticeSeen])

  return (
    container && (
      <MapProvider container={container}>
        <MetadataLayer />
        <CoordinatesLayer />
        <VisualizationsLayer />
      </MapProvider>
    )
  )
}
