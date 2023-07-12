import Container from '@mui/material/Container'
import content from './_content'
import Markdown from 'react-markdown'
import Div from '../../components/div'

const PrivacyPolicy = () => (
  <Div sx={{ margin: theme => `${theme.spacing(2)} 0`, flex: 1 }}>
    <Container sx={{ margin: 'auto' }}>
      <Markdown>{content}</Markdown>
    </Container>
  </Div>
)

export default PrivacyPolicy
