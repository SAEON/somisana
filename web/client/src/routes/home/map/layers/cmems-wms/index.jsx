import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_map-context'
import Img from '../../../../../components/img'
import Div from '../../../../../components/div'
import { Tooltip, Paper, Divider, Typography, Link, alpha } from '@mui/material'
import { minMax, thresholds } from '../saeon-wms'

const PALETTE = 'rainbow'

const STYLE = `boxfill/${PALETTE}`

const SERVICE_URL = `https://nrt.cmems-du.eu/thredds/wms/cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m?request=GetCapabilities&service=WMS`

const TILE_URL = `https://nrt.cmems-du.eu/thredds/wms/cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m?REQUEST=GetMap&VERSION=1.3.0&LAYERS=thetao&STYLES=${STYLE}&BBOX={bbox-epsg-3857}&CRS=EPSG:3857&WIDTH=256&HEIGHT=256&FORMAT=image/png&transparent=true&COLORSCALERANGE=${minMax}&NUMCOLORBANDS=${thresholds}`

const LEGEND_URL = `https://nrt.cmems-du.eu/thredds/wms/cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m?REQUEST=GetLegendGraphic&LAYER=thetao&PALETTE=${PALETTE}&transparent=true&FORMAT=image/png&COLORSCALERANGE=${minMax}&NUMCOLORBANDS=${thresholds}`

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
        'raster-opacity': 1,
      },
    })

    return () => {
      if (map.getLayer('wms')) map.removeLayer('wms')
      if (map.getSource('wms')) map.removeSource('wms')
    }
  }, [map])

  return (
    <>
      <Typography
        variant="body2"
        sx={{
          position: 'absolute',
          top: 0,
          right: 0,
          paddingTop: theme => theme.spacing(0.5),
          paddingBottom: theme => theme.spacing(0.5),
          paddingLeft: theme => theme.spacing(2),
          paddingRight: theme => theme.spacing(2),
          backgroundColor: theme => alpha(theme.palette.background.paper, 0.75),
        }}
      >
        Each domain represents a downscaling of the CMEMS global analysis and forecast product{' '}
        <Link
          target="_blank"
          rel="noopener noreferrer"
          variant="body2"
          href="https://data.marine.copernicus.eu/product/GLOBAL_ANALYSISFORECAST_PHY_001_024/description"
        >
          GLOBAL_ANALYSISFORECAST_PHY_001_024
        </Link>
      </Typography>
      <Paper
        sx={theme => ({
          display: 'none',
          [theme.breakpoints.up('sm')]: {
            opacity: 0.75,
            overflow: 'hidden',
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

        <Typography
          variant="overline"
          href={SERVICE_URL}
          target="_blank"
          rel="noopener noreferrer"
          sx={{
            display: 'block',
            textAlign: 'center',
            color: theme => theme.palette.common.white,
            marginBottom: theme => theme.spacing(1),
          }}
        >
          SST
        </Typography>
        <Img
          sx={{
            maxHeight: 250,
            margin: 'auto',
            display: 'block',
            marginRight: '-46px',
          }}
          src={LEGEND_URL}
        />
      </Paper>
    </>
  )
}

export default () => {
  const { map } = useContext(mapContext)

  return <Render map={map} />
}
