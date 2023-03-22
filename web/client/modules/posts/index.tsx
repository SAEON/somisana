import Container from '@mui/material/Container'
import Div from '../../components/div'
import Paper from '@mui/material/Paper'
import { alpha } from '@mui/material/styles'
import { ORIGIN } from '../../modules/config/env'
import Link from '@mui/material/Link'

const About = () => (
  <Div sx={{ my: theme => theme.spacing(2), flex: 1 }}>
    <Container sx={{ margin: 'auto' }}>
      <Paper
        sx={{
          p: 4,
          backgroundColor: theme => alpha(theme.palette.common.white, 1),
        }}
      >
        <Link href={`${ORIGIN}/posts/woes-model-seasonal-ssts`}>WOES model seasonal SSTs</Link>
      </Paper>
    </Container>
  </Div>
)

export default About
