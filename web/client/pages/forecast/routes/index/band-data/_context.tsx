import { createContext, useContext, memo } from 'react'
import { context as pageContext } from '../_context'
import { gql, useQuery } from '@apollo/client'
import Typography from '@mui/material/Typography'

export const context = createContext({})

const BOTTOM_DEPTH_PLACEHOLDER = -550

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
        depth: depth === BOTTOM_DEPTH_PLACEHOLDER ? -99999 : depth,
        timeStep,
      },
    }
  )

  return <context.Provider value={{ ...graphqlRequest }}>{children}</context.Provider>
})

export default props => {
  const { model, depth, timeStep, run: { id: runId = undefined } = {} } = useContext(pageContext)

  if (!runId) {
    return <Typography sx={{ m: 2 }}>No completed runs for the ({model.title}) model</Typography>
  }

  return <Render depth={depth} timeStep={timeStep} runId={runId} {...props} />
}
