import IconButton from '@mui/material/IconButton'
import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import { Database as DatabaseIcon } from '../../../../../components/icons'
import Tooltip from '@mui/material/Tooltip'

const mnemosyne = {
  1: 'https://mnemosyne.saeon.ac.za/somisana/algoa-bay-forecast',
  2: 'https://mnemosyne.saeon.ac.za/somisana/false-bay-forecast',
}

export const ToggleData = () => {
  const {
    model: { _id: id },
  } = useContext(modelContext)
  return (
    <Tooltip title="View and download raw data" placement="left-start">
      <IconButton
        LinkComponent="a"
        target="_blank"
        color="primary"
        size="small"
        sx={{ zIndex: 11 }}
        href={mnemosyne[id]}
      >
        <DatabaseIcon
          sx={{
            color: 'primary',
          }}
          fontSize="small"
        />
      </IconButton>
    </Tooltip>
  )
}
