import { useState, useEffect } from 'react'

export default function useFetch(url: String, options: Object = undefined) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    setLoading(true)

    fetch(url, options)
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok')
        }
        return response
      })
      .then(res => res.text())
      .then(data => {
        setData(data)
        setLoading(false)
        setError(null)
      })
      .catch(error => {
        setData(null)
        setLoading(false)
        setError(error)
      })
  }, [])

  return { data, loading, error }
}
