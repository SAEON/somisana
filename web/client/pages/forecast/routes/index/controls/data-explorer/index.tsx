import Paper from '@mui/material/Paper'
import { useContext } from 'react'
import Div from '../../../../../../components/div'
import { context as dataContext } from '../../_context'
import Collapse from '@mui/material/Collapse'
import Table from './table'

export default () => {
  const { selectedCoordinates } = useContext(dataContext)

  return (
    <Div>
      <Collapse in={Boolean(selectedCoordinates.length)} orientation="vertical">
        <Paper variant="outlined" sx={{ borderRadius: 0, mb: 1 }}>
          <Table selectedCoordinates={selectedCoordinates} />
        </Paper>
      </Collapse>
    </Div>
  )
}
