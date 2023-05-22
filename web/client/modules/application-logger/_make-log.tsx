import getUriState from '../../lib/get-uri-state'
import { PACKAGE_JSON } from '../../modules/config/env'

const { r } = getUriState()

export default (type, info = {}) => {
  if (!type) {
    throw new Error('No log type specified makeLog(...)')
  }

  return {
    clientVersion: PACKAGE_JSON?.version,
    type,
    r,
    info: {
      pathname: window.location.pathname,
      ...info,
    },
  }
}
