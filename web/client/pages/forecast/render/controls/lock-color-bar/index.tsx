import { useContext, useEffect, memo } from 'react'
import { context as pageContext } from '../../_context'
import { context as dataContext } from '../../band-data/_context'
import { AxisLock as AxisLockIcon } from '../../../../../components/icons'
import IconButton from '@mui/material/IconButton'
import Tooltip from '@mui/material/Tooltip'
import * as d3 from 'd3'

const Render = memo(
  ({ lockColorBar, setLockColorBar, gridValues, selectedVariable, setScaleMin, setScaleMax }) => {
    useEffect(() => {
      if (gridValues && !lockColorBar) {
        const [min, max] = d3.extent(gridValues.map(([, , v]) => parseFloat(v[selectedVariable])))
        setScaleMin(min)
        setScaleMax(max)
      }
    })

    return (
      <Tooltip title="Prevent color step recalculations per frame change" placement="left-start">
        <IconButton onClick={() => setLockColorBar(b => !b)} color="primary" size="small">
          <AxisLockIcon
            sx={{
              color: theme => (lockColorBar ? theme.palette.success.dark : 'primary'),
            }}
            fontSize="small"
          />
        </IconButton>
      </Tooltip>
    )
  }
)

export default () => {
  const { lockColorBar, setLockColorBar, selectedVariable, setScaleMax, setScaleMin } =
    useContext(pageContext)
  const { grid } = useContext(dataContext)
  return (
    <Render
      lockColorBar={lockColorBar}
      setLockColorBar={setLockColorBar}
      gridValues={grid?.values}
      selectedVariable={selectedVariable}
      setScaleMin={setScaleMin}
      setScaleMax={setScaleMax}
    />
  )
}
