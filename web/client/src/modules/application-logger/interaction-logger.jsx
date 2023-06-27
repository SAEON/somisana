import makeLog from './make-log'
import RegisterEventLog from './register-event-log'

export default ({ children }) => {
  const eventType = 'interaction'
  return (
    <RegisterEventLog
      target={globalThis}
      event={eventType}
      handle={e => {
        e.stopPropagation()
        if (!e.detail.type || !e.detail) {
          throw new Error('This event logger needs e.interactionType and e.detail defined')
        }
        console.gql(makeLog(eventType, { ...e.detail }))
      }}
    >
      {children}
    </RegisterEventLog>
  )
}
