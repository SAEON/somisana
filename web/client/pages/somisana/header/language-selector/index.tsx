import { useContext, useState, useEffect } from 'react'
import { ctx as siteSettingsContext, SettingPanel } from '../../../../modules/site-settings'
import Button from '@mui/material/Button'

export default () => {
  const [shouldRender, setShouldRender] = useState(false)
  const [open, setOpen] = useState(false)
  const { language } = useContext(siteSettingsContext)

  const flags = {
    en: 'za',
  }

  // TODO context is undefined in SSR environment
  useEffect(() => setShouldRender(true))

  if (shouldRender) {
    const flag = flags[language] || 'za'

    return (
      <>
        <Button
          onClick={() => setOpen(!open)}
          variant="text"
          sx={{ '& > img': { mr: 1, flexShrink: 0 } }}
        >
          <img
            loading="lazy"
            width="20"
            src={`https://flagcdn.com/w20/${flag}.png`}
            srcSet={`https://flagcdn.com/w40/${flag}.png 2x`}
            alt=""
          />
          {language.toUpperCase()}
        </Button>

        <SettingPanel forceLanguage open={open} setOpen={setOpen} />
      </>
    )
  }

  return null
}
