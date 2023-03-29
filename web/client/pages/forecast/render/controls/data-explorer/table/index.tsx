import { useContext } from 'react'
import { context as bandContext } from '../../../band-data/_context'

export default ({ selectedCoordinates }) => {
  const { grid, data } = useContext(bandContext)
  const tableData = selectedCoordinates.map(id => {
    const i = grid?.coordinates[id]
    return data?.data.json[i] || []
  })

  return JSON.stringify(tableData)
}
