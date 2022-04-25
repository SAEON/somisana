import { useState } from 'react'
import Button from '../../components/button/index.js'

const Counter = () => {
  const [c, setC] = useState(1)

  return (
    <Button variant="outlined" fullWidth onClick={() => setC(c => c * 2)}>
      Hello - clicked {c} times
    </Button>
  )
}

export default Counter
