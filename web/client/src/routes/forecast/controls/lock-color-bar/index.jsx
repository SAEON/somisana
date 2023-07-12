import { useContext, useEffect, memo } from 'react'
import { context as pageContext } from '../../_context'
import { context as dataContext } from '../../band-data/_context'
import { AxisLock as AxisLockIcon } from '../../../../components/icons'
import IconButton from '@mui/material/IconButton'
import Tooltip from '@mui/material/Tooltip'
import * as d3 from 'd3'
import Span from '../../../../components/span'

const Render = memo(
  ({
    lockColorBar,
    setLockColorBar,
    gridValues,
    selectedVariable,
    setScaleMin,
    setScaleMax,
    animateTimeStep,
  }) => {
    useEffect(() => {
      if (!animateTimeStep && gridValues && !lockColorBar) {
        const [min, max] = d3.extent(gridValues.map(([, , v]) => parseFloat(v[selectedVariable])))
        setScaleMin(min)
        setScaleMax(max)
      }
    })

    return (
      <Tooltip
        title={
          animateTimeStep
            ? 'Disabled during timestep animation'
            : 'Prevent color step recalculations per frame change'
        }
        placement="left-start"
      >
        <Span>
          <IconButton
            disabled={animateTimeStep}
            onClick={() =>
              setLockColorBar(b => {
                globalThis.dispatchEvent(
                  new CustomEvent('interaction', {
                    detail: { value: !b, type: 'lock-color-bar' },
                  })
                )
                return !b
              })
            }
            color="primary"
            size="small"
          >
            <AxisLockIcon
              sx={{
                color: theme =>
                  lockColorBar && !animateTimeStep ? theme.palette.success.dark : 'primary',
              }}
              fontSize="small"
            />
          </IconButton>
        </Span>
      </Tooltip>
    )
  }
)

export default () => {
  const {
    lockColorBar,
    setLockColorBar,
    selectedVariable,
    setScaleMax,
    setScaleMin,
    animateTimeStep,
  } = useContext(pageContext)
  const { grid } = useContext(dataContext)
  return (
    <Render
      animateTimeStep={animateTimeStep}
      lockColorBar={lockColorBar}
      setLockColorBar={setLockColorBar}
      gridValues={grid?.values}
      selectedVariable={selectedVariable}
      setScaleMin={setScaleMin}
      setScaleMax={setScaleMax}
    />
  )
}
