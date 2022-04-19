import mount from '../../modules/app-entry/main.js'
import ConfigProvider from '../../modules/config/index.js'
import Button from '../../components/button/index.js'

const App = () => (
  <ConfigProvider>
    <Button>Algoa Bay</Button>
  </ConfigProvider>
)

mount(App)
