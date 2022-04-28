import { lazy, Suspense } from "react"
import Counter from "../../../../modules/counter/index.js"
import GqlTest from "../../../../modules/gql-test/index.js"

const SuspenseTest = lazy(() => import('../../../../modules/suspense-test/index.js'))

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