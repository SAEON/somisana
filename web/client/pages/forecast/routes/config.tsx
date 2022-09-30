import { Home } from '../../../components/icons'
import HomePage from './home'

export default [
  {
    to: '/*',
    path: '*',
    label: 'Home',
    Icon: Home,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => <HomePage {...props} />,
  },
]
