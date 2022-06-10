import { useContext, memo } from 'react'
import { ctx as siteSettingsContext } from '../../_provider'
import Accordion from '../../../../components/accordion'
import Typography from '@mui/material/Typography'
import AccordionSummary from '@mui/material/AccordionSummary'
import AccordionDetails from '@mui/material/AccordionDetails'
import { ExpandMore } from '../../../../components/icons'
import SelectLocale from './_select-local'
import { SectionDescription } from '../components'
import FormGroup from '@mui/material/FormGroup'

const LanguageSettings = memo(
  ({ accepted, forceLanguage }) => {
    return (
      <>
        <Accordion defaultExpanded={forceLanguage || accepted === false ? true : undefined}>
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
              initiative. If the content is not already translated for the language of your choice,
              please consider submitting a translation! Content that has not yet been translated
              will be displayed in the default language &#40;English&#41;
            </SectionDescription>
            <FormGroup aria-label="Language settings" row>
              <SelectLocale />
            </FormGroup>
          </AccordionDetails>
        </Accordion>
      </>
    )
  },
  () => true
)

export default ({ forceLanguage }) => {
  const { accepted } = useContext(siteSettingsContext)
  return <LanguageSettings forceLanguage accepted={accepted} />
}
