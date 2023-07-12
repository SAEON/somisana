import { useContext } from 'react'
import { context as homeContext } from '../_context'
import ImageButton from '../../../../../components/fancy-buttons/image-button'
import Div from '../../../../../components/div'
import { Circular as Loading } from '../../../../../components/loading'
import Fade from '@mui/material/Fade'

const imageUrls = {
  1: '/algoa-bay-forecast-splash.jpg',
  2: '/sw-cape-forecast-splash.jpg',
}

export default () => {
  const { loading, data } = useContext(homeContext)
  const models = data?.models || []

  return (
    <Div
      sx={{
        position: 'absolute',
        left: 0,
        bottom: 0,
        maxWidth: '100%',
        height: '150px',
        display: 'flex',
        padding: theme => `0 ${theme.spacing(2)}`,
        '& .image-button': {
          marginRight: theme => theme.spacing(2),
          boxShadow: theme => theme.shadows[3],
          border: theme => `1px solid ${theme.palette.common.white}`,
          borderRadius: theme => `${theme.shape.borderRadius}px`,
        },
      }}
    >
      {!data && (
        <Fade in={Boolean(!data)} key="loading" unmountOnExit>
          <Div
            sx={{
              display: 'flex',
              alignItems: 'flex-end',
              paddingBottom: theme => theme.spacing(2),
            }}
          >
            <Loading size={60} color="primary" />
          </Div>
        </Fade>
      )}
      {data && (
        <Fade in={Boolean(data)} key="models" unmountOnExit>
          <Div
            sx={{
              display: 'flex',
              overflowX: 'auto',
              paddingBottom: theme => theme.spacing(1),
              marginBottom: theme => theme.spacing(1),
            }}
          >
            {models.map(({ _id, title }) => {
              return (
                <ImageButton
                  className="image-button"
                  sx={{
                    borderRadius: theme => `${theme.shape.borderRadius}px`,
                  }}
                  key={_id}
                  image={{
                    url: imageUrls[_id],
                    title,
                    width: '100%',
                  }}
                  to={`/explore/${_id}`}
                />
              )
            })}
          </Div>
        </Fade>
      )}
    </Div>
  )
}
