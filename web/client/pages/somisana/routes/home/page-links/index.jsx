import BoxButton from '../../../../../components/fancy-buttons/box-button'
import {
  Earth as EarthIcon,
  Database as DatabaseIcon,
  DataMatrix as DataMatrixIcon,
} from '../../../../../components/icons'
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
    <Grid justifyContent="center" container spacing={6} sx={{ mt: theme => theme.spacing(1) }}>
      <GridItem>
        <Title>Digital Earth</Title>
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
          <EarthIcon sx={{ width: '2em', height: '2em' }} />
        </Icon>

        <Content>
          Our ocean models are naturally bound by geographic coordinates. Explore our catalogue of
          offerings in 3D. Click on regions of interest to explore model features and advanced 3D
          data visualizations
        </Content>
        <BoxButton sx={{ height: 100 }} to={'/explore'} title={'Explore'} />
      </GridItem>

      <GridItem>
        <Title>High resolution data</Title>
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
          <DatabaseIcon sx={{ width: '2em', height: '2em' }} />
        </Icon>

        <Content>
          SAEON curates high-resolution bathymetry data along with ocean-current forecasts and
          hindcasts. Explore our publicly accessible datasets available for download or directly via
          our public OPeNDAP THREDDS server
        </Content>
        <BoxButton
          sx={{ height: 100 }}
          href="https://catalogue.saeon.ac.za/?referrer=somisana.ac.za"
          title={'Search'}
        />
      </GridItem>

      <GridItem>
        <Title>... Coming soon</Title>
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
          <DataMatrixIcon sx={{ width: '2em', height: '2em' }} />
        </Icon>

        <Content>
          This platforms aims to facilitate using South African science and research in an applied
          sense. Subscribe for updates to our platform and system (TODO)
        </Content>
        <BoxButton
          sx={{ height: 100 }}
          href="https://catalogue.saeon.ac.za/?referrer=somisana.ac.za"
          title={'Search'}
        />
      </GridItem>
    </Grid>
  )
}
