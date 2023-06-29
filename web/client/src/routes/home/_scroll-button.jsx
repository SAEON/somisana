import { useEffect, useState } from 'react'
import debounce from '../../lib/debounce'
import ScrollButton from '../../components/fancy-buttons/scroll-button'
import Fade from '@mui/material/Fade'
import Div from '../../components/div'

export default ({ contentRef }) => {
  const [pageScrolled, setPageScrolled] = useState(false)

  const onScroll = debounce(() => {
    const _pageScrolled = window.scrollY > 0
    if (pageScrolled !== _pageScrolled) {
      setPageScrolled(_pageScrolled)
    }
  })

  useEffect(() => {
    window.addEventListener('scroll', onScroll)
    return () => {
      window.removeEventListener('scroll', onScroll)
    }
  })

  return (
    <Div
      sx={{
        position: 'absolute',
        right: 0,
        bottom: 0,
        width: 68,
        backgroundColor: theme => theme.palette.common.white,
      }}
    >
      <Fade timeout={500} key="scroll-button" in={!pageScrolled}>
        <ScrollButton
          onClick={() =>
            window.scrollTo({ top: contentRef.current.offsetTop, left: 0, behavior: 'smooth' })
          }
          sx={{ bottom: theme => theme.spacing(6), position: 'relative', zIndex: 9 }}
        />
      </Fade>
    </Div>
  )
}
