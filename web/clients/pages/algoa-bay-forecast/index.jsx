import ConfigProvider from '../../modules/config/index.jsx'
import mount from '../../modules/app-entry/main.js'

const App = () => (
  <ConfigProvider>
    <div>Hello world</div>
  </ConfigProvider>
)

mount(App)
