import { gql, useQuery } from '@apollo/client'
import { Linear as Loading } from '../../../../../components/loading'
import Provider from './_context'
import Models from './_models'

export default () => {
  const { loading, error, data } = useQuery(
    gql`
      query models {
        models {
          ... on Model {
            id
            _id
            title
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
      <Provider>
        <Models models={data.models} />
      </Provider>
    </>
  )
}
