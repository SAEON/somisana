import SvgIcon from '@mui/material/SvgIcon'
import { mdiCog } from '@mdi/js'

export const Cog = (props: object) => (
  <SvgIcon {...props}>
    <path d={mdiCog} />
  </SvgIcon>
)
