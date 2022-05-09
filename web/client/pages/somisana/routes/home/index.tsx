import Tooltip from '@mui/material/Tooltip'
import IconButton from '@mui/material/IconButton'
import { Cog } from '../../../../components/icons'
import Title from './title'

const Home = () => {
  return (
    <>
      <Title />
      <Tooltip placement="left" title="Site settings">
        <IconButton
          size='medium'
          sx={{ position: 'absolute', bottom: 0, right: 0, margin: theme => theme.spacing(2) }}
        >
          <Cog />
        </IconButton>
      </Tooltip>
    </>
  )
}

export default Home
