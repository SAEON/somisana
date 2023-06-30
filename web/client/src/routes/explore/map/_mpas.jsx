import { useContext, useMemo } from 'react'
import { context as mapContext } from './_context'
import { context as configContext } from '../../../modules/config'
import VectorTileLayer from '@arcgis/core/layers/VectorTileLayer'
import { useTheme, alpha } from '@mui/material/styles'
import Div from '../../../components/div'
import Typography from '@mui/material/Typography'

export default () => {
  const theme = useTheme()
  const { map } = useContext(mapContext)
  const { TILESERV_BASE_URL } = useContext(configContext)

  const layer = useMemo(
    () =>
      new VectorTileLayer({
        style: {
          id: 'mpas',
          version: 8,
          sources: {
            mpas: {
              type: 'vector',
              tiles: [`${TILESERV_BASE_URL}/public.mpas/{z}/{x}/{y}.pbf`],
            },
          },
          layers: [
            {
              id: 'mpas',
              type: 'fill',
              source: 'mpas',
              minzoom: 0,
              maxzoom: 24,
              'source-layer': 'public.mpas',
              paint: {
                'fill-color': theme.palette.success.main,
                'fill-opacity': 0.7,
              },
            },
          ],
        },
      }),
    [TILESERV_BASE_URL, theme.palette.success.main]
  )

  map.add(layer)

  return (
    <Div
      sx={{
        backgroundColor: theme => alpha(theme.palette.common.white, 0.8),
        position: 'absolute',
        top: 0,
        right: 0,
        paddingLeft: theme => theme.spacing(2),
        paddingRight: theme => theme.spacing(2),
        marginTop: theme => theme.spacing(1),
        marginRight: theme => theme.spacing(1)
      }}
    >
      <Typography
        variant="overline"
        sx={{
          zIndex: 1,
          color: theme => theme.palette.common.black,
        }}
      >
        Map of models and marine protected areas
      </Typography>
    </Div>
  )
}
