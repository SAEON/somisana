import useTheme from '@mui/material/styles/useTheme'
import useMediaQuery from '@mui/material/useMediaQuery'

type MinHeight = {
  minHeight: number
}

export default function useAppBarHeight(): number {
  const {
    mixins: { toolbar },
    breakpoints,
  } = useTheme()

  const toolbarDesktopQuery = breakpoints.up('sm')
  const toolbarLandscapeQuery = `${breakpoints.up('xs')} and (orientation: landscape)`
  const isDesktop = useMediaQuery(toolbarDesktopQuery)
  const isLandscape = useMediaQuery(toolbarLandscapeQuery)

  let currentToolbarMinHeight
  if (isDesktop) {
    currentToolbarMinHeight = toolbar[toolbarDesktopQuery]
  } else if (isLandscape) {
    currentToolbarMinHeight = toolbar[toolbarLandscapeQuery]
  } else {
    currentToolbarMinHeight = toolbar
  }

  return (currentToolbarMinHeight as MinHeight).minHeight
}
