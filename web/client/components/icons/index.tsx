import SvgIcon from '@mui/material/SvgIcon'
import { mdiCog, mdiClose, mdiChevronDown, mdiContentSaveAll, mdiCheckAll } from '@mdi/js'

export const Cog = (props: any) => (
  <SvgIcon {...props}>
    <path d={mdiCog} />
  </SvgIcon>
)

export const Close = (props: any) => (
  <SvgIcon {...props}>
    <path d={mdiClose} />
  </SvgIcon>
)

export const ExpandMore = (props: any) => (
  <SvgIcon {...props}>
    <path d={mdiChevronDown} />
  </SvgIcon>
)

export const SaveAll = (props: any) => (
  <SvgIcon {...props}>
    <path d={mdiContentSaveAll} />
  </SvgIcon>
)

export const CheckAll = (props: any) => (
  <SvgIcon {...props}>
    <path d={mdiCheckAll} />
  </SvgIcon>
)
