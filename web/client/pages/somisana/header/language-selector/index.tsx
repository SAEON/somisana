import { useContext, useState, useEffect } from 'react'
import { ctx as siteSettingsContext, SettingPanel } from '../../../../modules/site-settings'
import Box from '@mui/material/Box'

export default () => {
  const [shouldRender, setShouldRender] = useState(false)
  const [open, setOpen] = useState(false)
  const { locale } = useContext(siteSettingsContext)

  useEffect(() => setShouldRender(true))


  if (shouldRender) {
    
    return  <>
    <Box
      onClick={() => setOpen(!open)}
      component="li"
      sx={{ '& > img': { mr: 2, flexShrink: 0 } }}
    >
      <img
        loading="lazy"
        width="20"
        src={`https://flagcdn.com/w20/${locale.code.split('_')[1].toLowerCase()}.png`}
        srcSet={`https://flagcdn.com/w40/${locale.code.split('_')[1].toLowerCase()}.png 2x`}
        alt=""
      />
      {locale.language.toUpperCase()}
    </Box>

    <SettingPanel open={open} setOpen={setOpen} />
  </>
  }

  return null

}
