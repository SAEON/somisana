import { createContext } from 'react'
import { gql, useQuery } from '@apollo/client'

export const context = createContext({})

export default ({ children }) => {
  const { error, ...res } = useQuery(
    gql`
      query models {
        models {
          ... on Model {
            id
            _id
            title
            description
            creator
            creatorContactEmail
          }
        }
      }
    `
  )

  if (error) {
    throw error
  }

  return <context.Provider value={{ ...res }}>{children}</context.Provider>
}
