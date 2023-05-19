import { useContext } from 'react'
import { context as homeContext } from '../_context'
import BoxButton from '../../../../../components/fancy-buttons/box-button'
import Div from '../../../../../components/div'
import { alpha } from '@mui/material/styles'
import Typography from '@mui/material/Typography'
import GridItem from '../components/grid-item'
import Grid from '@mui/material/Grid'
import { Linear as Loading } from '../../../../../components/loading'
import Link from '@mui/material/Link'
import Img from '../../../../../components/img'

export default () => {
  const { loading, data } = useContext(homeContext)

  if (loading) {
    return (
      <Div sx={{ position: 'relative' }}>
        <Loading />
      </Div>
    )
  }

  const models = data?.models || []

  const imageUrls = {
    1: '/algoa-bay-forecast-splash.jpg',
    2: '/sw-cape-forecast-splash.jpg',
  }

  return (
    <Grid
      justifyContent="center"
      container
      spacing={6}
      sx={{ marginTop: theme => theme.spacing(1) }}
    >
      {models.map(({ _id, title, description }) => {
        return (
          <GridItem md={6} key={_id}>
            <Typography
              textAlign="center"
              marginBottom={theme => theme.spacing(3)}
              color={theme => alpha(theme.palette.common.black, 0.9)}
              variant={'h3'}
              textTransform="uppercase"
            >
              {title}
            </Typography>

            <Img
              sx={{ width: '100%', boxShadow: theme => theme.shadows[3] }}
              src={imageUrls[_id]}
            />

            <Typography
              flexGrow={1}
              marginTop={theme => theme.spacing(3)}
              marginBottom={theme => theme.spacing(3)}
              color={theme => alpha(theme.palette.common.black, 0.9)}
              textAlign="left"
              variant="body2"
            >
              {description}
            </Typography>

            <BoxButton sx={{ height: 100 }} to={`/explore/${_id}`} title={'Go'} />
          </GridItem>
        )
      })}
    </Grid>
  )
}
