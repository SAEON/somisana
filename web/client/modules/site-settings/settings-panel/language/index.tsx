import { useContext, memo } from 'react'
import { ctx as siteSettingsContext } from '../../'
import Accordion from '../../../../components/accordion'
import Typography from '@mui/material/Typography'
import AccordionSummary from '@mui/material/AccordionSummary'
import AccordionDetails from '@mui/material/AccordionDetails'
import { ExpandMore } from '../../../../components/icons'
import SelectLocale from './_select-local'
import { SectionDescription } from '../components'
import FormGroup from '@mui/material/FormGroup'

const LanguageSettings = memo(
  ({ accepted }) => {
    return (
      <>
        <Accordion defaultExpanded={accepted === false ? true : undefined}>
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
      </>
    )
  },
  () => true
)

export default () => {
  const { accepted } = useContext(siteSettingsContext)
  return <LanguageSettings accepted={accepted} />
}
