import { Routes, Route } from 'react-router-dom'
import Home from './routes/home'
import PrivacyPolicy from '../../modules/privacy-policy'
import Header from './header'
import routes from './routes/config'

export default () => {
  return (
    <>
      <Header routes={routes} />
      <Routes>
        <Route path="/privacy-policy" element={<PrivacyPolicy />} />
        <Route path="*" element={<Home />} />
      </Routes>
    </>
  )
}
