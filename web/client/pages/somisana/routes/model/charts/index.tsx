import { useContext } from 'react'
import { context as pointDataContext } from '../point-data/_context'
import Grid from '@mui/material/Grid'

export default () => {
  const ctx = useContext(pointDataContext)
  return (
    <Grid container spacing={0}>
      <Grid item xs={12} md={6}>
        <pre>{JSON.stringify(ctx, null, 2)}</pre>
      </Grid>
      <Grid item xs={12} md={6}></Grid>
    </Grid>
  )
}
