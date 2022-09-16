import { createContext, useState } from 'react'
import { useParams } from 'react-router-dom'
import { gql, useQuery } from '@apollo/client'
import { Linear as Loading } from '../../../../components/loading'

export const context = createContext({})

export default ({ children }) => {
  const { id } = useParams()
  const [timeStep, setTimeStep] = useState(120)
  const [depth, setDepth] = useState(0)
  const [selectedCoordinate, setSelectedCoordinate] = useState(null)
  const [animateTimeStep, setAnimateTimeStep] = useState(false)

  const { loading, error, data } = useQuery(
    gql`
      query models($id: ID) {
        models(id: $id) {
          id
          ... on Model {
            _id
            title
            description
            max_x
            max_y
            min_x
            min_y
            gridWidth
            gridHeight
            runs
          }
        }
      }
    `,
    {
      variables: {
        id,
      },
    }
  )

  if (loading) {
    return <Loading />
  }

  if (error) {
    throw error
  }

  const model = data.models.find(({ _id }) => _id == id)
  const run = model.runs[0]

  return (
    <context.Provider
      value={{
        selectedCoordinate,
        setSelectedCoordinate,
        depth,
        setDepth,
        timeStep,
        setTimeStep,
        animateTimeStep,
        setAnimateTimeStep,
        run,
        model,
      }}
    >
      {children}
    </context.Provider>
  )
}
