import { useContext, memo } from 'react'
import Translate from '../../../i18n/translate'
import { context as siteSettingsContext } from '../../_provider'
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
              <Translate contentId="language" />
            </Typography>
          </AccordionSummary>
          <AccordionDetails>
            <SectionDescription sx={{ marginBottom: 0 }}>
              <Translate contentId="language-settings-blurb" />
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
  return <LanguageSettings forceLanguage={forceLanguage} accepted={accepted} />
}
