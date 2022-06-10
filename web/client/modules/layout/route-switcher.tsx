import { Routes, Route } from 'react-router-dom'
import PageTransition from './page-transition'

export default ({ routes, ...props }) => {
  return (
    <Routes>
      {routes.map(({ path, element: E, label }) => {
        return (
          <Route
            key={label}
            path={path}
            element={
              <PageTransition tKey={label}>
                <E {...props} />
              </PageTransition>
            }
          />
        )
      })}
    </Routes>
  )
}
