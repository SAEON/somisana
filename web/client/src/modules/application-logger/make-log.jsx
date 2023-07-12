import getUriState from '../../lib/get-uri-state'

export default (type, info = {}) => {
  if (!type) {
    throw new Error('No log type specified makeLog(...)')
  }

  const { r, ...params } = getUriState()

  return {
    type,
    r,
    info: {
      pathname: window.location.pathname,
      params,
      ...info,
    },
  }
}
