import { gql, useQuery } from '@apollo/client'
import { Linear as Loading } from '../../../components/loading'
import Provider from './_context'

export default ({ id, children }) => {
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
    <>
      <Provider model={data.models[0]}>{children}</Provider>
    </>
  )
}
