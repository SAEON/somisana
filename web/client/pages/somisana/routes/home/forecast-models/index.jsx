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

{
  /* Forecast models
     regional models,
     high resolution bathymetry,
    */
}

export default () => {
  const { loading, data } = useContext(homeContext)

  if (loading) {
    return (
      <Div sx={{ position: 'relative' }}>
        <Loading />
      </Div>
    )
  }

  const models = data.models

  return (
    <Grid justifyContent="center" container spacing={6} sx={{ mt: theme => theme.spacing(1) }}>
      {models.map(({ _id, title, description, creator, creatorContactEmail }) => {
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

            <Typography
              flexGrow={1}
              marginBottom={theme => theme.spacing(3)}
              color={theme => alpha(theme.palette.common.black, 0.9)}
              textAlign="left"
              variant="body2"
            >
              {description}
            </Typography>

            <Typography
              variant="overline"
              marginBottom={theme => theme.spacing(3)}
              sx={{ placeSelf: 'flex-start' }}
            >
              <Link href={`mailto:${creatorContactEmail}`}>{creator}</Link>
            </Typography>
            <BoxButton sx={{ height: 100 }} to={`/explore/${_id}`} title={'Go'} />
          </GridItem>
        )
      })}
    </Grid>
  )
}
