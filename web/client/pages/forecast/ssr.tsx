import RouteSwitcher from '../../modules/layout/route-switcher'
import routes from './routes/config'

export default () => {
  return (
    <>
      <RouteSwitcher routes={routes} />
    </>
  )
}
