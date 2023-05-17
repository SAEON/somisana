import Container from '@mui/material/Container'
import content from './_content'
import Markdown from 'react-markdown'
import Div from '../../components/div'
import Img from '../../components/img'
import Paper from '@mui/material/Paper'
import { alpha } from '@mui/material/styles'

const About = () => (
  <Div sx={{ margin: theme => `${theme.spacing(2)} 0`, flex: 1 }}>
    <Container sx={{ margin: 'auto' }}>
      <Paper
        sx={{
          padding: 4,
          backgroundColor: theme => alpha(theme.palette.common.white, 1),
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
