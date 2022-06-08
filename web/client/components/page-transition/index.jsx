import { Suspense } from 'react'
import Fade from '@mui/material/Fade'
import Loading from '../loading'

const Fallback = () => (
  <div style={{ height: 1000 }}>
    <Loading />
  </div>
)

export default ({ children, tKey }) => {
  window.scrollTo(0, 0)

  return (
    <Fade key={tKey} in={true}>
      <div style={{ position: 'relative', height: '100%' }}>
        <Suspense fallback={<Fallback />}>{children}</Suspense>
      </div>
    </Fade>
  )
}
