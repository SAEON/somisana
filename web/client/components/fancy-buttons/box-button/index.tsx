import styled from '@mui/material/styles/styled'
import { alpha } from '@mui/system/colorManipulator'
import ButtonBase from '@mui/material/ButtonBase'
import Typography from '@mui/material/Typography'
import { Link } from 'react-router-dom'
import Div from '../../div'

const Button = styled(ButtonBase)(({ theme }) => ({
  display: 'flex',
  width: '100%',
  height: '100%',
  position: 'relative',
  [theme.breakpoints.down('sm')]: {
    width: '100% !important',
    height: 100,
  },
  '& .MuiTypography-root': {
    outline: '2px solid transparent',
  },
  '&:hover, &.Mui-focusVisible': {
    zIndex: 1,
    '& .MuiFancyButtonBackdrop-root': {
      opacity: 0.15,
    },
    '& .MuiFancyButtonMarked-root': {
      opacity: 0,
    },
    '& .MuiTypography-root': {
      outline: '2px solid currentColor',
    },
  },
  transition: theme.transitions.create(['border']),
  border: `1px solid ${alpha(theme.palette.common.white, 0.5)}`,
  '&:hover': {
    border: `2px solid ${alpha(theme.palette.common.white, 0.1)}`,
  },
}))

const Image = styled('span')(({ theme }) => ({
  position: 'absolute',
  left: 0,
  right: 0,
  top: 0,
  bottom: 0,
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  color: theme.palette.common.white,
}))

const Backdrop = styled('span')(({ theme }) => ({
  position: 'absolute',
  left: 0,
  right: 0,
  top: 0,
  bottom: 0,
  backgroundColor: theme.palette.common.black,
  opacity: 0.4,
  transition: theme.transitions.create('opacity'),
}))

const Mark = styled('span')(({ theme }) => ({
  height: 2,
  width: 18,
  backgroundColor: theme.palette.common.white,
  position: 'absolute',
  bottom: -2,
  left: 'calc(50% - 9px)',
  transition: theme.transitions.create('opacity'),
}))

const FancyButton = ({
  title,
  disabled = false,
  href = undefined,
  onClick = undefined,
  to = '/records',
  ...props
}) => {
  return (
    <Div sx={{ width: '100%', height: '100%' }} {...props}>
      <Button
        component={onClick || href ? undefined : Link}
        href={href}
        onClick={onClick}
        to={onClick ? undefined : href ? undefined : to}
        disabled={disabled}
        focusRipple
        className="MuiFancyButton-root"
      >
        <Backdrop className="MuiFancyButtonBackdrop-root" />
        <Image>
          <Typography
            component="span"
            variant="subtitle1"
            color="inherit"
            sx={{
              position: 'relative',
              p: 4,
              pt: 2,
              pb: theme => `calc(${theme.spacing(1)} + 6px)`,
            }}
          >
            {title}
            <Mark className="MuiFancyButtonMarked-root" />
          </Typography>
        </Image>
      </Button>
    </Div>
  )
}

export default styled(FancyButton)({})
