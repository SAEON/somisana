import Container from '@mui/material/Container'
import content from './_content'
import Markdown from 'react-markdown'
import Div from '../../components/div'
import Img from '../../components/img'
import Paper from '@mui/material/Paper'
import { alpha } from '@mui/material/styles'

const About = () => (
  <Div sx={{ my: theme => theme.spacing(2), flex: 1 }}>
    <Container sx={{ margin: 'auto' }}>
      <Paper
        sx={{
          p: 4,
          backgroundColor: theme => alpha(theme.palette.common.white, 0.9),
        }}
      >
        <Markdown
          components={{
            img: props => <Img width="100%" {...props} />,
          }}
        >
          {content}
        </Markdown>
      </Paper>
    </Container>
  </Div>
)

export default About
