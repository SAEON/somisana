import { useContext } from 'react'
import { context as modelContext } from '../_context'
import Typography from '@mui/material/Typography'
import Link from '@mui/material/Link'

export default () => {
  const {
    run,
    model: { title },
  } = useContext(modelContext)
  return (
    <>
      <Typography
        sx={{
          textAlign: 'center',
        }}
        gutterBottom
        variant="h1"
      >
        {title}
      </Typography>
      <Typography
        marginBottom={theme => theme.spacing(4)}
        variant="subtitle1"
        sx={{ textAlign: 'center', fontStyle: 'italic' }}
      >
        <Link target="_blank" rel="noopener noreferrer" href="https://www.croco-ocean.org/">
          Coastal and Regional Ocean COmmunity model
        </Link>
        : {run.run_date}
      </Typography>
    </>
  )
}
