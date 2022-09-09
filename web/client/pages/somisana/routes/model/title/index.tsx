import Typography from '@mui/material/Typography'

export default () => {
  return (
    <>
      <Typography
        sx={{
          textAlign: 'center',
        }}
        gutterBottom
        variant="h1"
      >
        Algoa Bay Forecast
      </Typography>
      <Typography
        marginBottom={theme => theme.spacing(4)}
        variant="subtitle1"
        sx={{ textAlign: 'center', fontStyle: 'italic' }}
      >
        Ocean current forecast for the period from the 8th of August to 19 September
      </Typography>
    </>
  )
}
