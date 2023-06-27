import { useContext, useEffect } from 'react'
import { context as siteSettingsContext } from '../../client/modules/site-settings'
import { ThemeProvider } from '@mui/material/styles'

export default function Theme({ themes, ...props }) {
  const { colorScheme, updateSetting } = useContext(siteSettingsContext)

  // Client-side only
  useEffect(() => {
    if (!colorScheme) {
      updateSetting({
        colorScheme:
          window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
            ? 'dark'
            : 'light',
      })
    }
  }, [])

  return <ThemeProvider theme={themes[colorScheme || 'light']} {...props} />
}
