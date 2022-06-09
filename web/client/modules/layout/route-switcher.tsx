import { Routes, Route } from 'react-router-dom'

export default ({ routes }) => {
  return (
    <Routes>
      {routes.map(({ path, element: E, label }) => {
        return <Route key={label} path={path} element={<E />} />
      })}
    </Routes>
  )
}
