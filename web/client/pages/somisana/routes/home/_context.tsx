import { useContext, createContext } from 'react'
import { gql, useQuery } from '@apollo/client'
import { context as configContext } from '../../../../modules/config'

export const context = createContext({})

export default ({ children }) => {
  const { NODE_ENV } = useContext(configContext)
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
    if (NODE_ENV === 'production') {
      throw error
    } else {
      console.error(error)
    }
  }

  return <context.Provider value={{ ...res }}>{children}</context.Provider>
}
