import { useContext, memo, useState } from 'react'
import { context as pageContext } from '../../_context'
import Config_ from './config'
import Tooltip_, { tooltipClasses } from '@mui/material/Tooltip'
import Div from '../../../../../../components/div'
import Stack from '@mui/material/Stack'
import { styled, alpha } from '@mui/material/styles'

export const ToggleConfig = Config_

const Tooltip = styled(({ className, PopperProps, ...props }) => (
  <Tooltip_ {...props} classes={{ popper: className }} PopperProps={PopperProps} />
))(({ theme }) => ({
  zIndex: 1,
  [`& .${tooltipClasses.tooltip}`]: {
    transition: theme.transitions.create(['background-color']),
    backgroundColor: theme.palette.common.white,
    color: 'rgba(0, 0, 0, 0.87)',
    '&:hover': {
      backgroundColor: theme.palette.primary.light,
    },
    boxShadow: theme.shadows[3],
    position: 'relative',
    top: 4,
    left: theme.spacing(-1),
    margin: 0,
    padding: `${theme.spacing(0.5)} ${theme.spacing(1)}`,
    fontSize: 10,
  },
}))

const config = {
  temperature: {
    steps: 25,
    unit: '°C',
    fix: 1,
  },
  salinity: {
    steps: 50,
    unit: '‰',
    fix: 3,
  },
}

const Render = memo(({ scaleMin, scaleMax, color, selectedVariable }) => {
  const { steps, unit, fix } = config[selectedVariable]
  const range = scaleMax - scaleMin
  const stepSize = range / steps

  return (
    <Stack
      sx={{
        p: theme => theme.spacing(2),
        my: theme => theme.spacing(2),
        ml: theme => theme.spacing(2),
        backgroundColor: theme => alpha(theme.palette.common.black, 0.3),
        borderRadius: theme => `${theme.shape.borderRadius}px`,
        boxShadow: theme => theme.shadows[1],
        height: theme => `calc(100% - ${theme.spacing(4)})`,
        position: 'absolute',
        left: 0,
        zIndex: 1,
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        overflow: 'auto',
      }}
    >
      {new Array(steps)
        .fill(null)
        .map((_, i) => parseFloat((scaleMin + stepSize * i).toFixed(fix)))
        .reverse()
        .map((value, i) => {
          return (
            <Tooltip
              open={i % 7 === 0 ? true : undefined}
              key={i}
              placement="right-start"
              title={`${value} ${unit}`}
              PopperProps={{
                sx: { cursor: 'pointer' },
                onClick: () =>
                  alert(
                    'Feature being implemented - hovering on individual temperatures will highlight those contours on the map for the duration of the hover. Clicking on a label will allow for activating specific contours on the map'
                  ),
              }}
            >
              <Div
                sx={{
                  backgroundColor: color(value),
                  flex: 1,
                  display: 'flex',
                  width: theme => theme.spacing(2),
                }}
              />
            </Tooltip>
          )
        })}
    </Stack>
  )
})

export default () => {
  const {
    scaleMin,
    scaleMax,

    color,
    selectedVariable,
  } = useContext(pageContext)
  return (
    <Render
      scaleMin={scaleMin}
      scaleMax={scaleMax}
      color={color}
      selectedVariable={selectedVariable}
    />
  )
}
