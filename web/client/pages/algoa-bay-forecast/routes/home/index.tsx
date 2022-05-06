import { lazy, Suspense } from 'react'
import Counter from '../../../../modules/counter'
import GqlTest from '../../../../modules/gql-test'
import Div from '../../../../components/div'

const SuspenseTest = lazy(() => import('../../../../modules/suspense-test'))

const Home = () => {
  return (
    <>
      <Counter />
      <GqlTest />
      <Suspense fallback={null}>
        <SuspenseTest />
      </Suspense>
      <Div sx={{ backgroundColor: theme => theme.palette.primary.light }}>The styled Div</Div>
    </>
  )
}

export default Home
