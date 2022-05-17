import { useState } from 'react'
import Tooltip from '@mui/material/Tooltip'
import IconButton from '@mui/material/IconButton'
import Button from '@mui/material/Button'
import SwipeableDrawer from '@mui/material/SwipeableDrawer'
import { Cog, Close, ExpandMore, CheckAll } from '../../../../../components/icons'
import Toolbar from '@mui/material/Toolbar'
import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'
import AccordionSummary from '@mui/material/AccordionSummary'
import AccordionDetails from '@mui/material/AccordionDetails'
import Accordion from '../../../../../components/accordion'
import FormGroup from '@mui/material/FormGroup'
import Toggle from '../../../../../components/toggle'
import MuiLink from '@mui/material/Link'
import { Link } from 'react-router-dom'

const SiteSettingsPanel = () => {
  const [open, setOpen] = useState(false)

  return (
    <>
      {/* TOGGLE */}
      <Tooltip placement="left" title="Site settings">
        <IconButton
          onClick={() => setOpen(true)}
          size="medium"
          sx={{ position: 'absolute', bottom: 0, right: 0, margin: theme => theme.spacing(2) }}
        >
          <Cog />
        </IconButton>
      </Tooltip>

      {/* DRAWER */}
      <SwipeableDrawer
        variant="temporary"
        ModalProps={{
          keepMounted: true,
        }}
        anchor="right"
        open={open}
        onClose={() => setOpen(false)}
        onOpen={() => setOpen(true)}
      >
        <Toolbar
          disableGutters
          sx={{
            padding: theme => theme.spacing(1),
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <Typography>Site settings</Typography>
          <IconButton onClick={() => setOpen(false)} size="small">
            <Close />
          </IconButton>
        </Toolbar>
        <Box
          sx={theme => ({
            minWidth: 400,
            [theme.breakpoints.up('sm')]: {
              maxWidth: 400,
            },
          })}
        >
          <Accordion>
            <AccordionSummary
              expandIcon={<ExpandMore />}
              aria-controls="language-settings-content"
              id="language-settings-header"
            >
              <Typography>Language</Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Typography>TODO select language</Typography>
            </AccordionDetails>
          </Accordion>
          <Accordion>
            <AccordionSummary
              expandIcon={<ExpandMore />}
              aria-controls="coolie-settings-content"
              id="coolie-settings-header"
            >
              <Typography>Cookies</Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Typography
                sx={{
                  fontSize: '0.8rem',
                  mb: theme => theme.spacing(2),
                  textAlign: 'justify'
                }}
              >
                We use cookies to enable necessary functionality such as authentication.
                Additionally, we use cookies to analyze site usage. No personal information is
                provided to 3rd parties &#40;see our{' '}
                <MuiLink component={Link} to="/privacy-policy">
                  privacy policy
                </MuiLink>{' '}
                for more information&#41;.
              </Typography>
              <FormGroup aria-label="Cookie settings" row>
                <Toggle
                  labelProps={{
                    value: 'Necessary',
                    label: 'Necessary',
                    labelPlacement: 'start',
                  }}
                  switchProps={{
                    inputProps: {
                      'aria-label': 'Toggle necessary cookies',
                    },
                    defaultChecked: true,
                    disabled: true,
                    size: 'small',
                  }}
                />
                <Toggle
                  labelProps={{
                    value: 'Google analytics',
                    label: 'Google analytics',
                    labelPlacement: 'start',
                  }}
                  switchProps={{
                    inputProps: {
                      'aria-label': 'Google analytics',
                    },
                    defaultChecked: true,
                    disabled: false,
                    size: 'small',
                    onChange: ({ target: { checked } }) =>
                      (window['ga-disable-G-6ZM4ST1XCC'] = !checked),
                  }}
                />
              </FormGroup>
            </AccordionDetails>
          </Accordion>
        </Box>
        <Toolbar
          disableGutters
          variant="dense"
          sx={{
            padding: theme => theme.spacing(1),
            display: 'flex',
            alignItems: 'center',
            flexDirection: 'row-reverse',
            marginTop: 'auto',
          }}
        >
          <Button
            color="primary"
            onClick={() => setOpen(false)}
            variant="contained"
            disableElevation
            size="medium"
            startIcon={<CheckAll />}
          >
            Accept
          </Button>
        </Toolbar>
      </SwipeableDrawer>
    </>
  )
}

export default SiteSettingsPanel
