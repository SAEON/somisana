import Header from '../../../modules/header'
import SiteSettings from './site-settings'

export default props => {
  return (
    <Header {...props}>
      <SiteSettings />
    </Header>
  )
}
