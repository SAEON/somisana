import Login from './_login'
import Logout from './_logout'
import Div from '../../../components/div'

export default () => {
  return (
    <Div
      sx={{
        marginLeft: 'auto',
        borderLeft: theme => `1px solid ${theme.palette.divider}`,
        padding: theme => theme.spacing(1),
      }}
    >
      <Login />
    </Div>
  )
}
