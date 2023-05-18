import { useRef } from 'react'
import Title from './title'
import Div from '../../../../components/div'
import ScrollButton from './_scroll-button'
import Container_ from '@mui/material/Container'
import { alpha } from '@mui/system/colorManipulator'
import Typography from '@mui/material/Typography'
import PageLinks from './page-links'
import ForecastModels from './forecast-models'
import About from './about'
import HomeProvider from './_context'

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
    <HomeProvider>
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
          {/* PAGE LINKS */}
          <Bg
            sx={{
              background: theme =>
                `linear-gradient(200deg, ${alpha(theme.palette.common.black, 0.45)} 25%, ${alpha(
                  theme.palette.common.black,
                  0.7
                )} 85%)`,
            }}
          >
            <Container>
              <Heading color="white">Our Work</Heading>
              <PageLinks />
            </Container>
          </Bg>

          {/* FORECAST MODELS */}
          <Bg
            sx={{
              backgroundColor: theme => alpha(theme.palette.common.white, 0.7),
            }}
          >
            <Container>
              <Heading color="black">Forecast Models</Heading>
              <ForecastModels />
            </Container>
          </Bg>

          {/* ABOUT US */}
          <Bg
            sx={{
              background: theme =>
                `linear-gradient(90deg, ${alpha(theme.palette.common.black, 0.5)} 25%, ${alpha(
                  theme.palette.common.black,
                  0.7
                )} 85%)`,
            }}
          >
            <Container>
              <Heading color="white">Our partners</Heading>
              <About />
            </Container>
          </Bg>
        </Div>
      </Div>
    </HomeProvider>
  )
}

export default Home
