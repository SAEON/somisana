import {
  createTextures,
  createProgramInfo,
  createBufferInfoFromArrays,
  setBuffersAndAttributes,
  setUniforms,
  drawBufferInfo,
} from 'twgl.js'
import maplibre from 'maplibre-gl'
import { fs, fsScreen, vs, fsUpdate, vsQuad } from './_shaders'

export default function VectorField(map, gl) {
  let data
  let bounds
  let range
  let programInfo
  let textures
  let screenProgramInfo
  let updateProgramInfo
  let particleTextures
  let numParticles
  let framebuffer
  let particleIndices
  let particleRes
  let state = 'PAUSED'
  let mapBounds

  let fadeOpacity
  let speedFactor
  let dropRate
  let dropRateBump

  let animationId

  let nParticles = 2000

  function setBounds(bounds) {
    const nw = bounds.getNorthWest()
    const se = bounds.getSouthEast()
    const nwMercator = maplibre.MercatorCoordinate.fromLngLat(nw)
    const seMercator = maplibre.MercatorCoordinate.fromLngLat(se)

    //minx miny maxx maxy
    mapBounds = [nwMercator.x, seMercator.y, seMercator.x, nwMercator.y]
  }

  function setData(dataObject) {
    //set vectorField data and bounds of data, and range of vector components
    ;({ data, bounds, range } = dataObject)

    //initialize settings, programs, buffers
    initialize()

    //start animating field
    startAnimation()
  }

  function setParticles(num) {
    particleRes = Math.ceil(Math.sqrt(num))
    numParticles = particleRes * particleRes

    const particleState = new Uint8Array(numParticles * 4)

    for (let i = 0; i < particleState.length; i++) {
      particleState[i] = Math.floor(Math.random() * 256)
    }

    particleTextures = createTextures(gl, {
      particleTexture0: {
        mag: gl.NEAREST,
        min: gl.NEAREST,
        width: particleRes,
        height: particleRes,
        format: gl.RGBA,
        src: particleState,
        wrap: gl.CLAMP_TO_EDGE,
      },
      particleTexture1: {
        mag: gl.NEAREST,
        min: gl.NEAREST,
        width: particleRes,
        height: particleRes,
        format: gl.RGBA,
        src: particleState,
        wrap: gl.CLAMP_TO_EDGE,
      },
    })

    particleIndices = new Float32Array(numParticles)
    for (let i = 0; i < numParticles; i++) {
      particleIndices[i] = i
    }
  }

  function initialize() {
    fadeOpacity = 0.985
    speedFactor = 0.075
    dropRate = 0.003
    dropRateBump = 0.05

    programInfo = createProgramInfo(gl, [vs, fs])
    screenProgramInfo = createProgramInfo(gl, [vsQuad, fsScreen])
    updateProgramInfo = createProgramInfo(gl, [vsQuad, fsUpdate])

    //initial setting of particle positions
    setParticles(nParticles)

    const canvas = document.createElement('canvas')
    const context = canvas.getContext('2d')

    canvas.width = data.width
    canvas.height = data.height

    context.drawImage(dataCanvas, 0, 0)
    const myData = context.getImageData(0, 0, data.width, data.height)

    const emptyPixels = new Uint8Array(gl.canvas.width * gl.canvas.height * 4)

    textures = createTextures(gl, {
      u_image: {
        mag: gl.LINEAR,
        min: gl.LINEAR,
        width: myData.width,
        height: myData.height,
        format: gl.RGBA,
        src: myData.data,
      },
      backgroundTexture: {
        mag: gl.NEAREST,
        min: gl.NEAREST,
        width: gl.canvas.width,
        height: gl.canvas.height,
        format: gl.RGBA,
        src: emptyPixels,
        wrap: gl.CLAMP_TO_EDGE,
      },
      screenTexture: {
        mag: gl.NEAREST,
        min: gl.NEAREST,
        width: gl.canvas.width,
        height: gl.canvas.height,
        format: gl.RGBA,
        src: emptyPixels,
        wrap: gl.CLAMP_TO_EDGE,
      },
    })

    framebuffer = gl.createFramebuffer()
  }

  function drawParticles() {
    gl.useProgram(programInfo.program)

    const arrays = {
      a_index: {
        numComponents: 1,
        data: particleIndices,
      },
    }

    const bufferInfo = createBufferInfoFromArrays(gl, arrays)

    const uniforms = {
      u_vector: textures.u_image,
      u_particles: particleTextures.particleTexture0,
      u_particles_res: particleRes,
      u_vector_min: [range[0], range[0]],
      u_vector_max: [range[1], range[1]],
      u_bounds: mapBounds,
      u_data_bounds: bounds,
    }

    setBuffersAndAttributes(gl, programInfo, bufferInfo)
    setUniforms(programInfo, uniforms)

    drawBufferInfo(gl, bufferInfo, gl.POINTS)
  }

  function drawTexture(texture, opacity) {
    gl.useProgram(screenProgramInfo.program)

    const arrays = {
      a_pos: {
        numComponents: 2,
        data: new Float32Array([0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1]),
      },
    }

    const uniforms = {
      u_screen: texture,
      u_opacity: opacity,
    }

    const bufferInfo = createBufferInfoFromArrays(gl, arrays)
    setBuffersAndAttributes(gl, screenProgramInfo, bufferInfo)
    setUniforms(screenProgramInfo, uniforms)
    drawBufferInfo(gl, bufferInfo)
  }

  function drawScreen() {
    //bind framebuffer
    gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer)
    //draw to screenTexture
    gl.framebufferTexture2D(
      gl.FRAMEBUFFER,
      gl.COLOR_ATTACHMENT0,
      gl.TEXTURE_2D,
      textures.screenTexture,
      0
    )
    //set viewport to size of canvas

    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height)

    //first disable blending
    gl.disable(gl.BLEND)

    //draw backgroundTexture to screenTexture target
    drawTexture(textures.backgroundTexture, fadeOpacity)
    //draw particles to screentexture
    drawParticles()

    //target normal canvas by setting FRAMEBUFFER to null
    gl.bindFramebuffer(gl.FRAMEBUFFER, null)

    //enable blending for final render to map
    gl.enable(gl.BLEND)
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

    drawTexture(textures.screenTexture, 1.0)

    gl.disable(gl.BLEND)

    //swap background with screen
    const temp = textures.backgroundTexture
    textures.backgroundTexture = textures.screenTexture
    textures.screenTexture = temp
  }

  function updateParticles() {
    gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer)
    gl.framebufferTexture2D(
      gl.FRAMEBUFFER,
      gl.COLOR_ATTACHMENT0,
      gl.TEXTURE_2D,
      particleTextures.particleTexture1,
      0
    )

    gl.viewport(0, 0, particleRes, particleRes)

    gl.useProgram(updateProgramInfo.program)

    const arrays = {
      a_pos: {
        numComponents: 2,
        data: new Float32Array([0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1]),
      },
    }

    const uniforms = {
      u_vector: textures.u_image,
      u_particles: particleTextures.particleTexture0,
      u_vector_min: [range[0], range[0]],
      u_vector_max: [range[1], range[1]],
      u_rand_seed: Math.random(),
      u_vector_res: [data.width, data.height],
      u_speed_factor: speedFactor,
      u_drop_rate: dropRate,
      u_drop_rate_bump: dropRateBump,
      u_bounds: mapBounds,
      u_data_bounds: bounds,
    }

    const bufferInfo = createBufferInfoFromArrays(gl, arrays)
    setBuffersAndAttributes(gl, updateProgramInfo, bufferInfo)

    setUniforms(updateProgramInfo, uniforms)

    drawBufferInfo(gl, bufferInfo)

    const temp = particleTextures.particleTexture0
    particleTextures.particleTexture0 = particleTextures.particleTexture1
    particleTextures.particleTexture1 = temp
  }

  function draw() {
    if (state != 'ANIMATING') return

    gl.disable(gl.DEPTH_TEST)
    gl.disable(gl.STENCIL_TEST)

    drawScreen()
    updateParticles()
  }

  function frame() {
    map.triggerRepaint()
    animationId = requestAnimationFrame(frame)
  }

  function startAnimation() {
    state = 'ANIMATING'
    setBounds(map.getBounds())
    frame()
  }

  function stopAnimation() {
    state = 'PAUSED'
    clear()
    cancelAnimationFrame(animationId)
  }

  function clear() {
    gl.clearColor(0.0, 0.0, 0.0, 0.0)

    //clear framebuffer textures
    gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer)
    gl.framebufferTexture2D(
      gl.FRAMEBUFFER,
      gl.COLOR_ATTACHMENT0,
      gl.TEXTURE_2D,
      textures.screenTexture,
      0
    )
    gl.clear(gl.COLOR_BUFFER_BIT)
    gl.framebufferTexture2D(
      gl.FRAMEBUFFER,
      gl.COLOR_ATTACHMENT0,
      gl.TEXTURE_2D,
      textures.backgroundTexture,
      0
    )
    gl.clear(gl.COLOR_BUFFER_BIT)

    //generate new random particle positions
    setParticles(nParticles)

    //target normal canvas
    gl.bindFramebuffer(gl.FRAMEBUFFER, null)

    //clear canvas
    gl.clear(gl.COLOR_BUFFER_BIT)
  }

  return {
    setData,
    startAnimation,
    stopAnimation,
    draw,
  }
}
