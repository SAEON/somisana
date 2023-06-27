export default ({ splitString = false } = {}): { r?: String } => {
  if (typeof window === 'undefined') {
    return {}
  }

  const url = window.location.href
  const regex = /[?&]([^=#]+)=([^&#]*)/g
  const params = {}

  var match
  while ((match = regex.exec(url))) {
    params[match[1]] = splitString
      ? decodeURIComponent(match[2])
          .split(',')
          .map(item => decodeURIComponent(item))
          .filter(_ => _)
      : decodeURIComponent(match[2])
  }
  return params
}
