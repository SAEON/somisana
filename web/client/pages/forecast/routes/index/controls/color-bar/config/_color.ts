import * as d3 from 'd3'

// https://observablehq.com/@d3/color-schemes

export default (name, min, max) =>
  d3.scaleSequential(d3[`interpolate${name}`]).domain(d3.extent([min || 10, max || 25], v => v))
