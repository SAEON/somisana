import { Home } from '../../../components/icons'
import HomePage from './home'
import Div from '../../../components/div'

export default [
  {
    to: '/*',
    path: '*',
    label: 'Home',
    Icon: Home,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => (
      <Div
        sx={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'flex-start',
          flexGrow: 1,
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        <HomePage {...props} />
      </Div>
    ),
  },
]