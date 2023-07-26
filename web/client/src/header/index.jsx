import Header from '../modules/header'
import Img from '../components/img'
import { alpha } from '@mui/material'

export default props => {
  return (
    <Header {...props}>
      <Img
        sx={{
          height: 40,
          display: 'flex',
          padding: theme => theme.spacing(0.5),
        }}
        src="/saeon-logo.png"
      ></Img>
    </Header>
  )
}
