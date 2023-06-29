import { useMemo, useEffect } from 'react'
import { Routes, Route } from 'react-router-dom'

export default ({ routes: _routes, ...props }) => {
  useEffect(() => window.scrollTo(0, 0))
  const routes = useMemo(() => _routes.filter(({ href }) => !href), [_routes])

  return (
    <Routes>
      {routes.map(({ path, element: E, label }) => {
        return <Route key={label} path={path} element={<E {...props} />} />
      })}
    </Routes>
  )
}
