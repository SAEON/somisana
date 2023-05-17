import Container from '@mui/material/Container'
import Div from '../../components/div'
import Paper from '@mui/material/Paper'
import { alpha, styled } from '@mui/material/styles'
import Link_ from '@mui/material/Link'

const Link = styled(Link_)({ display: 'block' })

const About = () => (
  <Div sx={{ margin: theme => `${theme.spacing(2)} 0`, flex: 1 }}>
    <Container sx={{ margin: 'auto' }}>
      <Paper
        variant="outlined"
        sx={{
          padding: 4,
          backgroundColor: theme => alpha(theme.palette.common.white, 1),
        }}
      >
        <Link href={`/notes/woes-model-seasonal-sst`}>WOES model seasonal SSTs</Link>
        <Link href={`/notes/related-papers`}>Related papers</Link>
      </Paper>
    </Container>
  </Div>
)

export default About
