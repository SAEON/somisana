import mount from '../../entry-point/main.js'
import Button from '../../components/button/index.js'
import ConfigProvider from '../../modules/config/index.js'

const App = () => (
  <ConfigProvider>
    <Button>Algoa Bay 2</Button>
  </ConfigProvider>
)

mount(App)
