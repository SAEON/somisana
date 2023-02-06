import { Suspense, lazy, forwardRef } from 'react'
import { Linear as Loading } from '../../../components/loading'
import Box from '@mui/material/Box'

const LanguageSettings = lazy(() => import('./language'))
const ThemeSettings = lazy(() => import('./theme'))
const CookieSettings = lazy(() => import('./cookies'))

const StyledLoading = () => {
  return (
    <Loading
      sx={theme => ({
        [theme.breakpoints.up('sm')]: {
          display: 'block',
          width: 400,
        },
      })}
    />
  )
}

const DrawerContent = forwardRef(({ forceLanguage, ...props }, ref) => {
  return (
    <Box ref={ref} {...props}>
      <Suspense fallback={<StyledLoading />}>
        <LanguageSettings forceLanguage={forceLanguage} />
      </Suspense>
      <Suspense fallback={<StyledLoading />}>
        <CookieSettings />
      </Suspense>
      {/* <Suspense fallback={<StyledLoading />}>
        <ThemeSettings />
      </Suspense> */}
    </Box>
  )
})

export default DrawerContent
