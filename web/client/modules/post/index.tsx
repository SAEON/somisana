import { memo } from 'react'
import { useParams } from 'react-router-dom'
import Div from '../../components/div'
import Img from '../../components/img'
import { Linear as Loading } from '../../components/loading'
import useFetch from '../../hooks/use-fetch'
import Paper from '@mui/material/Paper'
import Container from '@mui/material/Container'
import Markdown from 'react-markdown'
import { alpha } from '@mui/material/styles'
import Fade from '@mui/material/Fade'

const Render = memo(
  ({ md }) => {
    return (
      <Fade in>
        <Div sx={{ flex: 1 }}>
          <Container sx={{ margin: 'auto', my: 2 }}>
            <Paper
              sx={{
                p: 4,
                backgroundColor: theme => alpha(theme.palette.common.white, 1),
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

  const { error, loading, data } = useFetch(`/posts/${id}/index.md`, {
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
