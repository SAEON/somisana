import { useState, useContext, useEffect } from 'react'
import { context as siteSettingsContext } from '../../site-settings'
import SettingsPanel from '../../site-settings/settings-panel'
import { Cog } from '../../../components/icons'
import MuiIcon from '@mui/material/Icon'
import Typography from '@mui/material/Typography'
import MuiLink from '@mui/material/Link'

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
      <MuiIcon
        sx={{
          marginRight: theme => theme.spacing(1),
          color: theme => theme.palette.common.white,
        }}
        component={Cog}
        fontSize="small"
      />
      <Typography
        component={props => (
          <MuiLink
            sx={{
              color: theme => (open ? theme.palette.primary.main : theme.palette.common.white),
              cursor: 'pointer',
            }}
            {...props}
            to={undefined}
            key={'site-settings'}
            onClick={() => setOpen(!open)}
          >
            Site settings
          </MuiLink>
        )}
        variant="overline"
      >
        Site settings
      </Typography>

      {/* DRAWER */}
      <SettingsPanel forceLanguage={false} open={open} setOpen={setOpen} />
    </>
  )
}

export default SiteSettingsPanel
