import Paper from '@mui/material/Paper'
import { useContext } from 'react'
import { createPortal } from 'react-dom'
import Fade from '@mui/material/Fade'
import { context as dataContext } from '../../_context'
import { context as bandContext } from '../../band-data/_context'
import Table from './table'
import Draggable from 'react-draggable'
import { DragVertical as DragHandle } from '../../../../../components/icons'
import Span from '../../../../../components/span'
import Typography from '@mui/material/Typography'
import Toolbar from '@mui/material/Toolbar'
import Div from '../../../../../components/div'
import Tooltip from '@mui/material/Tooltip'
import IconButton from '@mui/material/IconButton'
import {
  TableLarge as DataIcon,
  Close as CloseIcon,
  Download as DownloadIcon,
} from '../../../../../components/icons'

export default () => {
  const { showBandData, setShowBandData, depth, timeStep, model } = useContext(dataContext)
  const { data } = useContext(bandContext)

  return (
    <>
      <Tooltip placement="left-start" title="Show band data">
        <IconButton
          size="small"
          color="primary"
          onClick={() => {
            globalThis.dispatchEvent(
              new CustomEvent('interaction', {
                detail: { value: !open, type: 'toggle-band-data-table' },
              })
            )
            setShowBandData(!showBandData)
          }}
        >
          <DataIcon
            sx={{
              color: theme => (showBandData ? theme.palette.success.dark : 'primary'),
            }}
            fontSize="small"
          />
        </IconButton>
      </Tooltip>

      {/* Table */}
      {createPortal(
        <Fade key="data-explorer" in={showBandData} unmountOnExit>
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
                  <Typography>
                    Data: (t={timeStep}, {`${depth === -99999 ? 'bottom' : `${depth} meters`}`})
                  </Typography>
                  <Tooltip title="Download CSV data" placement="top-start">
                    <IconButton
                      onClick={() => {
                        globalThis.dispatchEvent(
                          new CustomEvent('interaction', {
                            detail: { type: 'download-data-frame', timeStep, depth },
                          })
                        )
                        const csvContent =
                          'data:text/csv;charset=utf-8,' +
                          [
                            ['coordinateid', 'lng', 'lat', 'temperature', 'salinity', 'u', 'v'],
                            ...(data?.data?.json || []),
                          ]
                            .map(e => e.join(','))
                            .join('\n')
                        const encodedUri = encodeURI(csvContent)
                        const link = document.createElement('a')
                        link.setAttribute('href', encodedUri)
                        link.setAttribute(
                          'download',
                          `${model.title} t${timeStep} ${depth}m r${model.runs[0].run_date}.csv`
                        )
                        document.body.appendChild(link) // Required for FF
                        link.click()
                      }}
                      size="small"
                      sx={{ marginLeft: 'auto' }}
                    >
                      <DownloadIcon fontSize="small" />
                    </IconButton>
                  </Tooltip>
                  <Tooltip title="Close" placement="top-start">
                    <IconButton
                      onClick={() => {
                        globalThis.dispatchEvent(
                          new CustomEvent('interaction', {
                            detail: { type: 'close-data-frame-explorer' },
                          })
                        )
                        setShowBandData(false)
                      }}
                      size="small"
                      sx={{ margin: theme => `0 ${theme.spacing(1)}` }}
                    >
                      <CloseIcon fontSize="small" />
                    </IconButton>
                  </Tooltip>
                </Toolbar>
                <Div
                  sx={{
                    borderRadius: theme =>
                      `0 0 ${theme.shape.borderRadius}px ${theme.shape.borderRadius}px`,
                    overflow: 'hidden',
                  }}
                >
                  <Table />
                </Div>
              </Paper>
            </Draggable>
          </Span>
        </Fade>,
        document.getElementsByTagName('body')[0]
      )}
    </>
  )
}
