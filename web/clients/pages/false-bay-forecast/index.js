import ConfigProvider from '../../modules/config/index.js'
import mount from '../../modules/app-entry/main.js'

export const Page = () => (
  <ConfigProvider>
    <div>False bay</div>
  </ConfigProvider>
)

export default () => mount(Page)
