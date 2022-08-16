import { forwardRef } from 'react'
import { keyframes } from '@mui/material/styles'
import styled from '@mui/material/styles/styled'
import { alpha } from '@mui/system/colorManipulator'
import ButtonBase from '@mui/material/ButtonBase'

const animation = keyframes`
  0% {
    opacity: 0;
  }
  30% {
    opacity: 1;
  }
  100% {
    opacity: 0;
  }
`

const Button = styled(ButtonBase)(({ theme }) => ({
  cursor: 'pointer',
  display: 'block',
  left: '50%',
  zIndex: 2,
  transform: 'translate(0, -50%)',
  color: theme.palette.common.black,
  transition: theme.transitions.create('opacity'),
}))

const StyledSpan = styled('span')(({ theme }) => ({
  position: 'absolute',
  top: 0,
  left: '50%',
  width: 24,
  height: 24,
  marginLeft: -12,
  borderLeft: `1px solid ${alpha(theme.palette.common.black, 0.9)}`,
  borderBottom: `1px solid ${alpha(theme.palette.common.black, 0.9)}`,
  transform: 'rotate(-45deg)',
  animation: `${animation} 1.5s infinite`,
  boxSizing: 'border-box',
}))

export default forwardRef(({ sx = {}, onClick, ...otherProps }, ref) => {
  return (
    <Button
      sx={{
        ':hover': {
          opacity: '0.5 !important',
        },
        ...sx,
      }}
      ref={ref}
      onClick={onClick || undefined}
      {...otherProps}
    >
      <StyledSpan />
    </Button>
  )
})
