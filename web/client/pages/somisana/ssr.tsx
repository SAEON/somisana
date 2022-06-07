import { Routes, Route } from 'react-router-dom'
import Home from './routes/home'
import PrivacyPolicy from '../../modules/privacy-policy'
import Header from './header'

export default () => {
  return (
    <>
      <Header />
      <Routes>
        <Route path="/privacy-policy" element={<PrivacyPolicy />} />
        <Route path="*" element={<Home />} />
      </Routes>
    </>
  )
}
