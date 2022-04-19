import ConfigProvider from '../../modules/config/index.js'
import mount from '../../entry-point/main.js'

const App = () => (
  <ConfigProvider>
    <div>False bay 2</div>
  </ConfigProvider>
)

mount(App)
