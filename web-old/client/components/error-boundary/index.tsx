import { Component } from 'react'
import { TECHNICAL_CONTACT } from '../../modules/config/env'

class ErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { error: undefined }
  }

  static getDerivedStateFromError(error) {
    return { error: error.message }
  }

  render() {
    const { props, state } = this
    const { children } = props
    const { error } = state

    // NO APP ERROR
    if (!error) {
      return children
    }

    return (
      <div style={{ marginLeft: 16 }}>
        <p>
          <b>Application Error</b>
        </p>
        <p>
          Please try refreshing this page in a few minutes. If the error persists, or if assistance
          is required, please contact{' '}
          <a href={`mailto:${TECHNICAL_CONTACT}`}>{TECHNICAL_CONTACT}</a> with a screenshot of this
          page so that we may resolve the issue speedily
        </p>
        <pre
          style={{
            whiteSpace: 'pre-wrap',
            wordBreak: 'break-word',
          }}
        >
          {error}
        </pre>
      </div>
    )
  }
}

export default ErrorBoundary
