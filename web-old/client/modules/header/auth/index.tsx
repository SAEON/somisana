import Login from './_login'
import UserMenu from './user-menu'
import Div from '../../../components/div'

export default () => {
  return (
    <Div
      sx={{
        marginLeft: 'auto',
        borderLeft: theme => `1px solid ${theme.palette.divider}`,
        padding: theme => `0 0 0 ${theme.spacing(1)}`,
      }}
    >
      {/* <Login /> */}
      {/* <UserMenu /> */}
    </Div>
  )
}
