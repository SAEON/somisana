import ConfigProvider from '../../modules/config/index.js'
import Counter from '../../modules/counter/index.js'

export default () => {

  return <Counter />
  return (
    <ConfigProvider>
      <Counter />
    </ConfigProvider>
    )
}
