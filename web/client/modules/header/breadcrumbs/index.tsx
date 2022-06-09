import Typography from '@mui/material/Typography'
import Breadcrumbs from '@mui/material/Breadcrumbs'
import { Link, useLocation } from 'react-router-dom'
import MuiIcon from '@mui/material/Icon'
import MuiLink from '@mui/material/Link'

const sxIcon = {
  marginRight: theme => theme.spacing(0.5),
  width: 18,
  height: 18,
}

const sxLink = {
  display: 'flex',
  alignItems: 'center',
}

export default ({ contentBase = '/', routes }) => {
  const { pathname } = useLocation() // Trigger re-render on location changes
  const normalizedPathname = pathname.replace(contentBase, '/')

  const _pathname = normalizedPathname.match(/\/records\/./)
    ? ['', 'records', ...new Set(normalizedPathname.split('/records/')).filter(_ => _)]
    : [...new Set(normalizedPathname.split('/'))]

  const tree = _pathname.map(p => {
    return (
      routes.find(({ to }) => {
        to = to.replace(contentBase, '').replace('/', '')
        return to === p
      }) || { label: p?.titleize() || '404 (Not found)' }
    )
  })

  return (
    <Breadcrumbs aria-label="breadcrumb">
      {tree.length > 1 &&
        tree.slice(0, -1).map(({ label, Icon, BreadcrumbsIcon, breadcrumbsLabel, to }) => {
          Icon = BreadcrumbsIcon || Icon
          label = breadcrumbsLabel || label

          return (
            <MuiLink
              component={Link}
              key={label}
              color="inherit"
              to={
                to ||
                tree
                  .slice(1, -1)
                  .map(({ to, label }) => to || label)
                  .join('/')
              }
              sx={sxLink}
            >
              {Icon && <MuiIcon sx={sxIcon} size={18} component={Icon} />}
              {label}
            </MuiLink>
          )
        })}

      {tree.slice(-1).map(({ label, breadcrumbsLabel, Icon, BreadcrumbsIcon } = {}) => {
        Icon = BreadcrumbsIcon || Icon
        label = breadcrumbsLabel || label

        return (
          <Typography key={label} color="textPrimary" sx={sxLink}>
            {Icon && <MuiIcon sx={sxIcon} size={18} component={Icon} />}
            {label}
          </Typography>
        )
      })}
    </Breadcrumbs>
  )
}
