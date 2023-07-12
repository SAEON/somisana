import { memo } from 'react'
import { useParams } from 'react-router-dom'
import Div from '../../components/div'
import Img from '../../components/img'
import { Linear as Loading } from '../../components/loading'
import useFetch from '../../hooks/use-fetch'
import Paper from '@mui/material/Paper'
import Container from '@mui/material/Container'
import Markdown from 'react-markdown'
import Fade from '@mui/material/Fade'

const Render = memo(
  ({ md }) => {
    return (
      <Fade in>
        <Div sx={{ flex: 1 }}>
          <Container sx={{ margin: theme => `${theme.spacing(2)} auto` }}>
            <Paper
              variant="outlined"
              sx={{
                padding: theme => theme.spacing(4),
              }}
            >
              <Markdown
                components={{
                  img: props => <Img width="100%" {...props} />,
                }}
              >
                {md}
              </Markdown>
            </Paper>
          </Container>
        </Div>
      </Fade>
    )
  },
  () => true
)

export default () => {
  const { id } = useParams()

  const { error, loading, data } = useFetch(`/notes/${id}/index.md`, {
    headers: {
      Accept: 'text/plain',
    },
  })

  if (loading) {
    return <Loading />
  }

  if (error) {
    throw error
  }

  return <Render md={data} />
}
