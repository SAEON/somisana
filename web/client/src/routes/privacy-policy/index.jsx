import Container from '@mui/material/Container'
import content from './_content'
import Markdown from 'react-markdown'
import Div from '../../components/div'
import { Paper } from '@mui/material'

const PrivacyPolicy = () => (
  <Div sx={{ margin: theme => `${theme.spacing(2)} 0`, flex: 1 }}>
    <Container sx={{ margin: 'auto' }}>
      <Paper
        sx={{
          paddingLeft: theme => theme.spacing(4),
          paddingRight: theme => theme.spacing(4),
          paddingTop: theme => theme.spacing(1),
          paddingBottom: theme => theme.spacing(1),
        }}
      >
        <Markdown>{content}</Markdown>
      </Paper>
    </Container>
  </Div>
)

export default PrivacyPolicy
