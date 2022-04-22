import { hydrateRoot } from 'react-dom/client'
import ConfigProvider from '../config/index.js'

export default Page =>
  hydrateRoot(
    document.getElementById('root'),
    <ConfigProvider>
      <Page />
    </ConfigProvider>
  )
