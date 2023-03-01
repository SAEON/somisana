import RouteSwitcher from '../../modules/layout/route-switcher'
import Header, { LanguageSelector } from './header'
import routes from './routes/config'
import Footer from '../../modules/footer'
import Background from '../../modules/background'

export default () => {
  return (
    <Background>
      <Header routes={routes}>
        <LanguageSelector />
      </Header>
      <RouteSwitcher routes={routes} />
      <Footer routes={routes} />
    </Background>
  )
}
