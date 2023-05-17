import Paper from '@mui/material/Paper'
import { useContext } from 'react'
import Div from '../../../../../components/div'
import { context as dataContext } from '../../_context'
import Collapse from '@mui/material/Collapse'
import Table from './table'

export default () => {
  const { selectedCoordinates, setSelectedCoordinates } = useContext(dataContext)

  return (
    <Div>
      <Collapse
        in={Boolean(Object.values({ ...selectedCoordinates }).filter(v => Boolean(v)).length)}
        orientation="vertical"
      >
        <Paper variant="outlined" sx={{ borderRadius: 0, mb: 1, overflowY: 'scroll' }}>
          <Table
            selectedCoordinates={selectedCoordinates}
            setSelectedCoordinates={setSelectedCoordinates}
          />
        </Paper>
      </Collapse>
    </Div>
  )
}
