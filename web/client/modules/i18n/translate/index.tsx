import { useContext, useState, useEffect, lazy, Suspense } from 'react'
import { ctx as i18nContext } from '../index'
import Box from '@mui/material/Box'

const Form = lazy(() => import('./form'))

export default ({ contentId }) => {
  const [open, setOpen] = useState(false)
  const [isClient, setIsClient] = useState(false)
  const { t, language } = useContext(i18nContext)
  const { text, missing } = t(contentId, language)

  useEffect(() => {
    setIsClient(true)
  }, [])

  return (
    <>
      <Box
        component={'span'}
        onClick={missing && isClient ? () => setOpen(!open) : () => null}
        sx={
          missing && isClient
            ? {
                position: 'relative',
                outline: theme => `thin dotted ${theme.palette.success.main}`,
                cursor: 'pointer',
                transition: theme => theme.transitions.create(['background-color']),
                '&:hover': {
                  backgroundColor: theme => theme.palette.grey[100],
                },
              }
            : {}
        }
      >
        {text}
      </Box>

      {/* CONTENT TRANSLATION */}
      {missing && isClient && (
        <Suspense fallback={null}>
          <Form from={text} open={open} setOpen={setOpen} />
        </Suspense>
      )}
    </>
  )
}
