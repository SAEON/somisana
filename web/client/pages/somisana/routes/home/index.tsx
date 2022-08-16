import { useRef } from 'react'
import Title from './title'
import Div from '../../../../components/div'
import ScrollButton from './_scroll-button'
import Container_ from '@mui/material/Container'
import { alpha } from '@mui/system/colorManipulator'
import Typography from '@mui/material/Typography'

const Container = props => <Container_ sx={{ py: theme => theme.spacing(8) }} {...props} />

const Bg = ({ sx = {}, ...props }) => (
  <Div
    sx={{
      pb: theme => theme.spacing(6),
      ...sx,
    }}
    {...props}
  />
)

const Heading = props => (
  <Typography
    variant="h4"
    sx={{
      textAlign: 'center',
      mt: theme => theme.spacing(3),
      mb: theme => theme.spacing(6),
      color: theme => alpha(theme.palette.common.black, 0.9),
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
        <Bg sx={{ backgroundColor: theme => alpha(theme.palette.common.black, 0.4) }}>
          <Container>
            <Heading>Our Work</Heading>
            Coming soon...
            {/* Forecast models, hindcast models, regional models, high resolution bathymetry, product
            explorer (map), event alerts? use fancy buttons! */}
          </Container>
        </Bg>
      </Div>
    </Div>
  )
}

export default Home
