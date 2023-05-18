import { useState } from 'react'
import IconButton from '@mui/material/IconButton'
import { EgagasiniGraphic } from '../../../components/icons'
import Title from '@mui/material/DialogTitle'
import Dialog from '@mui/material/Dialog'
import Content from '@mui/material/DialogContent'
import { styled } from '@mui/material'
import Div from '../../../components/div'

export default styled(props => {
  const [open, setOpen] = useState(false)
  return (
    <Div {...props}>
      <IconButton onClick={() => setOpen(true)} size="medium">
        <EgagasiniGraphic fontSize="medium" />
      </IconButton>

      <Dialog disableScrollLock onClose={() => setOpen(false)} open={open}>
        <Title sx={{ textAlign: 'center' }}>SOMISANA</Title>
        <Content dividers sx={{ display: 'flex' }}>
          <EgagasiniGraphic sx={{ fontSize: 250 }} />
        </Content>
      </Dialog>
    </Div>
  )
})({})
