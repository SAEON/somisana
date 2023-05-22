import makeLog from './_make-log'
import RegisterEventLog from './_register-event-log'

export default ({ children }) => {
  return (
    <RegisterEventLog
      target={globalThis}
      event="load"
      readyState="complete"
      handle={() => console.gql(makeLog('appRender'))}
    >
      {children}
    </RegisterEventLog>
  )
}
