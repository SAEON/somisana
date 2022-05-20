import { useState, useContext, useEffect } from 'react'
import { ctx as siteSettingsContext, SettingPanel } from '../../../../../modules/site-settings'
import Tooltip from '@mui/material/Tooltip'
import IconButton from '@mui/material/IconButton'
import { Cog } from '../../../../../components/icons'

const SiteSettingsPanel = () => {
  const { updateSetting, ...settings } = useContext(siteSettingsContext)
  const [open, setOpen] = useState(false)

  useEffect(() => {
    if (!settings.accepted) {
      setOpen(true)
    }
  }, [settings.accepted])

  return (
    <>
      {/* TOGGLE DRAWER */}
      <Tooltip placement="left" title="Site settings">
        <IconButton
          onClick={() => setOpen(true)}
          size="medium"
          sx={{ position: 'absolute', bottom: 0, right: 0, margin: theme => theme.spacing(2) }}
        >
          <Cog />
        </IconButton>
      </Tooltip>

      {/* DRAWER */}
      <SettingPanel open={open} setOpen={setOpen} />
    </>
  )
}

export default SiteSettingsPanel
