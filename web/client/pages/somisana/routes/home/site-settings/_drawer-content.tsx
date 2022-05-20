import { Suspense, lazy, forwardRef } from 'react'
import Loading from '../../../../../components/loading'
import Box from '@mui/material/Box'

const LanguageSettings = lazy(() => import('./language'))
const ThemeSettings = lazy(() => import('./theme'))
const CookieSettings = lazy(() => import('./cookies'))

const DrawerContent = forwardRef((props, ref) => {
  return (
    <Box ref={ref} {...props}>
      <Suspense fallback={<Loading />}>
        <LanguageSettings />
      </Suspense>
      <Suspense fallback={<Loading />}>
        <CookieSettings />
      </Suspense>
      <Suspense fallback={<Loading />}>
        <ThemeSettings />
      </Suspense>
    </Box>
  )
})

export default DrawerContent
