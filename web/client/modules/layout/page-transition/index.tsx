import { useEffect } from 'react'
import Fade from '@mui/material/Fade'
import Div from '../../../components/div'

export default ({ children, tKey }) => {
  useEffect(() => window.scrollTo(0, 0))

  return (
    <Fade key={tKey} in={true}>
      <Div
        sx={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'flex-start',
          flexGrow: 1,
          position: 'relative',
        }}
      >
        {children}
      </Div>
    </Fade>
  )
}
