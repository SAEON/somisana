import maplibregl from 'maplibre-gl'
import { vs_ex as vertexSource, fs_ex as fragmentSource } from './_shaders'
import * as twgl from 'twgl.js'

export default {
  id: 'current-vectors',
  type: 'custom',

  // https://maplibre.org/maplibre-gl-js-docs/api/properties/#styleimageinterface#onadd
  onAdd(map, gl) {
    console.log(twgl)
    // create a vertex shader
    var vertexShader = gl.createShader(gl.VERTEX_SHADER)
    gl.shaderSource(vertexShader, vertexSource)
    gl.compileShader(vertexShader)

    // create a fragment shader
    var fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)
    gl.shaderSource(fragmentShader, fragmentSource)
    gl.compileShader(fragmentShader)

    // link the two shaders into a WebGL program
    this.program = gl.createProgram()
    gl.attachShader(this.program, vertexShader)
    gl.attachShader(this.program, fragmentShader)
    gl.linkProgram(this.program)

    this.aPos = gl.getAttribLocation(this.program, 'a_pos')

    var a = maplibregl.MercatorCoordinate.fromLngLat({
      lng: 17,
      lat: -35,
    })
    var b = maplibregl.MercatorCoordinate.fromLngLat({
      lng: 18,
      lat: -34,
    })
    var c = maplibregl.MercatorCoordinate.fromLngLat({
      lng: 20,
      lat: -35,
    })

    // create and initialize a WebGLBuffer to store vertex and color data
    this.buffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, this.buffer)
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([b.x, b.y, a.x, a.y, c.x, c.y]), gl.STATIC_DRAW)
  },

  // https://maplibre.org/maplibre-gl-js-docs/api/map/#map.event:render
  render(gl, matrix) {
    gl.useProgram(this.program)
    gl.uniformMatrix4fv(gl.getUniformLocation(this.program, 'u_matrix'), false, matrix)
    gl.bindBuffer(gl.ARRAY_BUFFER, this.buffer)
    gl.enableVertexAttribArray(this.aPos)
    gl.vertexAttribPointer(this.aPos, 2, gl.FLOAT, false, 0, 0)
    gl.enable(gl.BLEND)
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 3)
  },
}
