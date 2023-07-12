import { styled } from '@mui/material/styles'
import Box from '@mui/material/Box'
import ButtonBase from '@mui/material/ButtonBase'
import Typography from '@mui/material/Typography'
import { Link } from 'react-router-dom'
import Div from '../../div'

const ImageButton = styled(props => <ButtonBase LinkComponent={Link} {...props} />)(
  ({ theme }) => ({
    position: 'relative',
    height: '100%',
    borderRadius: `${theme.shape.borderRadius}px`,
    [theme.breakpoints.down('sm')]: {
      width: '100% !important', // Overrides inline-style
    },
    '&:hover, &.Mui-focusVisible': {
      zIndex: 1,
      '& .MuiImageBackdrop-root': {
        opacity: 0.15,
      },
      '& .MuiImageMarked-root': {
        opacity: 0,
      },
      '& .MuiTypography-root': {
        borderTop: `4px solid transparent`,
        borderBottom: '4px solid currentColor',
      },
    },
  })
)

const ImageSrc = styled('span')(({ theme }) => ({
  position: 'absolute',
  left: 0,
  right: 0,
  top: 0,
  bottom: 0,
  backgroundSize: 'cover',
  backgroundPosition: 'center 40%',
  borderRadius: `${theme.shape.borderRadius}px`,
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
  borderRadius: `${theme.shape.borderRadius}px`,
}))

const ImageBackdrop = styled('span')(({ theme }) => ({
  position: 'absolute',
  left: 0,
  right: 0,
  top: 0,
  bottom: 0,
  backgroundColor: theme.palette.common.black,
  borderRadius: `${theme.shape.borderRadius}px`,
  opacity: 0.4,
  transition: theme.transitions.create('opacity'),
}))

const ImageMarked = styled('span')(({ theme }) => ({
  height: 4,
  width: 18,
  backgroundColor: theme.palette.common.white,
  position: 'absolute',
  bottom: -4,
  left: 'calc(50% - 9px)',
  transition: theme.transitions.create('opacity'),
}))

export default styled(({ image, to, ...props }) => {
  return (
    <Div {...props}>
      <Box
        sx={{
          display: 'flex',
          flexWrap: 'wrap',
          minWidth: 250,
          width: '100%',
          height: '100%',
          borderRadius: theme => `${theme.shape.borderRadius}px`,
        }}
      >
        <ImageButton
          to={to}
          focusRipple
          key={image.title}
          style={{
            width: image.width,
          }}
        >
          <ImageSrc style={{ backgroundImage: `url(${image.url})` }} />
          <ImageBackdrop className="MuiImageBackdrop-root" />
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
              {image.title}
              <ImageMarked className="MuiImageMarked-root" />
            </Typography>
          </Image>
        </ImageButton>
      </Box>
    </Div>
  )
})({})
