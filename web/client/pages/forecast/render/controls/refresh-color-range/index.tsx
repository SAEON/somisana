import { useContext } from 'react'
import { context as pageContext } from '../../_context'
import { context as dataContext } from '../../band-data/_context'
import { Refresh as RefreshIcon } from '../../../../../components/icons'
import IconButton from '@mui/material/IconButton'
import Tooltip from '@mui/material/Tooltip'
import * as d3 from 'd3'

const Render = ({ gridValues, selectedVariable, setScaleMin, setScaleMax }) => {
  return (
    <Tooltip title="Recalculate color range" placement="left-start">
      <IconButton
        onClick={() => {
          if (gridValues) {
            const [min, max] = d3.extent(
              gridValues.map(([, , v]) => parseFloat(v[selectedVariable]))
            )
            setScaleMin(min)
            setScaleMax(max)
          }
        }}
        color="primary"
        size="small"
      >
        <RefreshIcon
          sx={{
            color: theme => theme.palette.success.dark,
          }}
          fontSize="small"
        />
      </IconButton>
    </Tooltip>
  )
}

export default () => {
  const { selectedVariable, setScaleMax, setScaleMin } = useContext(pageContext)
  const { grid } = useContext(dataContext)

  return (
    <Render
      gridValues={grid?.values}
      selectedVariable={selectedVariable}
      setScaleMin={setScaleMin}
      setScaleMax={setScaleMax}
    />
  )
}
