import { useRef, memo } from 'react'
import Title from './title'
import Div from '../../../../components/div'
import { alpha } from '@mui/system/colorManipulator'
import ForecastModels from './forecast-models'
import ModelsProvider from './_context'
import ScrollButton from './_scroll-button'
import Content from './content'

const Home = memo(() => {
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
        <ForecastModels />
        {/* <ScrollButton contentRef={ref} /> */}
      </Div>

      {/* CONTENT */}
      {/* <Content ref={ref} /> */}
    </Div>
  )
})

export default () => {
  return (
    <ModelsProvider>
      <Home />
    </ModelsProvider>
  )
}
