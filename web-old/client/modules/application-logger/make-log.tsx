import getUriState from '../../lib/get-uri-state'
import { PACKAGE_JSON } from '../config/env'

export default (type, info = {}) => {
  if (!type) {
    throw new Error('No log type specified makeLog(...)')
  }

  const { r, ...params } = getUriState()

  return {
    clientVersion: PACKAGE_JSON?.version,
    type,
    r,
    info: {
      pathname: window.location.pathname,
      params,
      ...info,
    },
  }
}
