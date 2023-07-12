export function bilinearInterpolation(grid, m, n, [x, y]) {
  const x0 = clamp(Math.floor(x), 0, n - 1),
    dx = x - x0
  const x1 = clamp(Math.ceil(x), 0, n - 1),
    rx = dx / (x1 - x)
  const y0 = clamp(Math.floor(y), 0, m - 1),
    dy = y - y0
  const y1 = clamp(Math.ceil(y), 0, m - 1),
    ry = dy / (y1 - y)

  // bilinear interpolation
  const qx = i(
    i(grid.lng[x0 + n * y0], grid.lng[x1 + n * y0], rx),
    i(grid.lng[x0 + n * y1], grid.lng[x1 + n * y1], rx),
    ry
  )
  const qy = i(
    i(grid.lat[x0 + n * y0], grid.lat[x0 + n * y1], ry),
    i(grid.lat[x1 + n * y0], grid.lat[x1 + n * y1], ry),
    rx
  )

  return [qx, qy]

  // linear interpolation
  function i(a, b, r) {
    return a === b ? a : (a + b * r) / (r + 1)
  }

  function clamp(x, lo, hi) {
    return x < lo ? lo : x > hi ? hi : x
  }
}
