import { useContext } from 'react'
import { context as bandContext } from '../../../band-data/_context'

export default ({ selectedCoordinates }) => {
  const data = useContext(bandContext)
  console.log(data)
  return JSON.stringify(selectedCoordinates)
}
