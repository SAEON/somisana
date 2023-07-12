import { useEffect } from 'react'
import { gql, useApolloClient } from '@apollo/client'
import logger from '../../logger'
import logToGql from '../../logger/log-to-graphql'

const { configure: configureLogger } = logger

export default ({ children }) => {
  const { link } = useApolloClient()

  // Clint only
  useEffect(() => {
    configureLogger(() => ({
      overwrites: {
        gql: logToGql({
          link,
          query: gql`
            mutation logBrowserEvents($input: [BrowserEventInput]!) {
              logBrowserEvents(input: $input)
            }
          `,
        }),
      },
    }))
  }, [link])

  return children
}
