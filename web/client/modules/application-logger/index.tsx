import { useEffect } from 'react'
import { gql, useApolloClient } from '@apollo/client'
import logger from '../../../logger'
import logToGql from '../../../logger/log-to-graphql'

export { default as RegisterEventLog } from './_register-event-log'
export { default as makeLog } from './_make-log'
export { default as LogAppRender } from './_app-render'

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
