import { lazy, Suspense } from 'react'
import { Linear as Loading } from '../../../../components/loading'
import Dialog from '@mui/material/Dialog'

const Form = lazy(() => import('./_lazy'))

export default ({ open, setOpen, from }) => {
  return (
    <Dialog onClose={() => setOpen(false)} open={open}>
      <Suspense fallback={<Loading />}>
        <Form from={from} />
      </Suspense>
    </Dialog>
  )
}
