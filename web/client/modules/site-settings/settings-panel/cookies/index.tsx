import { useContext, memo } from 'react'
import { context as siteSettingsContext } from '../../_provider'
import Accordion from '../../../../components/accordion'
import Typography from '@mui/material/Typography'
import AccordionSummary from '@mui/material/AccordionSummary'
import AccordionDetails from '@mui/material/AccordionDetails'
import { ExpandMore } from '../../../../components/icons'
import { SectionDescription } from '../components'
import FormGroup from '@mui/material/FormGroup'
import MuiLink from '@mui/material/Link'
import { Link } from 'react-router-dom'
import Toggle from '../../../../components/toggle'
import Tooltip from '@mui/material/Tooltip'

const CookieSettings = memo(
  ({ updateSetting, accepted, disableGoogleAnalytics }) => {
    return (
      <>
        <Accordion defaultExpanded={accepted === false ? true : undefined}>
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
              We use cookies to enable necessary functionality such as authentication. Additionally,
              we use cookies to analyze site usage. No personal information is provided to 3rd
              parties &#40;see our{' '}
              <MuiLink component={Link} to="/privacy-policy">
                privacy policy
              </MuiLink>{' '}
              for more information&#41;
            </SectionDescription>
            <FormGroup aria-label="Cookie settings" row>
              <Tooltip placement="left-start" title="Some cookies are necessary to use this site">
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
                    defaultChecked: true,
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
                    label: 'Session',
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
              <Tooltip placement="left-start" title="Enable Google Analytics (disabled by default)">
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
                    checked: !disableGoogleAnalytics,
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
      </>
    )
  },
  (a, b) => {
    if (a.disableGoogleAnalytics !== b.disableGoogleAnalytics) return false
    return true
  }
)

export default () => {
  const { updateSetting, disableGoogleAnalytics, accepted } = useContext(siteSettingsContext)
  return (
    <CookieSettings
      updateSetting={updateSetting}
      accepted={accepted}
      disableGoogleAnalytics={disableGoogleAnalytics}
    />
  )
}
