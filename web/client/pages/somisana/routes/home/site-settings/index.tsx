import { useState, useContext } from 'react'
import { ctx as siteSettingsContext } from '../../../../../modules/site-settings'
import Tooltip from '@mui/material/Tooltip'
import IconButton from '@mui/material/IconButton'
import Button from '@mui/material/Button'
import SwipeableDrawer from '@mui/material/SwipeableDrawer'
import Toolbar from '@mui/material/Toolbar'
import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'
import AccordionSummary from '@mui/material/AccordionSummary'
import AccordionDetails from '@mui/material/AccordionDetails'
import FormGroup from '@mui/material/FormGroup'
import MuiLink from '@mui/material/Link'
import { Link } from 'react-router-dom'
import { styled } from '@mui/material/styles'
import { Cog, Close, ExpandMore, CheckAll } from '../../../../../components/icons'
import Accordion from '../../../../../components/accordion'
import Toggle from '../../../../../components/toggle'
import SelectLocale from './_select-local'

const SectionDescription = styled(Typography)(({ theme }) => ({
  fontSize: '0.8rem',
  marginBottom: theme.spacing(2),
}))

const SiteSettingsPanel = () => {
  const { updateSetting, ...settings } = useContext(siteSettingsContext)
  const [open, setOpen] = useState(false)

  return (
    <>
      {/* TOGGLE DRAWER */}
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
              <Typography variant="overline" variantMapping={{ overline: 'h3' }}>
                Language
              </Typography>
            </AccordionSummary>
            <AccordionDetails>
              <SectionDescription sx={{ marginBottom: 0 }}>
                The SOMISANA i18n effort &#40;content translation&#41; is a community-driven
                initiative. If the content is not already translated for the locale of your choice,
                please consider submitting a translation! Content that has not yet been translated
                will be displayed in the default locale &#40;English&#41;
              </SectionDescription>
              <FormGroup aria-label="Locale settings" row>
                <SelectLocale />
              </FormGroup>
            </AccordionDetails>
          </Accordion>
          <Accordion>
            <AccordionSummary
              expandIcon={<ExpandMore />}
              aria-controls="coolie-settings-content"
              id="coolie-settings-header"
            >
              <Typography variant="overline" variantMapping={{ overline: 'h3' }}>
                Cookies
              </Typography>
            </AccordionSummary>
            <AccordionDetails>
              <SectionDescription>
                We use cookies to enable necessary functionality such as authentication.
                Additionally, we use cookies to analyze site usage. No personal information is
                provided to 3rd parties &#40;see our{' '}
                <MuiLink component={Link} to="/privacy-policy">
                  privacy policy
                </MuiLink>{' '}
                for more information&#41;
              </SectionDescription>
              <FormGroup aria-label="Cookie settings" row>
                <Tooltip placement="left-start" title="These settings are stored in a cookie">
                  <Toggle
                    labelProps={{
                      value: 'Site settings',
                      label: 'Site settings',
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
                </Tooltip>
                <Tooltip placement="left-start" title="Our single-sign-on system requires cookies">
                  <Toggle
                    labelProps={{
                      value: 'Authentication',
                      label: 'Authentication',
                      labelPlacement: 'start',
                    }}
                    switchProps={{
                      inputProps: {
                        'aria-label': 'Toggle necessary cookies',
                      },
                      defaultChecked: false,
                      disabled: true,
                      size: 'small',
                    }}
                  />
                </Tooltip>
                <Tooltip
                  placement="left-start"
                  title="Please provide us feedback on site-feature usage!"
                >
                  <Toggle
                    labelProps={{
                      value: 'Client session',
                      label: 'Client session',
                      labelPlacement: 'start',
                    }}
                    switchProps={{
                      inputProps: {
                        'aria-label': 'Toggle necessary cookies',
                      },
                      defaultChecked: false,
                      disabled: true,
                      size: 'small',
                    }}
                  />
                </Tooltip>
                <Tooltip placement="left-start" title="We get it!">
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
                      checked: !settings.disableGoogleAnalytics,
                      disabled: false,
                      size: 'small',
                      onChange: ({ target: { checked } }) =>
                        updateSetting({ disableGoogleAnalytics: !checked }),
                    }}
                  />
                </Tooltip>
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
