import { createContext, useContext, memo } from 'react'
import { context as pageContext } from '../_context'
import { gql, useQuery } from '@apollo/client'

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

  return <context.Provider value={{ ...graphqlRequest }}>{children}</context.Provider>
})

export default props => {
  const {
    depth,
    timeStep,
    run: { id: runId = 0 },
  } = useContext(pageContext)
  return <Render depth={depth} timeStep={timeStep} runId={runId} {...props} />
}
