import { useState, useContext, useEffect, lazy, Suspense } from 'react'
import { ctx as siteSettingsContext } from '../../site-settings'
import { Cog } from '../../../components/icons'
import MuiIcon from '@mui/material/Icon'
import Typography from '@mui/material/Typography'
import MuiLink from '@mui/material/Link'

const SettingPanel = lazy(() => import('../../site-settings/settings-panel'))

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
          mr: theme => theme.spacing(1),
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
      {open && (
        <Suspense fallback={null}>
          <SettingPanel forceLanguage={false} open={open} setOpen={setOpen} />
        </Suspense>
      )}
    </>
  )
}

export default SiteSettingsPanel
