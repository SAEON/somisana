import Typography from '@mui/material/Typography'
import Breadcrumbs from '@mui/material/Breadcrumbs'
import { Link, useLocation } from 'react-router-dom'
import MuiIcon from '@mui/material/Icon'
import MuiLink from '@mui/material/Link'
import Span from '../../../components/span'

export default ({ contentBase = '/', routes }) => {
  const { pathname } = useLocation() // Trigger re-render on location changes
  const normalizedPathname = pathname.replace(contentBase, '/')

  const _pathname = normalizedPathname.match(/\/records\/./)
    ? ['', 'records', ...new Set(normalizedPathname.split('/records/'))].filter(_ => _)
    : [...new Set(normalizedPathname.split('/'))]

  const tree = _pathname.map((p, i, array) => {
    return {
      p,
      ...(routes.find(({ to }) => {
        if (!isNaN(parseInt(p))) {
          if (to.replace(contentBase, '').replace(':id', p) === `${array[i - 1]}/${p}`) {
            return true
          }
        }

        to = to.replace(contentBase, '').replace('/', '')
        return p === to
      }) || { label: `${i}` }),
    }
  })

  return (
    <Breadcrumbs aria-label="breadcrumb">
      {tree.length > 1 &&
        tree.slice(0, -1).map(({ label, Icon, BreadcrumbsIcon, breadcrumbsLabel, to }) => {
          Icon = BreadcrumbsIcon || Icon
          label = breadcrumbsLabel || label
          label = label?.replace('Home', 'SOMISANA') || label

          return (
            <Typography
              component={props => <MuiLink component={Link} {...props} />}
              key={label}
              to={
                to ||
                tree
                  .slice(1, -1)
                  .map(({ to, label }) => to || label)
                  .join('/')
              }
              sx={{
                display: 'flex',
                alignItems: 'center',
                '& .MuiSvgIcon-root': {
                  mt: '0 !important',
                  ml: '0 !important',
                  mb: '0 !important',
                },
              }}
            >
              {Icon && (
                <MuiIcon
                  sx={{ mr: theme => theme.spacing(0.5), width: '0.8em' }}
                  component={Icon}
                />
              )}
              <Span
                sx={theme => ({
                  display: 'none',
                  [theme.breakpoints.up('md')]: {
                    display: 'flex',
                  },
                })}
              >
                {label}
              </Span>
            </Typography>
          )
        })}

      {tree
        .slice(-1)
        .map(({ label, breadcrumbsLabel, BreadcrumbsLabel, Icon, BreadcrumbsIcon, p } = {}) => {
          Icon = BreadcrumbsIcon || Icon
          label = breadcrumbsLabel
            ? typeof breadcrumbsLabel === 'function'
              ? breadcrumbsLabel(p)
              : breadcrumbsLabel
            : label
          label = `${label || ''}`?.replace('Home', 'SOMISANA') || label

          return (
            <Typography
              key={label}
              sx={{
                display: 'flex',
                alignItems: 'center',
              }}
            >
              {Icon && (
                <MuiIcon
                  sx={{ mr: theme => theme.spacing(0.5), width: '0.8em' }}
                  component={Icon}
                />
              )}
              {BreadcrumbsLabel && <BreadcrumbsLabel pathname={p} />}
              {!BreadcrumbsLabel && label}
            </Typography>
          )
        })}
    </Breadcrumbs>
  )
}
