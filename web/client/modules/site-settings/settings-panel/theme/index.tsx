import { useContext, memo } from 'react'
import { context as siteSettingsContext } from '../../_provider'
import Accordion from '../../../../components/accordion'
import Typography from '@mui/material/Typography'
import AccordionSummary from '@mui/material/AccordionSummary'
import AccordionDetails from '@mui/material/AccordionDetails'
import { ExpandMore } from '../../../../components/icons'
import { SectionDescription } from '../components'
import Toggle from '../../../../components/toggle'
import FormGroup from '@mui/material/FormGroup'
import Tooltip from '@mui/material/Tooltip'
// import { useColorScheme } from '@mui/material/styles'

const ThemeSettings = memo(
  ({ accepted }) => {
    // const { mode, setMode } = useColorScheme()
    return (
      <>
        <Accordion defaultExpanded={accepted === false ? true : undefined}>
          <AccordionSummary
            expandIcon={<ExpandMore />}
            aria-controls="theme-settings-content"
            id="theme-settings-header"
          >
            <Typography variant="overline" variantMapping={{ overline: 'h3' }}>
              Theme
            </Typography>
          </AccordionSummary>
          <AccordionDetails>
            <SectionDescription sx={{ marginBottom: 0 }}>Theming options</SectionDescription>
            <FormGroup aria-label="Theming options" row>
              <Tooltip placement="left-start" title="Toggle between light and dark theme">
                <Toggle
                  labelProps={{
                    value: 'Dark theme',
                    label: 'Dark theme',
                    labelPlacement: 'start',
                  }}
                  switchProps={{
                    inputProps: {
                      'aria-label': 'Toggle dark theme',
                    },
                    defaultChecked: false,
                    disabled: true,
                    size: 'small',
                    // checked: mode === 'dark',
                    // onChange: ({ target: { checked } }) => setMode(checked ? 'dark' : 'light'),
                  }}
                />
              </Tooltip>
            </FormGroup>
          </AccordionDetails>
        </Accordion>
      </>
    )
  },
  () => true
)

export default () => {
  const { accepted } = useContext(siteSettingsContext)
  return <ThemeSettings accepted={accepted} />
}
