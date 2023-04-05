const isStaticAsset = path => {
  if (path.endsWith('.md')) return true
  if (path.endsWith('.png')) return true
  if (path.endsWith('.pdf')) return true
  return false
}

export default (path: string) =>
  path.replace(/(explore|notes)\/(.*)/, (match, g1, g2) => {
    if (path.endsWith('.js')) return path.replace(`${g1}/`, '')
    if (isStaticAsset(path)) return path
    return match.replace(`${g1}/`, 'esri-atlas').replace(g2, '')
  })
