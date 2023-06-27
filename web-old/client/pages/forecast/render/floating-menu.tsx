import Stack from '@mui/material/Stack'
import Draggable from 'react-draggable'
import { DragHorizontal } from '../../../components/icons'
import { styled } from '@mui/material/styles'

export default styled(({ children, id, ...props }) => {
  return (
    <Draggable
      onStop={e => {
        globalThis.dispatchEvent(
          new CustomEvent('interaction', {
            detail: { type: 'drag-floating-menu', menuId: id },
          })
        )
      }}
      handle={`#${id}`}
    >
      <Stack
        sx={{
          opacity: 0.8,
          alignItems: 'center',
          position: 'relative',
          zIndex: 1,
          boxShadow: theme => theme.shadows[3],
          padding: theme => theme.spacing(1),
          borderRadius: theme => `${theme.shape.borderRadius}px`,
          backgroundColor: theme => theme.palette.background.paper,
        }}
        {...props}
        direction="column"
        spacing={1}
      >
        <DragHorizontal
          id={id}
          sx={{
            cursor: 'move',
          }}
        />
        {children}
      </Stack>
    </Draggable>
  )
})({})
