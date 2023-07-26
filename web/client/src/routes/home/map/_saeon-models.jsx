import { gql, useQuery } from '@apollo/client'
import { Linear as Loading } from '../../../components/loading'
import SaeonWmsLayer from './layers/saeon-wms'

export default ({ modelid = undefined, children }) => {
  const id = modelid || new URL(window.location.href).searchParams.get('id')

  const { loading, error, data } = useQuery(
    gql`
      query models($id: ID) {
        models(id: $id) {
          id
          _id
          title
          description
          max_x
          max_y
          min_x
          min_y
          gridWidth
          gridHeight
          runs {
            id
            run_date
            modelid
            step1_timestamp
            timestep_attrs
            successful
          }
          creator
          creatorContactEmail
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
      {data.models.map(model => (
        <SaeonWmsLayer key={model.id} model={model} />
      ))}
    </>
  )
}
