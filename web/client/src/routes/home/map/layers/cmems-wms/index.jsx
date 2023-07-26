import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_map-context'
import Img from '../../../../../components/img'
import Div from '../../../../../components/div'
import Span from '../../../../../components/span'
import { Tooltip, Paper, Divider, Typography } from '@mui/material'

const PALETTE = 'ncview'

const STYLE = `boxfill/${PALETTE}`

// const SERVICE_URL = `https://nrt.cmems-du.eu/thredds/wms/cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m?request=GetCapabilities&service=WMS`

const TILE_URL = `https://nrt.cmems-du.eu/thredds/wms/cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m?REQUEST=GetMap&VERSION=1.3.0&LAYERS=thetao&STYLES=${STYLE}&BBOX={bbox-epsg-3857}&CRS=EPSG:3857&WIDTH=256&HEIGHT=256&FORMAT=image/png&transparent=true`

const LEGEND_URL = `https://nrt.cmems-du.eu/thredds/wms/cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m?REQUEST=GetLegendGraphic&LAYER=thetao&PALETTE=${PALETTE}&transparent=true&FORMAT=image/png`

const Render = ({ map }) => {
  useEffect(() => {
    map.addSource('wms', {
      type: 'raster',
      tiles: [TILE_URL],
      tileSize: 256,
    })

    map.addLayer({
      id: 'wms',
      type: 'raster',
      source: 'wms',
      paint: {
        'raster-opacity': 0.35,
      },
    })

    return () => {
      if (map.getLayer('wms')) map.removeLayer('wms')
      if (map.getSource('wms')) map.removeSource('wms')
    }
  }, [map])

  return (
    <Paper
      sx={theme => ({
        display: 'none',
        [theme.breakpoints.up('sm')]: {
          opacity: 0.75,
          position: 'absolute',
          zIndex: 1,
          backgroundColor: theme => theme.palette.common.black,
          margin: theme => theme.spacing(2),
          padding: theme => theme.spacing(2),
          bottom: 42,
          left: 0,
          display: 'inherit',
        },
        [theme.breakpoints.up('md')]: {
          bottom: 0,
        },
      })}
    >
      <Div
        sx={{
          border: theme => `1px solid ${theme.palette.common.white}`,
          borderRadius: theme => `${theme.shape.borderRadius}px`,
        }}
      >
        <Tooltip placement="left-end" title="Marine protected areas">
          <Typography
            variant="overline"
            sx={{
              color: theme => theme.palette.common.white,
              display: 'block',
              textAlign: 'center',
            }}
          >
            MPAs
          </Typography>
        </Tooltip>
      </Div>
      <Divider
        sx={{ marginTop: theme => theme.spacing(2), marginBottom: theme => theme.spacing(1) }}
      />
      <Tooltip placement="left-end" title="Select a region by clicking on the bounding box">
        <Span>
        <Typography
          variant="overline"
          sx={{
            color: theme => theme.palette.common.white,
            display: 'block',
            textAlign: 'center',
          }}
        >
          RSA EEZ
        </Typography>
        <Typography
          variant="caption"
          sx={{
            color: theme => theme.palette.common.white,
            display: 'block',
            textAlign: 'center',
          }}
        >
          Select..
        </Typography>
        </Span>
      </Tooltip>
      <Divider
        sx={{ marginTop: theme => theme.spacing(2), marginBottom: theme => theme.spacing(1) }}
      />
      <Typography
        variant="overline"
        sx={{
          display: 'block',
          textAlign: 'center',
          marginBottom: theme => theme.spacing(1),
        }}
      >
        CMEMS SST
      </Typography>
      <Img
        sx={{
          maxHeight: 250,
          margin: 'auto',
          display: 'block',
        }}
        src={LEGEND_URL}
      />
    </Paper>
  )
}

export default () => {
  const { map } = useContext(mapContext)

  return <Render map={map} />
}
