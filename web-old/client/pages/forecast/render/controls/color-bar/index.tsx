import { useContext, memo } from 'react'
import { context as pageContext } from '../../_context'
import Config_ from './config'
import Tooltip_, { tooltipClasses } from '@mui/material/Tooltip'
import Div from '../../../../../components/div'
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

const Render = memo(
  ({ scaleMin, scaleMax, color, selectedVariable }) => {
    const { steps, unit, fix } = config[selectedVariable]
    const range = scaleMax - scaleMin
    const stepSize = range / steps

    return (
      <Stack
        sx={{
          padding: theme => theme.spacing(1.5),
          margin: theme => `${theme.spacing(2)} 0 0 ${theme.spacing(2)}`,
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
          overflow: 'hidden',
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
                  onClick: () => console.log('tooltip clicked. This could be useful in the future'),
                }}
              >
                <Div
                  sx={{
                    ':first-of-type': {
                      borderRadius: `4px 4px 0 0`,
                    },
                    ':last-of-type': {
                      borderRadius: `0 0 4px 4px`,
                    },
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
  },
  (a, b) => {
    if (!b.scaleMax || !b.scaleMin) return true
    return false
  }
)

export default () => {
  const { scaleMin, scaleMax, color, selectedVariable } = useContext(pageContext)
  return (
    <Render
      scaleMin={scaleMin}
      scaleMax={scaleMax}
      color={color}
      selectedVariable={selectedVariable}
    />
  )
}
