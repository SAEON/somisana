import RouteSwitcher from '../../modules/layout/route-switcher'
import Header from './header'
import routes from './routes/config'
import Footer from '../../modules/footer'
import Background from '../../modules/background'
import Div from '../../components/div'

export default () => {
  return (
    <Background>
      <Header routes={routes}>
        <Div sx={{ display: 'flex', alignItems: 'center' }}></Div>
      </Header>
      <RouteSwitcher routes={routes} />
      <Footer routes={routes} />
    </Background>
  )
}
