import IconButton from '@mui/material/IconButton'
import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import {
  Database as DatabaseIcon,
  FileMultiple as FilesIcon,
  TableLarge as TableIcon,
} from '../../../../../../components/icons'
import Div from '../../../../../../components/div'
import Tooltip from '@mui/material/Tooltip'
import Link from '@mui/material/Link'

export const ToggleData = () => {
  const { activeRightPane, setActiveRightPane } = useContext(modelContext)
  return (
    <Tooltip title="Toggle data controls" placement="left-start">
      <IconButton
        color="primary"
        size="small"
        onClick={() => setActiveRightPane(a => (a === 'data' ? false : 'data'))}
      >
        <DatabaseIcon
          sx={{
            color: theme => (activeRightPane === 'data' ? theme.palette.success.dark : 'primary'),
          }}
          fontSize="small"
        />
      </IconButton>
    </Tooltip>
  )
}

const mnemosyne = {
  1: 'https://mnemosyne.saeon.ac.za/somisana/algoa-bay-forecast',
  2: 'https://mnemosyne.saeon.ac.za/somisana/false-bay-forecast',
}

export default () => {
  const {
    showData,
    setShowData,
    model: { _id: id },
  } = useContext(modelContext)

  return (
    <Div sx={{ px: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
      {/* RAW DATA */}
      <Tooltip title="File server" placement="left-start">
        <IconButton
          LinkComponent={Link}
          href={mnemosyne[id]}
          rel="noopener noreferrer"
          target="_blank"
          size="small"
          color="primary"
        >
          <FilesIcon fontSize="small" />
        </IconButton>
      </Tooltip>

      {/* DATA TABLES */}
      <Tooltip title="Inline data" placement="left-start">
        <IconButton
          onClick={() => {
            alert(
              'TBC - this could open a table with all the data of a particular depth, for downloading to CSV, printing, etc.'
            )
            setShowData(b => !b)
          }}
          size="small"
          color="primary"
        >
          <TableIcon
            sx={{
              color: theme => (showData ? theme.palette.success.dark : 'primary'),
            }}
            fontSize="small"
          />
        </IconButton>
      </Tooltip>
    </Div>
  )
}
