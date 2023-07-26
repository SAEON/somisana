import Header from '../modules/header'
import Img from '../components/img'

export default props => {
  return (
    <Header {...props}>
      <Img
        sx={{
          height: 40,
          display: 'flex',
          padding: theme => theme.spacing(0.5),
          background: theme => theme.palette.common.white,
        }}
        src="/saeon-logo.png"
      ></Img>
    </Header>
  )
}
