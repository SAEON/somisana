import { createContext, useState, useMemo } from 'react'
import { gql, useQuery } from '@apollo/client'
import { Linear as Loading } from '../../../../components/loading'
import * as d3 from 'd3'

export const context = createContext({})

export default ({ modelid = undefined, children }) => {
  const id = modelid || new URL(window.location.href).searchParams.get('id')
  const [timeStep, setTimeStep] = useState(120)
  const [depth, setDepth] = useState(0)
  const [selectedCoordinate, setSelectedCoordinate] = useState(null)
  const [animateTimeStep, setAnimateTimeStep] = useState(false)
  const [scaleMin, setScaleMin] = useState(false)
  const [scaleMax, setScaleMax] = useState(false)
  const [selectedVariable, setSelectedVariable] = useState('temperature')

  const color = useMemo(
    () =>
      d3
        .scaleSequential(d3.interpolateMagma)
        .domain(d3.extent([scaleMin || 10, scaleMax || 25], v => v)),
    [scaleMin, scaleMax]
  )

  const { loading, error, data } = useQuery(
    gql`
      query models($id: ID) {
        models(id: $id) {
          id
          ... on Model {
            _id
            title
            description
            max_x
            max_y
            min_x
            min_y
            gridWidth
            gridHeight
            runs
          }
        }
      }
    `,
    {
      variables: {
        id,
      },
    }
  )

  if (loading) {
    return <Loading />
  }

  if (error) {
    throw error
  }

  const model = data.models.find(({ _id }) => _id == id)
  const run = model?.runs[0] || {}

  return (
    <context.Provider
      value={{
        selectedCoordinate,
        setSelectedCoordinate,
        depth,
        setDepth,
        timeStep,
        setTimeStep,
        animateTimeStep,
        setAnimateTimeStep,
        run,
        model,
        scaleMin,
        scaleMax,
        color,
        setScaleMin,
        setScaleMax,
        selectedVariable,
        setSelectedVariable,
      }}
    >
      {children}
    </context.Provider>
  )
}
