import SvgIcon from '@mui/material/SvgIcon'
import { mdiCog, mdiClose, mdiChevronDown, mdiContentSaveAll, mdiCheckAll } from '@mdi/js'
import {styled} from '@mui/material/styles'

export const Cog = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiCog} />
  </SvgIcon>
))({}) 

export const Close = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiClose} />
  </SvgIcon>
))({})

export const ExpandMore = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiChevronDown} />
  </SvgIcon>
))({})

export const SaveAll = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiContentSaveAll} />
  </SvgIcon>
))({})

export const CheckAll = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiCheckAll} />
  </SvgIcon>
))({})
