import { Routes, Route } from 'react-router-dom'
import Home from './routes/home/index.js'

export default () => {
  return (
    <Routes>
      <Route path="*" element={<Home />} />
    </Routes>
  )
}
