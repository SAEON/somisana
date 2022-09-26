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
  <Container_ sx={{ py: theme => theme.spacing(8), position: 'relative' }} {...props} />
)

const Bg = ({ sx = {}, ...props }) => (
  <Div
    sx={{
      pb: theme => theme.spacing(6),
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
      mt: theme => theme.spacing(3),
      mb: theme => theme.spacing(6),
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
          <Bg sx={{ backgroundColor: theme => theme.palette.primary.dark }}>
            <Container>
              <Heading color="white">Our Work</Heading>
              <PageLinks />
            </Container>
          </Bg>

          {/* FORECAST MODELS */}
          <Bg sx={{ backgroundColor: theme => theme.palette.grey[100] }}>
            <Container>
              <Heading color="black">Forecast Models</Heading>
              <ForecastModels />
            </Container>
          </Bg>

          {/* ABOUT US */}
          <Bg sx={{ backgroundColor: theme => theme.palette.primary.main }}>
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
