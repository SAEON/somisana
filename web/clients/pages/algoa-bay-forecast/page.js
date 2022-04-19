import ConfigProvider from '../../modules/config/index.js'
import Counter from '../../modules/counter/index.js'

export default () => (
  <ConfigProvider>
    <Counter />
  </ConfigProvider>
)