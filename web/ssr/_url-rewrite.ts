export default (path: string) =>
  path.replace(/(explore|posts)\/(.*)/, (match, g1, g2) => {
    if (path.endsWith('.js')) {
      return path.replace(`${g1}/`, '')
    }

    return match.replace(`${g1}/`, 'esri-atlas').replace(g2, '')
  })
