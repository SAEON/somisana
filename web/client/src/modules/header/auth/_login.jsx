import { useState, useEffect } from 'react'
import Typography from '@mui/material/Typography'
import Link from '@mui/material/Link'

export default () => {
  const [href, setHref] = useState('')

  // Client only
  useEffect(() => {
    setHref(`http://localhost:3000/http/login?redirect=${window.location.href}`)
  })

  return (
    <Typography href={href} component={Link} sx={{ margin: theme => `0 ${theme.spacing(1)}` }}>
      Log in
    </Typography>
  )
}
