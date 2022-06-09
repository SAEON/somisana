import SvgIcon from '@mui/material/SvgIcon'
import { styled } from '@mui/material/styles'
import {
  mdiCog,
  mdiClose,
  mdiChevronDown,
  mdiMap,
  mdiContentSaveAll,
  mdiCheckAll,
  mdiMenu,
  mdiHome,
  mdiLicense,
  mdiFileSign,
} from '@mdi/js'

export const Cog = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiCog} />
  </SvgIcon>
))({})

export const Home = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiHome} />
  </SvgIcon>
))({})

export const Map = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiMap} />
  </SvgIcon>
))({})

export const Contract = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiFileSign} />
  </SvgIcon>
))({})

export const License = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiLicense} />
  </SvgIcon>
))({})

export const Menu = styled((props: any) => (
  <SvgIcon {...props}>
    <path d={mdiMenu} />
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
