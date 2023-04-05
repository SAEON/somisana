import { useState, useRef } from 'react'
import Paper from '@mui/material/Paper'
import Typography from '@mui/material/Typography'
import Span from '../../../../../components/span'
import IconButton from '@mui/material/IconButton'
import { Layers as LayersIcon } from '../../../../../components/icons'
import Fade from '@mui/material/Fade'
import Div from '../../../../../components/div'

export default () => {
  const [open, setOpen] = useState(false)
  const ref = useRef(null) // Might be useful in placing the hovered menu

  return (
    <Span
      onMouseLeave={() => setOpen(false)}
      sx={{ display: 'flex', flexDirection: 'row-reverse', position: 'relative', zIndex: 10 }}
    >
      <IconButton
        sx={{ zIndex: 11 }}
        size="small"
        color="primary"
        onMouseEnter={() => setOpen(true)}
      >
        <LayersIcon fontSize="small" />
      </IconButton>

      <Fade key="layers-control" in={open}>
        <Span
          ref={ref}
          sx={{
            right: 0,
            pr: 6,
            position: 'absolute',
          }}
        >
          <Paper
            sx={{
              position: 'relative',
              boxShadow: theme => theme.shadows[3],
              px: 2,
              py: 1,
              textAlign: 'center',
              display: 'flex',
              alignItems: 'center',
              flexDirection: 'column',
            }}
          >
            <Typography variant="body2" sx={{ whiteSpace: 'nowrap' }}>
              Toggle layers (feature coming soon)
            </Typography>
            <Div></Div>
          </Paper>
        </Span>
      </Fade>
    </Span>
  )
}
