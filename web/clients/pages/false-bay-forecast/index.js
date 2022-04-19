import ConfigProvider from '../../modules/config/index.js'
import mount from '../../modules/app-entry/main.js'

const App = () => (
  <ConfigProvider>
    <div>False bay</div>
  </ConfigProvider>
)

mount(App)
