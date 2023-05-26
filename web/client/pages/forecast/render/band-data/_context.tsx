import { createContext, useContext, memo, useMemo } from 'react'
import { context as pageContext } from '../_context'
import { gql, useQuery } from '@apollo/client'
import Typography from '@mui/material/Typography'

export const context = createContext({})

const Render = memo(({ children, depth, timeStep, runId }) => {
  const graphqlRequest = useQuery(
    gql`
      query ($timeStep: Int!, $runId: Int!, $depth: Int!) {
        data(timeStep: $timeStep, runId: $runId, depth: $depth) {
          id
          json
        }
      }
    `,
    {
      variables: {
        runId,
        depth,
        timeStep,
      },
    }
  )

  const grid = useMemo(() => {
    const points = graphqlRequest?.data?.data.json
    if (!points) return null

    return points.reduce(
      (a, c, i) => {
        const [coordinateid, lng, lat, temperature, salinity, u, v] = c
        a.coordinates[coordinateid] = i

        // For d3-contour
        a.lng.push(lng)
        a.lat.push(lat)
        a.temperature.push(temperature)
        a.salinity.push(salinity)
        a.u.push(u)
        a.v.push(v)

        // For d3-tricontour
        a.values.push([lng, lat, { temperature, salinity, u, v }])
        return a
      },
      {
        lng: [],
        lat: [],
        temperature: [],
        salinity: [],
        u: [],
        v: [],
        values: [],
        coordinates: {},
      }
    )
  }, [graphqlRequest])

  return <context.Provider value={{ grid, ...graphqlRequest }}>{children}</context.Provider>
})

export default props => {
  const { model, depth, timeStep, run: { id: runId = undefined } = {} } = useContext(pageContext)

  if (!runId) {
    return <Typography sx={{ margin: 2 }}>No completed runs for the {model.title} model</Typography>
  }

  return <Render depth={depth} timeStep={timeStep} runId={runId} {...props} />
}
