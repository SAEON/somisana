import MuiAccordion from '@mui/material/Accordion'
import type { AccordionProps } from '@mui/material'

const Accordion = (props: AccordionProps) => (
  <MuiAccordion
    sx={{
      paddingLeft: theme => theme.spacing(1.5),
      paddingRight: theme => theme.spacing(1.5),
      backgroundColor: 'transparent',
      borderRight: 0,
      borderLeft: 0,
      borderBottom: 0,
      '&:first-of-type': {
        borderTop: 0,
      },
      '&:before': {
        display: 'none',
      },
    }}
    square
    disableGutters
    variant="outlined"
    {...props}
  />
)

export default Accordion
