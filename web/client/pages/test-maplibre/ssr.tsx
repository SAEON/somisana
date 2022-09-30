import Map from './map'
import Div from '../../components/div'

export default () => {
  return (
    <Div sx={{ position: 'fixed', top: 0, bottom: 0, left: 0, right: 0 }}>
      <Map />
    </Div>
  )
}
