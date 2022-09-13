import { createContext, useContext, useEffect } from 'react'
import { context as modelContext } from '../_context'
import { gql, useQuery } from '@apollo/client'

export const context = createContext({})

export default ({ children }) => {
  const { depth, timeStep } = useContext(modelContext)

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
        runId: 1,
        depth,
        timeStep,
      },
    }
  )

  return <context.Provider value={{ ...graphqlRequest }}>{children}</context.Provider>
}
