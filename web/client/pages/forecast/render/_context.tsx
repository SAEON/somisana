import { createContext, useState, useCallback, useEffect } from 'react'
import { gql, useQuery } from '@apollo/client'
import { Linear as Loading } from '../../../components/loading'
import { color as colorFn } from './controls/color-bar/config'
import format from 'date-fns/format'
import add from 'date-fns/add'

const fixStep1_timestamp = (i, step1_timestamp) => {
  const step1Timestamp = new Date(step1_timestamp)
  const dt = add(step1Timestamp, {
    days: -i,
  })
  return `${format(dt, 'yyyy-MM-dd')}T${format(dt, 'HH:mm:ss')}`
}

export const context = createContext({})

export default ({ modelid = undefined, children }) => {
  const id = modelid || new URL(window.location.href).searchParams.get('id')
  const [timeStep, setTimeStep] = useState(120)
  const [activeRun, setActiveRun] = useState(0)
  const [depth, setDepth] = useState(0)
  const [showCoordinates, setShowCoordinates] = useState(true)
  const [showMPAs, setShowMPAs] = useState(true)
  const [selectedCoordinates, setSelectedCoordinates] = useState({})
  const [selectedMPAs, setSelectedMPAs] = useState({})
  const [thresholds, setThresholds] = useState(12)
  const [animateTimeStep, setAnimateTimeStep] = useState(false)
  const [scaleMin, setScaleMin] = useState(false)
  const [scaleMax, setScaleMax] = useState(false)
  const [activeRightPane, setActiveRightPane] = useState(false)
  const [selectedVariable, setSelectedVariable] = useState('temperature')
  const [showCurrents, setShowCurrents] = useState(false)
  const [colorScheme, setColorScheme] = useState('Magma')
  const [showIsolines, setShowIsolines] = useState(true)
  const [showData, setShowData] = useState(false)

  const color = useCallback(colorFn(colorScheme, scaleMin, scaleMax), [
    scaleMin,
    scaleMax,
    colorScheme,
  ])

  useEffect(() => {
    setScaleMin(false)
    setScaleMax(false)
  }, [selectedVariable])

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

  /**
   * Updates to the system often involve
   * more recent runs having additional run
   * metadata. Assume that new information in
   * the most recent run applies to the older
   * runs
   */
  const model = data.models.find(({ _id }) => _id == id)
  const runs = [...(model?.runs || [])].map((r, i) => {
    r = Object.fromEntries(
      Object.entries(r).filter(([, value]) => {
        return Boolean(value)
      })
    )
    const mostRecentRun = model?.runs[0] || {}
    if (!r.step1_timestamp) {
      r.step1_timestamp = fixStep1_timestamp(i, mostRecentRun.step1_timestamp)
    }
    return { ...mostRecentRun, ...r }
  })
  const run = runs[activeRun]

  return (
    <context.Provider
      value={{
        selectedCoordinates,
        setSelectedCoordinates,
        selectedMPAs,
        setSelectedMPAs,
        showCoordinates,
        setShowCoordinates,
        showMPAs,
        setShowMPAs,
        depth,
        setDepth,
        timeStep,
        setTimeStep,
        animateTimeStep,
        setAnimateTimeStep,
        runs,
        run,
        activeRun,
        setActiveRun,
        thresholds,
        setThresholds,
        model,
        scaleMin,
        scaleMax,
        color,
        setScaleMin,
        activeRightPane,
        setActiveRightPane,
        setScaleMax,
        selectedVariable,
        setSelectedVariable,
        showCurrents,
        setShowCurrents,
        colorScheme,
        setColorScheme,
        showIsolines,
        setShowIsolines,
        showData,
        setShowData,
      }}
    >
      {children}
    </context.Provider>
  )
}
