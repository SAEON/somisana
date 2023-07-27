import { useCallback, useContext, useEffect, useMemo } from 'react'
import { context as mapContext } from '../../../_context'
import { context as pageContext } from '../../../../_context'
import { format, add } from 'date-fns'
import resolveRegion from '../../../../../../lib/resolve-region'

const WMS_PARAMS = `REQUEST=GetMap&VERSION=1.3.0&BBOX={bbox-epsg-3857}&CRS=EPSG:3857&WIDTH=256&HEIGHT=256&FORMAT=image/png&TRANSPARENT=true`

const VIZ_ID = 'current-vectors'

const Render = ({ modelid, map, showCurrents, run, timeStep, depth: _depth }) => {
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
  const region = resolveRegion[modelid]
  const yyyyMMdd = useMemo(() => format(new Date(run.run_date), 'yyyyMMdd'), [run.run_date])
  const yyyyMM = useMemo(() => format(new Date(run.run_date), 'yyyyMM'), [run.run_date])
  const path = useMemo(
    () =>
      `/thredds/wms/data/somisana/${region}/5-day-forecast/${yyyyMM}/${yyyyMMdd}-hourly-avg-t3.nc`,
    [region, yyyyMM, yyyyMMdd]
  )
  const layer = `u:v-group`
  const style = `sized_arrows`
  const depth = useMemo(() => Math.abs(_depth), [_depth])
  const url = useMemo(
    () =>
      `https://thredds.somisana.ac.za${path}?${WMS_PARAMS}&LAYERS=${layer}&STYLES=${style}&elevation=${depth}&time=${time}`,
    [path, layer, style, depth, time]
  )

  const removeLayer = useCallback(() => {
    if (map.getLayer(VIZ_ID)) map.removeLayer(VIZ_ID)
    if (map.getSource(VIZ_ID)) map.removeSource(VIZ_ID)
  }, [map])

  useEffect(() => {
    if (showCurrents) {
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
    } else {
      removeLayer()
    }

    return () => {
      removeLayer()
    }
  }, [map, showCurrents, url, removeLayer])

  return null
}

export default ({ grid }) => {
  const { map } = useContext(mapContext)
  const {
    showCurrents,
    model: { _id: id },
    run,
    timeStep,
    depth,
    thresholds,
  } = useContext(pageContext)

  return (
    <Render
      modelid={id}
      map={map}
      grid={grid}
      showCurrents={showCurrents}
      run={run}
      timeStep={timeStep}
      depth={depth}
      thresholds={thresholds}
    />
  )
}
