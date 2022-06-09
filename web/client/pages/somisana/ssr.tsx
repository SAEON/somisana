import RouteSwitcher from '../../modules/layout/route-switcher'
import Header from './header'
import routes from './routes/config'

export default () => {
  return (
    <>
      <Header routes={routes} />
      <RouteSwitcher routes={routes} />
    </>
  )
}
