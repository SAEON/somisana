import Container from '@mui/material/Container'
import content from './_content'
import Markdown from 'react-markdown'
import Div from '../../components/div'
import Img from '../../components/img'

const About = () => (
  <Div sx={{ my: theme => theme.spacing(2), flex: 1 }}>
    <Container sx={{ margin: 'auto' }}>
      <Markdown
        components={{
          img: props => <Img width="100%" {...props} />,
        }}
      >
        {content}
      </Markdown>
    </Container>
  </Div>
)

export default About
