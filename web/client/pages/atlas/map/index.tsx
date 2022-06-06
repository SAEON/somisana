import Ol from './_ol'
import OSM from './layers/open-street-maps'
// import TerrestrisBaseMap from './layers/terrestris-base-map'
import Attribution from './_attribution'

export default () => {
  return <Ol Attribution={Attribution} layers={[OSM()]} />
}
