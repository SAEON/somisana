import mount from '../../modules/app-entry/main.js'
import ConfigProvider from '../../modules/config/index.js'
import Button from '../../components/button/index.js'

export const Page = () => (
  <ConfigProvider>
    <Button>Algoa Bay</Button>
  </ConfigProvider>
)

export default () => mount(Page)
