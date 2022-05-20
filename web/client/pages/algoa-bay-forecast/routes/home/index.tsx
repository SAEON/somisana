import Counter from '../../../../modules/counter'
import GqlTest from '../../../../modules/gql-test'
import Div from '../../../../components/div'

const Home = () => {
  return (
    <>
      <Counter />
      <GqlTest />
      <Div sx={{ backgroundColor: theme => theme.palette.primary.light }}>The styled Div</Div>
    </>
  )
}

export default Home
