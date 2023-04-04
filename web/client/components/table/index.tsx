import { useDrag, useDrop } from 'react-dnd'
import { headerRenderer } from 'react-data-grid'
import Div from '../div'

export const DraggableHeaderRenderer = ({ onColumnsReorder, column, ...props }) => {
  const [{ isDragging }, drag] = useDrag({
    type: 'COLUMN_DRAG',
    item: { key: column.key },
    collect: monitor => ({
      isDragging: monitor.isDragging(),
    }),
  })

  const [{ isOver }, drop] = useDrop({
    accept: 'COLUMN_DRAG',
    drop({ key }) {
      onColumnsReorder(key, column.key)
    },
    collect: monitor => ({
      isOver: monitor.isOver(),
      canDrop: monitor.canDrop(),
    }),
  })

  return (
    <Div
      ref={ref => {
        drag(ref)
        drop(ref)
      }}
      sx={{
        textAlign: 'center',
        opacity: isDragging ? 0.5 : 1,
        backgroundColor: isOver ? '#ececec' : undefined,
        cursor: 'move',
      }}
    >
      {headerRenderer({ column, ...props })}
    </Div>
  )
}
