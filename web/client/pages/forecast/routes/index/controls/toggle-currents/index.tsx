import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import IconButton from '@mui/material/IconButton'
import { TailWind } from '../../../../../../components/icons'
import Tooltip from '@mui/material/Tooltip'

export default () => {
  const { showCurrents, setShowCurrents } = useContext(modelContext)

  return (
    <Tooltip placement="left-start" title="Toggle currents (not implemented yet)">
      <IconButton onClick={() => setShowCurrents(b => !b)} color="primary" size="small">
        <TailWind
          sx={{
            color: theme => (showCurrents ? theme.palette.success.dark : 'primary'),
          }}
          fontSize="small"
        />
      </IconButton>
    </Tooltip>
  )
}
