import { cloneElement } from 'react'
import useScrollTrigger from '@mui/material/useScrollTrigger'

export default ({ children }) => {
  const trigger = useScrollTrigger({
    disableHysteresis: true,
    threshold: 0,
  })

  return cloneElement(children, {
    variant: trigger ? 'elevation' : 'outlined',
    elevation: trigger ? 4 : 0,
  })
}
