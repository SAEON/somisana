import Paper from '@mui/material/Paper'
import { useContext } from 'react'
import Fade from '@mui/material/Fade'
import { context as dataContext } from '../../_context'
import Table from './table'
import Draggable from 'react-draggable'
import { DragVertical as DragHandle } from '../../../../../components/icons'
import Span from '../../../../../components/span'
import Typography from '@mui/material/Typography'
import Toolbar from '@mui/material/Toolbar'
import Div from '../../../../../components/div'

export default () => {
  const { selectedCoordinates, setSelectedCoordinates } = useContext(dataContext)

  return (
    <Fade
      key="data-explorer"
      in={Boolean(Object.values({ ...selectedCoordinates }).filter(v => Boolean(v)).length)}
      unmountOnExit
    >
      <Span
        sx={{
          zIndex: 20,
          position: 'absolute',
          display: 'flex',
          justifyContent: 'center',
          width: '100%',
          top: theme => theme.spacing(-100),
        }}
      >
        <Draggable
          onStop={e => {
            globalThis.dispatchEvent(
              new CustomEvent('interaction', {
                detail: { type: 'drag-data-explorer' },
              })
            )
          }}
          handle="#draggable-data-explorer"
        >
          <Paper
            sx={{
              opacity: 0.8,
              position: 'relative',
              top: theme => theme.spacing(124),
              boxShadow: theme => theme.shadows[3],
              textAlign: 'center',
              display: 'flex',
              flexDirection: 'column',
            }}
          >
            <Toolbar
              disableGutters
              id="draggable-data-explorer"
              sx={{
                cursor: 'move',
                borderBottom: theme => theme.palette.divider,
              }}
              variant="dense"
            >
              <DragHandle sx={{ margin: theme => `0 ${theme.spacing(1)}` }} />
              <Typography>Data Explorer</Typography>
            </Toolbar>
            <Div
              sx={{
                borderRadius: theme =>
                  `0 0 ${theme.shape.borderRadius}px ${theme.shape.borderRadius}px`,
                overflow: 'hidden',
              }}
            >
              <Table
                selectedCoordinates={selectedCoordinates}
                setSelectedCoordinates={setSelectedCoordinates}
              />
            </Div>
          </Paper>
        </Draggable>
      </Span>
    </Fade>
  )
}
