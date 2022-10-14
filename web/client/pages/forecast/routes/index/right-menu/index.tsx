import { useContext } from 'react'
import { context as modelContext } from '../_context'
import DepthControl from '../controls/depth'
import Div from '../../../../../components/div'
import Paper from '@mui/material/Paper'
import Collapse from '@mui/material/Collapse'

export default () => {
  const { activeRightPane } = useContext(modelContext)

  return (
    <Div sx={{ display: 'flex' }}>
      <Paper
        variant="outlined"
        sx={{
          borderRadius: 0,
          borderBottom: 'none',
          py: theme => theme.spacing(3),
        }}
      >
        <Collapse
          sx={{ height: '100%' }}
          unmountOnExit
          in={activeRightPane === 'depth'}
          orientation="horizontal"
        >
          <DepthControl />
        </Collapse>
      </Paper>
    </Div>
  )
}
