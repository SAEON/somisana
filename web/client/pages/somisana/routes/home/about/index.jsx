import BoxButton from '../../../../../components/fancy-buttons/box-button'
import { About as AboutIcon } from '../../../../../components/icons'
import Icon from '@mui/material/Icon'
import { alpha, styled } from '@mui/material/styles'
import Typography from '@mui/material/Typography'
import GridItem from '../components/grid-item'
import Grid from '@mui/material/Grid'

{
  /* Forecast models, hindcast models, regional models, high resolution bathymetry, product
            explorer (map), event alerts? use fancy buttons! */
}

const Text_ = styled(Typography)(({ theme }) => ({
  color: alpha(theme.palette.common.white, 0.9),
}))

const Title = props => (
  <Text_ textAlign="center" fontSize="1rem" variant={'h3'} textTransform="uppercase" {...props} />
)

const Content = props => (
  <Text_
    flexGrow={1}
    marginBottom={theme => theme.spacing(6)}
    textAlign="left"
    variant="body2"
    {...props}
  />
)

export default () => {
  return (
    <Grid
      justifyContent="center"
      container
      spacing={6}
      sx={{ marginTop: theme => theme.spacing(1) }}
    >
      <GridItem>
        <Title>About us</Title>
        <Icon
          sx={theme => ({
            color: alpha(theme.palette.common.white, 0.9),
            margin: theme.spacing(3),
            marginBottom: theme.spacing(4),
            display: 'flex',
            alignContent: 'center',
            justifyContent: 'center',
            height: 'unset',
            width: 'unset',
          })}
        >
          <AboutIcon sx={{ width: '2em', height: '2em' }} />
        </Icon>

        <Content>TODO</Content>
        <BoxButton sx={{ height: 100 }} to={'/about'} title={'More ...'} />
      </GridItem>
      <GridItem>
        <Title>TODO ...</Title>
      </GridItem>
    </Grid>
  )
}
