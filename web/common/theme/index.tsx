import { useContext, useEffect } from 'react'
import { context as siteSettingsContext } from '../../client/modules/site-settings'
import { ThemeProvider } from '@mui/material/styles'

export default function Theme({ themes, ...props }) {
  const { colorScheme, updateSetting } = useContext(siteSettingsContext)
  useEffect(() => {
    const defaultSystemTheme =
      window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
        ? 'dark'
        : 'light'
    console.log(defaultSystemTheme, colorScheme)
    if (!colorScheme) {
      updateSetting({ colorScheme: defaultSystemTheme })
    }
  }, [])

  return <ThemeProvider theme={themes[colorScheme || 'light']} {...props} />
}
