import { useContext, useState, useMemo, useEffect, useCallback } from 'react'
import '../../../../../../../node_modules/react-data-grid/lib/styles.css'
import { context as bandContext } from '../../../band-data/_context'
import ReactDataGrid from 'react-data-grid'
import { HTML5Backend } from 'react-dnd-html5-backend'
import { DndProvider } from 'react-dnd'
import I from '../../../../../../components/i'
import { DraggableHeaderRenderer } from '../../../../../../components/table'
import Div from '../../../../../../components/div'
import IconButton from '@mui/material/IconButton'
import { Close as CloseIcon } from '../../../../../../components/icons'
import Grid from '@mui/material/Grid'

const getComparator = sortColumn => {
  switch (sortColumn) {
    default:
      return (a, b) => {
        a = (a[sortColumn]?.toString() || '').replace(/\s+/g, '').toUpperCase()
        b = (b[sortColumn]?.toString() || '').replace(/\s+/g, '').toUpperCase()
        if (a > b) return 1
        if (b > a) return -1
        return 0
      }
  }
}

export default ({ selectedCoordinates, setSelectedCoordinates, selectedMPAs }) => {
  const { grid, data } = useContext(bandContext)
  const [sortColumns, setSortColumns] = useState([])
  const [rows, setRows] = useState([])

  const closeCoordinate = useCallback(
    id => setSelectedCoordinates(coordinates => ({ ...coordinates, [id]: false })),
    [setSelectedCoordinates]
  )

  const [columns, setColumns] = useState([
    {
      key: 'i',
      name: ` `,
      resizable: false,
      width: 50,
      formatter: ({ row: { i } }) => <I sx={{ textAlign: 'center', display: 'block' }}>{i}</I>,
    },
    { key: 'location', name: 'Lat / Long (°)' },
    { key: 'temperature', name: 'Temperature (°C)' },
    { key: 'salinity', name: 'Salinity (‰)' },
    { key: 'u', name: 'U (m/s)' },
    { key: 'v', name: 'V (m/s)' },
    {
      key: 'coordinateid',
      name: ` `,
      width: 40,
      formatter: ({ row: { coordinateid } }) => (
        <Div
          sx={{ height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
        >
          <Div sx={{ display: 'flex', justifyContent: 'center' }}>
            <IconButton size="small" onClick={() => closeCoordinate(coordinateid)}>
              <CloseIcon sx={{ fontSize: 12 }} />
            </IconButton>
          </Div>
        </Div>
      ),
    },
  ])

  useEffect(() => {
    setRows(
      Object.entries(selectedCoordinates)
        .filter(([, v]) => Boolean(v))
        .map(([id], i) => {
          const index = grid?.coordinates[id]
          const [coordinateid, lng, lat, temperature = NaN, salinity = NaN, u = NaN, v = NaN] =
            data?.data.json[index] || []
          return {
            i: i + 1,
            location: `${lat?.toFixed(5) || '-'}/${lng?.toFixed(5) || '-'}`,
            temperature,
            salinity,
            u,
            v,
            coordinateid,
          }
        })
    )
  }, [setRows, selectedCoordinates, grid, data])

  const draggableColumns = useMemo(() => {
    function headerRenderer(props) {
      return <DraggableHeaderRenderer {...props} onColumnsReorder={handleColumnsReorder} />
    }

    function handleColumnsReorder(sourceKey, targetKey) {
      const sourceColumnIndex = columns.findIndex(c => c.key === sourceKey)
      const targetColumnIndex = columns.findIndex(c => c.key === targetKey)
      const reorderedColumns = [...columns]
      reorderedColumns.splice(
        targetColumnIndex,
        0,
        reorderedColumns.splice(sourceColumnIndex, 1)[0]
      )
      setColumns(reorderedColumns)
    }

    return columns.map(c => {
      if (c.key === 'i') return c
      return { ...c, headerRenderer }
    })
  }, [columns])

  const sortedRows = useMemo(() => {
    if (sortColumns.length === 0) return rows

    return [...rows].sort((a, b) => {
      for (const sort of sortColumns) {
        const comparator = getComparator(sort.columnKey)
        const compResult = comparator(a, b)
        if (compResult !== 0) {
          return sort.direction === 'ASC' ? compResult : -compResult
        }
      }
      return 0
    })
  }, [rows, sortColumns])

  return (
    <Grid container spacing={1}>
      <Grid item sx={12} md={8}>
        <Div
          sx={{
            height: 35 + 35 * Object.values(selectedCoordinates).filter(v => Boolean(v)).length,
            maxHeight: 10 * 35,
          }}
        >
          <DndProvider backend={HTML5Backend}>
            <ReactDataGrid
              columns={draggableColumns}
              defaultColumnOptions={{
                sortable: true,
                resizable: true,
              }}
              enableVirtualization
              onRowsChange={setRows}
              onSortColumnsChange={setSortColumns}
              sortColumns={sortColumns}
              rows={sortedRows}
            />
          </DndProvider>
        </Div>
      </Grid>

      <Grid item sx={12} md={4}>
        <Div>Show selected MPA information here: {JSON.stringify(selectedMPAs)}</Div>
      </Grid>
    </Grid>
  )
}
