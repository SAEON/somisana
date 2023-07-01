import { useContext, useEffect } from 'react'
import { context as siteSettingsContext } from  '../modules/site-settings'
import { ThemeProvider } from '@mui/material/styles'

export default function Theme({ themes, ...props }) {
  const { colorScheme, updateSetting } = useContext(siteSettingsContext)

  useEffect(() => {
    if (!colorScheme) {
      updateSetting({
        colorScheme:
          window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
            ? 'dark'
            : 'light',
      })
    }
  }, [colorScheme, updateSetting])

  return <ThemeProvider theme={themes[colorScheme || 'light']} {...props} />
}
