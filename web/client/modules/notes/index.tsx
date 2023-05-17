import Container from '@mui/material/Container'
import Div from '../../components/div'
import Paper from '@mui/material/Paper'
import { styled } from '@mui/material/styles'
import { Link as RouterLink } from 'react-router-dom'
import Link_ from '@mui/material/Link'

const StyledLink = styled(RouterLink)(({ theme }) => ({
  display: 'block',
  color: theme.palette.primary.main,
  textDecoration: 'none',
  '&:hover': {
    textDecoration: 'underline',
  },
}))

const Notes = () => (
  <Div sx={{ margin: theme => `${theme.spacing(2)} 0`, flex: 1 }}>
    <Container sx={{ margin: 'auto' }}>
      <Paper
        variant="outlined"
        sx={{
          padding: theme => theme.spacing(4),
        }}
      >
        <StyledLink to={`/notes/woes-model-seasonal-sst`}>WOES model seasonal SSTs</StyledLink>
        <StyledLink to={`/notes/related-papers`}>Related papers</StyledLink>
      </Paper>
    </Container>
  </Div>
)

export default Notes
