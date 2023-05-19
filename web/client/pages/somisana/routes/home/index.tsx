import { useRef } from 'react'
import Title from './title'
import Div from '../../../../components/div'
import ScrollButton from './_scroll-button'
import Container_ from '@mui/material/Container'
import { alpha } from '@mui/system/colorManipulator'
import Typography from '@mui/material/Typography'
import ForecastModels from './forecast-models'
import ModelsProvider from './_context'

const Container = props => (
  <Container_ sx={{ padding: theme => `${theme.spacing(8)} 0`, position: 'relative' }} {...props} />
)

const Bg = ({ sx = {}, ...props }) => (
  <Div
    sx={{
      paddingBottom: theme => theme.spacing(6),
      ...sx,
    }}
    {...props}
  />
)

const Heading = ({ color, ...props }) => (
  <Typography
    variant="h2"
    sx={{
      textAlign: 'center',
      marginTop: theme => theme.spacing(3),
      marginBottom: theme => theme.spacing(6),
      color: theme => alpha(theme.palette.common[color || 'white'], 0.9),
    }}
    {...props}
  />
)

const Home = () => {
  const ref = useRef(null)

  return (
    <Div
      sx={{
        flex: 1,
        maxWidth: '100%',
      }}
    >
      {/* TITLE */}
      <Div
        sx={{
          background: theme =>
            `linear-gradient(45deg, ${alpha(theme.palette.common.black, 0.3)} 25%, ${alpha(
              theme.palette.common.black,
              0.7
            )} 85%)`,
          height: theme => `calc(100vh - ${theme.spacing(6)})`,
          display: 'flex',
          flex: 1,
          position: 'relative',
          flexDirection: 'column',
        }}
      >
        <Title />

        <Div>
          <ScrollButton contentRef={ref} />
        </Div>
      </Div>

      {/* CONTENT */}
      <Div ref={ref}>
        {/* FORECAST MODELS */}
        <Bg
          sx={{
            backgroundColor: theme => alpha(theme.palette.common.white, 0.7),
          }}
        >
          <Container>
            <Heading color="black">Operational Ocean forecasts</Heading>
            <ModelsProvider>
              <ForecastModels />
            </ModelsProvider>
          </Container>
        </Bg>
      </Div>
    </Div>
  )
}

export default Home
