import { useState, lazy, Suspense, useEffect } from 'react'
import { Linear as Loading } from '../../components/loading'
import Div from '../../components/div'
import { Typography, Button } from '@mui/material'
import { useSnackbar } from 'notistack'
import Img from '../../components/img'

const Map = lazy(() => import('./map'))

export default () => {
  const { enqueueSnackbar } = useSnackbar()
  const [ref, setRef] = useState(null)

  useEffect(() => {
    enqueueSnackbar(
      `Welcome to the SOMISANA visualization tools. Click a region to explore high resolution, operational data.`,
      {
        variant: 'info',
        anchorOrigin: {
          horizontal: 'center',
          vertical: 'bottom',
        },
      }
    )
  }, [enqueueSnackbar])

  return (
    <Div
      sx={{
        display: 'flex',
        flexDirection: 'column',
        height: theme => `calc(100vh - ${theme.spacing(6)})`,
        position: 'relative',
      }}
    >
      <Div
        sx={{
          backgroundColor: theme => theme.palette.background.paper,
          padding: theme => theme.spacing(1),
          borderBottom: theme => `1px solid ${theme.palette.divider}`,
        }}
      >
        <Typography
          variant="h5"
          variantMapping={{ h5: 'h2' }}
          sx={{ display: 'block', textAlign: 'center' }}
        >
          Sustainable Ocean Modelling Initiative: A South African Approach
        </Typography>
        <Typography
          variant="overline"
          variantMapping={{ overline: 'h3' }}
          sx={{ textAlign: 'center' }}
        >
          High-resolution South African EEZ ocean data
        </Typography>
      </Div>
      <Div ref={el => setRef(el)} sx={{ display: 'flex', flex: 1 }}>
        <Suspense fallback={<Loading />}>
          <Map container={ref} />
        </Suspense>
      </Div>
      <Div
        sx={{
          backgroundColor: theme => theme.palette.background.paper,
          padding: theme => theme.spacing(1),
          borderTop: theme => `1px solid ${theme.palette.divider}`,
        }}
      >
        <Div sx={{ display: 'flex', flexDirection: 'row' }}>
          <Img
            sx={{ display: 'flex', height: 30, marginRight: theme => theme.spacing(1) }}
            src="/ocims-200h.png"
          ></Img>
          <Button
            rel={'noopener noreferrer'}
            target={'_blank'}
            size="small"
            href="https://www.ocims.gov.za/"
            sx={theme => ({
              [theme.breakpoints.down('sm')]: {
                display: 'none',
              },
            })}
          >
            ocims.gov.za
          </Button>
          <Button
            rel={'noopener noreferrer'}
            target={'_blank'}
            size="small"
            href="https://saeon.ac.za"
            sx={theme => ({
              marginLeft: theme.spacing(1),
              [theme.breakpoints.down('md')]: {
                display: 'none',
              },
            })}
          >
            saeon.ac.za
          </Button>
          <Button
            rel={'noopener noreferrer'}
            target={'_blank'}
            size="small"
            href="https://somisana.ac.za"
            sx={theme => ({
              marginRight: 'auto',
              marginLeft: theme.spacing(1),
              [theme.breakpoints.down('md')]: {
                display: 'none',
              },
            })}
          >
            somisana.ac.za
          </Button>
          <Button
            rel={'noopener noreferrer'}
            target={'_blank'}
            size="small"
            href="https://mnemosyne.somisana.ac.za/somisana"
            sx={theme => ({
              [theme.breakpoints.down('md')]: {
                marginLeft: 'auto'
              },
            })}
          >
            High-resolution data
          </Button>
          <Button
            rel={'noopener noreferrer'}
            target={'_blank'}
            size="small"
            sx={theme => ({
              marginLeft: theme.spacing(1),
              [theme.breakpoints.down('md')]: {
                display: 'none',
              },
            })}
            href="https://thredds.somisana.ac.za/thredds/catalog/data/somisana/catalog.html"
          >
            TDS Server
          </Button>
        </Div>
      </Div>
    </Div>
  )
}
