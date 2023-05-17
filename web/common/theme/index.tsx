import { useContext } from 'react'
import { context as siteSettingsContext } from '../../client/modules/site-settings'
import { ThemeProvider } from '@mui/material/styles'

export default function Theme({ themes, ...props }) {
  const { colorScheme } = useContext(siteSettingsContext)
  return <ThemeProvider theme={themes[colorScheme]} {...props} />
}
