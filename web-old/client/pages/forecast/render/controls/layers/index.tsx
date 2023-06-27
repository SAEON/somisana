import { useState, useRef, useContext } from 'react'
import { context as pageContext } from '../../_context'
import Paper from '@mui/material/Paper'
import Typography from '@mui/material/Typography'
import Span from '../../../../../components/span'
import IconButton from '@mui/material/IconButton'
import { Layers as LayersIcon } from '../../../../../components/icons'
import Fade from '@mui/material/Fade'
import Div from '../../../../../components/div'
import FormGroup from '@mui/material/FormGroup'
import FormControlLabel from '@mui/material/FormControlLabel'
import { styled } from '@mui/material/styles'
import Switch from '@mui/material/Switch'

const F = styled(({ control, title, ...props }) => (
  <FormGroup {...props}>
    <FormControlLabel
      labelPlacement="start"
      sx={{ margin: 0 }}
      control={control}
      label={<Typography sx={{ whiteSpace: 'nowrap', marginRight: 'auto' }}>{title}</Typography>}
    />
  </FormGroup>
))({})

const Render = ({
  showMPAs,
  setShowMPAs,
  showCoordinates,
  setShowCoordinates,
  showDomain,
  setShowDomain,
}) => {
  const [open, setOpen] = useState(false)
  const ref = useRef(null) // Might be useful in placing the hovered menu

  return (
    <Span
      onMouseLeave={() => setOpen(false)}
      sx={{ display: 'flex', flexDirection: 'row-reverse', position: 'relative', zIndex: 8 }}
    >
      <IconButton
        sx={{ zIndex: 9 }}
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
            paddingRight: theme => theme.spacing(6),
            position: 'absolute',
            zIndex: 2,
          }}
        >
          <Paper
            sx={{
              position: 'relative',
              boxShadow: theme => theme.shadows[3],
              padding: theme => theme.spacing(1),
              textAlign: 'center',
              display: 'flex',
              alignItems: 'center',
              flexDirection: 'column',
            }}
          >
            <Div>
              <F
                title={`${showDomain ? 'Hide' : 'Show'} domain`}
                control={
                  <Switch
                    sx={{ marginLeft: theme => theme.spacing(2) }}
                    size="small"
                    color={showDomain ? 'primary' : 'default'}
                    onChange={() =>
                      setShowDomain(b => {
                        globalThis.dispatchEvent(
                          new CustomEvent('interaction', {
                            detail: { value: !b, type: 'toggle-domain-later' },
                          })
                        )
                        return !b
                      })
                    }
                    checked={showDomain}
                  />
                }
              />
              <F
                title={`${showMPAs ? 'Hide' : 'Show'} MPAs`}
                control={
                  <Switch
                    sx={{ marginLeft: theme => theme.spacing(2) }}
                    size="small"
                    color={showMPAs ? 'primary' : 'default'}
                    onChange={() =>
                      setShowMPAs(b => {
                        globalThis.dispatchEvent(
                          new CustomEvent('interaction', {
                            detail: { value: !b, type: 'toggle-mpa-layer' },
                          })
                        )
                        return !b
                      })
                    }
                    checked={showMPAs}
                  />
                }
              />

              <F
                title={`${showCoordinates ? 'Hide' : 'Show'} coordinates`}
                control={
                  <Switch
                    sx={{ marginLeft: theme => theme.spacing(2) }}
                    size="small"
                    color={showCoordinates ? 'primary' : 'default'}
                    onChange={() =>
                      setShowCoordinates(b => {
                        globalThis.dispatchEvent(
                          new CustomEvent('interaction', {
                            detail: { value: !b, type: 'toggle-coordinates-layer' },
                          })
                        )
                        return !b
                      })
                    }
                    checked={showCoordinates}
                  />
                }
              />
            </Div>
          </Paper>
        </Span>
      </Fade>
    </Span>
  )
}

export default () => {
  const { showMPAs, setShowMPAs, showCoordinates, setShowCoordinates, showDomain, setShowDomain } =
    useContext(pageContext)
  return (
    <Render
      showMPAs={showMPAs}
      setShowMPAs={setShowMPAs}
      showCoordinates={showCoordinates}
      setShowCoordinates={setShowCoordinates}
      showDomain={showDomain}
      setShowDomain={setShowDomain}
    />
  )
}
