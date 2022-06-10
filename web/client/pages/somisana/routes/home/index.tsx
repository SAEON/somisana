import Title from './title'
import Div from '../../../../components/div'

const Home = () => {
  return (
    <Div sx={{ height: 'calc(100vh - 48px)', display: 'flex', flex: 1 }}>
      <Title />
    </Div>
  )
}

export default Home
