// https://stackoverflow.com/a/35970186/3114742

export const padZero = (str, len = 2) => {
  var zeros = new Array(len).join('0')
  return (zeros + str).slice(-len)
}

export default (hex, bw) => {
  if (hex.indexOf('#') === 0) {
    hex = hex.slice(1)
  }

  if (hex.length === 3) {
    hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2]
  }

  if (hex.length !== 6) {
    throw new Error('Invalid HEX color.')
  }

  const r = parseInt(hex.slice(0, 2), 16)
  const g = parseInt(hex.slice(2, 4), 16)
  const b = parseInt(hex.slice(4, 6), 16)

  if (bw) {
    return r * 0.299 + g * 0.587 + b * 0.114 > 186 ? '#000000' : '#FFFFFF'
  }

  const r2 = (255 - r).toString(16)
  const g2 = (255 - g).toString(16)
  const b2 = (255 - b).toString(16)

  return '#' + padZero(r2) + padZero(g2) + padZero(b2)
}
