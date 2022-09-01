import { useContext } from 'react'
import { context as modelContext } from '../../../_context'
import Div from '../../../../../../../components/div'

export default () => {
  const { setTime_step } = useContext(modelContext)

  return (
    <Div sx={{ zIndex: 10 }}>
      <button onClick={() => setTime_step(t => t - 1)}>Previous time step</button>
      <button onClick={() => setTime_step(t => t + 1)}>Next time step</button>
    </Div>
  )
}
