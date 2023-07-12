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

const ThemeSettings = memo(
  ({ accepted, colorScheme, updateSetting }) => {
    return (
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
          <SectionDescription>
            Theming options. This menu can be toggled via the site settings button the in the footer
          </SectionDescription>
          <FormGroup aria-label="Theming options" row>
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
                size: 'small',
                checked: colorScheme === 'dark',
                onChange: ({ target: { checked } }) =>
                  updateSetting({ colorScheme: checked ? 'dark' : 'light' }),
              }}
            />
          </FormGroup>
        </AccordionDetails>
      </Accordion>
    )
  },
  ({ colorScheme: a }, { colorScheme: b }) => {
    if (a !== b) return false
    return true
  }
)

export default () => {
  const { accepted, colorScheme, updateSetting } = useContext(siteSettingsContext)
  return (
    <ThemeSettings accepted={accepted} colorScheme={colorScheme} updateSetting={updateSetting} />
  )
}
