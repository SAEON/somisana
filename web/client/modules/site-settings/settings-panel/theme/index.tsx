import { useContext, memo } from 'react'
import { context as siteSettingsContext } from '../../_provider'
import Accordion from '../../../../components/accordion'
import Typography from '@mui/material/Typography'
import AccordionSummary from '@mui/material/AccordionSummary'
import AccordionDetails from '@mui/material/AccordionDetails'
import { ExpandMore } from '../../../../components/icons'
import { SectionDescription } from '../components'

const ThemeSettings = memo(
  ({ accepted }) => {
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
            <SectionDescription sx={{ marginBottom: 0 }}>
              TODO - toggle between light and dark?
            </SectionDescription>
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
