import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import IconButton from '@mui/material/IconButton'
import { ScatterPlot } from '../../../../../components/icons'
import Tooltip from '@mui/material/Tooltip'

export default () => {
  const { selectedVariable, setSelectedVariable } = useContext(modelContext)

  return (
    <Tooltip placement="left-start" title="Toggle salinity contours">
      <IconButton
        onClick={() => {
          if (selectedVariable === 'salinity') {
          } else {
            setSelectedVariable('salinity')
          }
        }}
        color="primary"
        size="small"
      >
        <ScatterPlot
          sx={{
            color: theme =>
              selectedVariable === 'salinity' ? theme.palette.success.dark : 'primary',
          }}
          fontSize="small"
        />
      </IconButton>
    </Tooltip>
  )
}
