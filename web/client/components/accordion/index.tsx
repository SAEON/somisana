import MuiAccordion from '@mui/material/Accordion'
import type { AccordionProps } from '@mui/material'

const Accordion = (props: AccordionProps) => (
  <MuiAccordion
    sx={{
      backgroundColor: 'transparent',
      border: theme => `1px solid ${theme.palette.divider}`,
      borderRight: 0,
      borderLeft: 0,
      '&:not(:last-child)': {
        borderBottom: 0,
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
