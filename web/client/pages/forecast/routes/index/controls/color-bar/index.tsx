import { useContext, memo } from 'react'
import { context as pageContext } from '../../_context'
import Config from './config'
import invertColor, { padZero } from './_functions'
import Tooltip_, { tooltipClasses } from '@mui/material/Tooltip'
import Div from '../../../../../../components/div'
import Stack from '@mui/material/Stack'
import { styled } from '@mui/material/styles'

const Tooltip = styled(({ className, ...props }) => (
  <Tooltip_ {...props} classes={{ popper: className }} />
))(({ theme }) => ({
  zIndex: 1,
  [`& .${tooltipClasses.tooltip}`]: {
    backgroundColor: theme.palette.common.white,
    color: 'rgba(0, 0, 0, 0.87)',
    boxShadow: theme.shadows[7],
    position: 'relative',
    top: 4,
    left: theme.spacing(-4),
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
  ({
    scaleMin,
    scaleMax,
    setScaleMin,
    setScaleMax,
    color,
    selectedVariable,
    colorScheme,
    setColorScheme,
  }) => {
    const { steps, unit, fix } = config[selectedVariable]
    const range = scaleMax - scaleMin
    const stepSize = range / steps

    return (
      <Stack
        sx={{
          my: theme => theme.spacing(8),
          mx: theme => theme.spacing(2),
          height: '100%',
          maxHeight: 'fill-available',
          position: 'absolute',
          left: 0,
          zIndex: 1,
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          overflow: 'auto',
        }}
      >
        <Config
          scaleMin={scaleMin}
          scaleMax={scaleMax}
          setScaleMin={setScaleMin}
          setScaleMax={setScaleMax}
          colorScheme={colorScheme}
          setColorScheme={setColorScheme}
        />
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
              >
                <Div
                  sx={{
                    backgroundColor: color(value),
                    flex: 1,
                    display: 'flex',
                    px: theme => theme.spacing(1),
                  }}
                />
              </Tooltip>
            )
          })}
      </Stack>
    )
  }
)

export default () => {
  const {
    scaleMin,
    scaleMax,
    setScaleMin,
    setScaleMax,
    color,
    selectedVariable,
    colorScheme,
    setColorScheme,
  } = useContext(pageContext)
  return (
    <Render
      scaleMin={scaleMin}
      scaleMax={scaleMax}
      setScaleMin={setScaleMin}
      setScaleMax={setScaleMax}
      color={color}
      selectedVariable={selectedVariable}
      colorScheme={colorScheme}
      setColorScheme={setColorScheme}
    />
  )
}
