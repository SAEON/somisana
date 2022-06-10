import Container from '@mui/material/Container'
import content from './_content'
import Markdown from 'react-markdown'
import Div from '../../components/div'

const About = () => (
  <Div sx={{ marginTop: theme => theme.spacing(2), flex: 1 }}>
    <Container sx={{ margin: 'auto' }}>
      <Markdown>{content}</Markdown>
    </Container>
  </Div>
)

export default About
