import { createContext, useState } from 'react'
import { useParams } from 'react-router-dom'
import { gql, useQuery } from '@apollo/client'
import { Linear as Loading } from '../../../../components/loading'

export const context = createContext({})

export default ({ children }) => {
  const { id } = useParams()
  const [time_step, setTime_step] = useState(1)

  const { loading, error, data } = useQuery(
    gql`
      query models($id: ID) {
        models(id: $id) {
          id
          ... on Model {
            _id
            max_x
            max_y
            min_x
            min_y
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

  return (
    <context.Provider value={{ time_step, setTime_step, model: { ...data.models[0] } }}>
      {children}
    </context.Provider>
  )
}
