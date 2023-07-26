import { useContext, useMemo, useCallback, useEffect } from 'react'
import { context as mapContext } from '../../_map-context'
import { format, add } from 'date-fns'

const WMS_PARAMS = `REQUEST=GetMap&VERSION=1.3.0&BBOX={bbox-epsg-3857}&CRS=EPSG:3857&WIDTH=256&HEIGHT=256&FORMAT=image/png&TRANSPARENT=true`

const resolveRegion = {
  1: 'algoa-bay',
  2: 'sw-cape',
}

const Render = ({ map, model }) => {
  const run = useMemo(
    () =>
      [...model.runs].sort(({ run_date: a }, { run_date: b }) => {
        a = new Date(a)
        b = new Date(b)
        if (a > b) return -1
        if (b > a) return 1
        return 0
      })[0],
    [model]
  )

  const VIZ_ID = `saeon-wms-${run.modelid}`

  const yyyyMMdd = useMemo(() => format(new Date(run.run_date), 'yyyyMMdd'), [run.run_date])
  const yyyyMM = useMemo(() => format(new Date(run.run_date), 'yyyyMM'), [run.run_date])
  const region = resolveRegion[run.modelid]
  const layer = `temp`
  const style = `raster/psu-magma`
  const depth = 0
  const minMax = '10,25'
  const timeStep = 120
  const thresholds = 240

  // const LEGEND_URL = `https://thredds.somisana.ac.za/thredds/wms/data/somisana/algoa-bay/5-day-forecast/202307/20230726-hourly-avg-t3.nc?REQUEST=GetLegendGraphic&LAYERS=temp&STYLES=${style}&COLORSCALERANGE=${minMax}&transparent=true&FORMAT=image/png`

  const t0 = useMemo(
    () => (run?.step1_timestamp ? new Date(run.step1_timestamp) : 'Missing timestep'),
    [run?.step1_timestamp]
  )
  const time =
    t0.constructor === Date
      ? format(
          add(t0, {
            hours: timeStep - 1,
          }),
          "yyyy-MM-dd'T'HH:mm"
        )
      : timeStep

  const path = useMemo(
    () =>
      `/thredds/wms/data/somisana/${region}/5-day-forecast/${yyyyMM}/${yyyyMMdd}-hourly-avg-t3.nc`,
    [region, yyyyMM, yyyyMMdd]
  )

  const url = useMemo(
    () =>
      `https://thredds.somisana.ac.za${path}?${WMS_PARAMS}&LAYERS=${layer}&STYLES=${style}&elevation=${depth}&time=${time}&COLORSCALERANGE=${minMax}&NUMCOLORBANDS=${thresholds}&transparent=true&FORMAT=image/png`,
    [path, layer, style, depth, time, minMax, thresholds]
  )

  const removeLayer = useCallback(() => {
    if (map.getLayer(VIZ_ID)) map.removeLayer(VIZ_ID)
    if (map.getSource(VIZ_ID)) map.removeSource(VIZ_ID)
  }, [map, VIZ_ID])

  useEffect(() => {
    map.addSource(VIZ_ID, {
      type: 'raster',
      tiles: [url],
      tileSize: 256,
    })

    map.addLayer({
      id: VIZ_ID,
      type: 'raster',
      source: VIZ_ID,
    })

    map.moveLayer(VIZ_ID)
    if (map.getLayer('domains')) map.moveLayer('domains')
    if (map.getLayer('mpas')) map.moveLayer('mpas')

    return () => {
      removeLayer()
    }
  }, [map, url, VIZ_ID, removeLayer])
}

export default ({ model }) => {
  const { map } = useContext(mapContext)

  return <Render map={map} model={model} />
}
