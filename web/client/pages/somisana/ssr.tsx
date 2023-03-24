import RouteSwitcher from '../../modules/layout/route-switcher'
import Header, { LanguageSelector } from './header'
import routes from './routes/config'
import Footer from '../../modules/footer'
import Background from '../../modules/background'
import EgagasiniLogo from './header/egagasini-logo'
import Div from '../../components/div'

export default () => {
  return (
    <Background>
      <Header routes={routes}>
        <Div sx={{ display: 'flex', alignItems: 'center' }}>
          <EgagasiniLogo />
          <LanguageSelector />
        </Div>
      </Header>
      <RouteSwitcher routes={routes} />
      <Footer routes={routes} />
    </Background>
  )
}
