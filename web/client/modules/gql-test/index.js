import { useEffect, useState } from 'react'
import { gql, useQuery } from '@apollo/client'
import Div from '../../components/div/index.js'

const GqlTest = () => {
  const { error, loading, data } = useQuery(
    gql`
      query {
        test
      }
    `
  )

  return <Div>{loading ? 'Loading' : JSON.stringify(data)}</Div>
}

/**
 * Currently useQuery doesn't work in SSR
 * https://github.com/apollographql/apollo-client/issues/9623
 */
export default () => {
  const [renderCtx, setRenderCtx] = useState('ssr')

  useEffect(() => setRenderCtx('client'), [])

  if (renderCtx === 'client') {
    return <GqlTest />
  }
}
