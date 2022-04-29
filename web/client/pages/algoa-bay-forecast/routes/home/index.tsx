import { lazy, Suspense } from 'react'
import Counter from '../../../../modules/counter'
import GqlTest from '../../../../modules/gql-test'

const SuspenseTest = lazy(() => import('../../../../modules/suspense-test'))

const Home = () => {
  return (
    <>
      <Counter />
      <GqlTest />
      <Suspense fallback={null}>
        <SuspenseTest />
      </Suspense>
    </>
  )
}

export default Home
