import Paper from '@mui/material/Paper'
import { useContext } from 'react'
import Div from '../../../../../components/div'
import { context as dataContext } from '../../_context'
import Draggable from 'react-draggable'
import Fade from '@mui/material/Fade'
import Table from './table'
import Span from '../../../../../components/span'

export default () => {
  const { selectedCoordinates, setSelectedCoordinates } = useContext(dataContext)

  return (
    <Fade in={Boolean(Object.values({ ...selectedCoordinates }).filter(v => Boolean(v)).length)}>
      <Span
        sx={{
          zIndex: 10,
          position: 'absolute',
          display: 'flex',
          justifyContent: 'center',
          width: '100%',
          top: theme => theme.spacing(-8),
        }}
      >
        <Draggable handle="#draggable-time-info">
          <Paper
            sx={{
              position: 'relative',
              top: theme => theme.spacing(11),
              cursor: 'move',
              boxShadow: theme => theme.shadows[3],
              p: 0,
              m: 0,
              textAlign: 'center',
              display: 'flex',
              alignItems: 'center',
            }}
            id="draggable-time-info"
          >
            <Paper
              variant="outlined"
              sx={{
                m: 0,
                overflowY: 'scroll',
              }}
            >
              <Table
                selectedCoordinates={selectedCoordinates}
                setSelectedCoordinates={setSelectedCoordinates}
              />
            </Paper>
          </Paper>
        </Draggable>
      </Span>
    </Fade>
  )
}
