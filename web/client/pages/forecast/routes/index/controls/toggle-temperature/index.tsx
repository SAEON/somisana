import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import IconButton from '@mui/material/IconButton'
import { DegCelsius } from '../../../../../../components/icons'
import Tooltip from '@mui/material/Tooltip'

export default () => {
  const { selectedVariable, setSelectedVariable } = useContext(modelContext)

  return (
    <Tooltip placement="left-start" title="Toggle temperature contours">
      <IconButton
        onClick={() => {
          if (selectedVariable === 'temperature') {
          } else {
            setSelectedVariable('temperature')
          }
        }}
        color="primary"
        size="small"
      >
        <DegCelsius
          sx={{
            color: theme =>
              selectedVariable === 'temperature' ? theme.palette.success.dark : 'primary',
          }}
          fontSize="small"
        />
      </IconButton>
    </Tooltip>
  )
}
