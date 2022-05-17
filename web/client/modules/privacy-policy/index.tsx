import Container from '@mui/material/Container'
import content from './_content'
import Markdown from 'react-markdown'
import Div from '../../components/div'


const PrivacyPolicy = () => (
<Div sx={{marginTop: theme => theme.spacing(2)}}>
  <Container><Markdown>{content}</Markdown></Container>
</Div>
)


export default PrivacyPolicy