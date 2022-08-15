import { gql, useQuery } from '@apollo/client'
import { Linear as Loading } from '../../../../../components/loading'
import Provider from './_context'

export default () => {
  const { loading, error, data } = useQuery(
    gql`
      query models {
        models {
          id
          ... on Model {
            _id
            name
            envelope
          }
        }
      }
    `
  )

  if (loading) {
    return <Loading />
  }

  if (error) {
    throw error
  }

  return (
    <>
      <Provider models={data.models}></Provider>
    </>
  )
}
