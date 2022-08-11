import Provider from './_context'

export default ({ id, children }) => {
  console.log('TODO get the model by id', id)
  return <Provider>{children}</Provider>
}
