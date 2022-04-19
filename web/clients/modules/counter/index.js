import {useState} from 'react'
import Button from '../../components/button/index.js'

export default () => {
  const [c, setC] = useState(1)

  return <Button onClick={() => setC(c =>  c + 1)}>Clicked {c} times</Button>
}