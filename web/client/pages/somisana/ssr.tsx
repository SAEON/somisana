import { Routes, Route } from 'react-router-dom'
import Home from './routes/home'
import PrivacyPolicy from '../../modules/privacy-policy'

export default () => {
  return (
    <Routes>
      <Route path="/privacy-policy" element={<PrivacyPolicy />} />
      <Route path="*" element={<Home />} />
    </Routes>
  )
}
